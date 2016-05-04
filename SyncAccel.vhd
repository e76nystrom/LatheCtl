--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:25:00 01/25/2015 
-- Design Name: 
-- Module Name:    SyncAccel - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SyncAccel is
 generic (syn_bits : positive;
          pos_bits : positive;
          count_bits : positive);
 port (
  clk : in std_logic;
  init : in std_logic;                  --reset
  ena : in std_logic;                   --enable operation
  decel : in std_logic;
  ch : in std_logic;
  dir : in std_logic;
  dir_ch : in std_logic;
  din : in std_logic;
  dshift : in std_logic;
  d_sel : in std_logic;
  incr1_sel : in std_logic;
  incr2_sel : in std_logic;
  accel_sel : in std_logic;
  accelCount_sel : in std_logic;
  xpos : inout unsigned(pos_bits-1 downto 0);
  ypos : inout unsigned(pos_bits-1 downto 0);
  sum : inout unsigned(syn_bits-1 downto 0);
  accelSum  : inout unsigned(syn_bits-1 downto 0);
  synstp : out std_logic;
  test1 : out std_logic;
  test2 : out std_logic;
  accelFlag : out std_logic
  );
end SyncAccel;

architecture Behavioral of SyncAccel is

 component Shift is
  generic(n : positive);
  port (
   clk : in std_logic;
   shift : in std_logic;
   din : in std_logic;
   data : inout  unsigned (n-1 downto 0));
 end component;

 component DataSel4 is
  generic (n : positive);
  port (
   sel : in std_logic_vector (1 downto 0);
   data0 : in  unsigned (n-1 downto 0);
   data1 : in  unsigned (n-1 downto 0);
   data2 : in  unsigned (n-1 downto 0);
   data3 : in  unsigned (n-1 downto 0);
   data_out : out  unsigned (n-1 downto 0));
 end component;

 component Adder is
  generic (n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   load : in std_logic;
   func : in std_logic;
   a : in  unsigned (n-1 downto 0);
   sum : inout  unsigned (n-1 downto 0));
 end component;

 component Accumulator is
  generic (n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   clr : in std_logic;
   func : in std_logic;
   a : in unsigned (n-1 downto 0);
   sum : inout unsigned (n-1 downto 0);
   zero: inout std_logic);
 end component;

 component UpDownClrCtr is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   inc : in std_logic;
   clr : in std_logic;
   counter : inout unsigned(n-1 downto 0)
   );
 end component;

 component DownCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   load : in std_logic;
   preset : in unsigned(n-1 downto 0);
   counter : inout unsigned(n-1 downto 0);
   zero : out std_logic
   );
 end component;

 type fsm is (idle, chk_dir, dir_upd1, dir_upd2,
                  upd_sum, upd_accel, clr_ena);
 signal state : fsm := idle;

 signal mux_sel : std_logic_vector(1 downto 0);
 constant selD     : std_logic_vector(1 downto 0) := "00";
 constant selIncr1 : std_logic_vector(1 downto 0) := "01";
 constant selIncr2 : std_logic_vector(1 downto 0) := "10";
 constant selAccel : std_logic_vector(1 downto 0) := "11";
 signal adder_ena  : std_logic;
 signal adder_load : std_logic;

 signal d      : unsigned(syn_bits-1 downto 0);
 signal incr1  : unsigned(syn_bits-1 downto 0);
 signal incr2  : unsigned(syn_bits-1 downto 0);
 signal accel  : unsigned(syn_bits-1 downto 0);
 signal aval   : unsigned(syn_bits-1 downto 0);

 signal decelActive : std_logic;

 signal accelCount : unsigned(count_bits-1 downto 0);
 --signal accelSum  : unsigned(syn_bits-1 downto 0);

 signal xinc    : std_logic := '0';
 signal yinc    : std_logic := '0';
 signal clr_pos : std_logic;
 
 signal dClk         : std_logic;
 signal incr1Clk     : std_logic;
 signal incr2Clk     : std_logic;
 signal accelClk      : std_logic;
 signal accelCountClk : std_logic;

 signal accelAdd : std_logic;
 signal accelClr : std_logic;
 signal accelUpdate : std_logic;
 signal accelAccumZero : std_logic;

 signal accelCountDec : std_logic;
 signal accelCountPreset : std_logic;
 signal accelCounter : unsigned(count_bits-1 downto 0);
 signal accelCounterZero : std_logic;

begin

 dClk <= d_sel and dshift;
 test1 <= ch;
 test2 <= xInc;

 dreg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => dClk,
   din => din,
   data => d);

 incr1Clk <= incr1_sel and dshift;

 incr1reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => incr1Clk,
   din => din,
   data => incr1);

 incr2Clk <= incr2_sel and dshift;

 incr2reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => incr2Clk,
   din => din,
   data => incr2);

 accelClk <= accel_sel and dshift;

 accelreg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => accelClk,
   din => din,
   data => accel);

 accelCountClk <= accelCount_sel and dshift;

 accelCountReg: Shift
  generic map(count_bits)
  port map (
   clk => clk,
   shift => accelCountClk,
   din => din,
   data => accelCount);

 mux: DataSel4
  generic map(syn_bits)
  port map (
   sel => mux_sel,
   data0 => d,
   data1 => incr1,
   data2 => incr2,
   data3 => accelSum,
   data_out => aval);

 xadder: Adder
  generic map(syn_bits)
  port map (
   clk => clk,
   ena => adder_ena,
   load => adder_load,
   func => dir,
   a => aval,
   sum => sum);

 accelAdd <= not decelActive;

 accelAccum: Accumulator
  generic map(syn_bits)
  port map (
   clk => clk,
   ena => accelUpdate,
   clr => accelClr,
   func => accelAdd,
   a => accel,
   sum => accelSum,
   zero => accelAccumZero);

 accelCtr: DownCounter
  generic map(count_bits)
  port map (
   clk => clk,
   ena => accelCountDec,
   load => accelCountPreset,
   preset => accelCount,
   counter => accelCounter,
   zero => accelCounterZero);

 xposreg: UpDownClrCtr
  generic map(pos_bits)
  port map (
   clk => clk,
   ena => xinc,
   inc => dir,
   clr => clr_pos,
   counter => xpos);

 yposreg: UpDownClrCtr
  generic map(pos_bits)
  port map (
   clk => clk,
   ena => yinc,
   inc => dir,
   clr => clr_pos,
   counter => ypos);

 accelFlag <= '1' when decelActive = '0' and accelCounterZero = '0' else '0';

 syn_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
    --position counters
    xinc <= '0';                        --disable x inc
    yinc <= '0';                        --disable y inc
    clr_pos <= '1';                     --set to clear position
    --sum mux
    mux_sel <= SelD;                    --select d to load
    adder_load <= '1';                  --set to init adder
    mux_sel <= SelD;                    --select d to load
    adder_ena <= '1';                   --enable for loading
    --acceleration registers
    accelCountPreset <= '1';            --preset acceleration counter
    accelUpdate <= '1';                 --flag to update it
    accelClr <= '1';                    --clear acceleration sum
    decelActive <= '0';                 --clear deceleration flag
    --misc
    synstp <= '0';                      --clear output step
    state <= idle;                      --set to idle state
   else
    case state is                       --select state
     when idle =>                       --idle
      clr_pos <= '0';                   --finish clear operation

      adder_ena <= '0';                 --end enable
      mux_sel <= selIncr1;              --select increment 1
      adder_load <= '0';                --end load

      accelUpdate <= '0';               --end update
      accelClr <= '0';                  --end clear operation

      if (decel = '1') and (decelActive = '0') then --if starting decel
       decelActive <= '1';              --start deceleration
       accelCountPreset <= '1';         --start preset for decel countdown
      else
       accelCountPreset <= '0';         --stop preset
      end if;

      synstp <= '0';
      if (ena = '1') then               --if enabled
       if (ch = '1') then               --if encoder change
        state <= chk_dir;               --check for dir change
       end if;
      end if;

     when chk_dir =>                    --check direction for dir change
      accelCountPreset <= '0';          --end preset
      if (dir_ch = '1') then            --if direction change
       adder_ena <= '1';                --enable adder
       mux_sel <= selIncr1;
       state <= dir_upd1;
      else                              --if no direction change
       state <= upd_sum;                --advance to update sum state
      end if;

     when dir_upd1 =>                   --update direction part 1
      mux_sel <= selIncr2;
      state <= dir_upd2;

     when dir_upd2 =>                   --update direction part 2
      state <= upd_sum;

     when upd_sum =>                    --update sum
      adder_ena <= '1';                 --enable adder
      xinc <= '1';                      --enable x increment
      if (dir = '1') then               --if direction positive
       if (sum(syn_bits-1) = '1') then  --if negative (sign bit set)
        mux_sel <= selIncr1;
       else
        mux_sel <= selIncr2;
        synstp <= '1';                  --enable step pulse
        yinc <= '1';                    --enable y increment
       end if;
      else                              --if direction negative
       if (sum(syn_bits-1) = '1') then  --if negative (sign bit set)
        mux_sel <= selIncr2;
       else
        mux_sel <= selIncr1;
        synstp <= '1';                  --enable step pulse
        yinc <= '1';                    --enable y increment
       end if;
      end if;
      state <= upd_accel;

     when upd_accel =>                  --update acceleration
      synstp <= '0';                    --clear step pulse
      xinc <= '0';
      yinc <= '0';
      mux_sel <= selAccel;
      if (accelCounterZero = '0') then  --if accel active
       accelUpdate <= '1';
       accelCountDec <= '1';
      end if;
      state <= clr_ena;

     when clr_ena =>                    --clr enable wait for ch inactive
      adder_ena <= '0';                 --disable adder
      accelUpdate <= '0';
      accelCountDec <= '0';
      if (ch = '0') then                --if change flag cleared
       state <= idle;                   --return to idle state
      end if;
    end case;
   end if;
  end if;
 end process;

end Behavioral;
