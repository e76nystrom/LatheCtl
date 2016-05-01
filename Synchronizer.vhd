--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:25:00 01/25/2015 
-- Design Name: 
-- Module Name:    Synchronizer - Behavioral 
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

entity Synchronizer is
 generic (syn_bits : positive;
          pos_bits : positive);
 port ( clk : in std_logic;
        syn_init : in std_logic;
        ch : in std_logic;
        dir : in std_logic;
        dir_ch : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        d_sel : in std_logic;
        incr1_sel : in std_logic;
        incr2_sel : in std_logic;
        xpos : inout unsigned(pos_bits-1 downto 0);
        ypos : inout unsigned(pos_bits-1 downto 0);
        sum : inout unsigned(syn_bits-1 downto 0);
        synstp : out std_logic);
end Synchronizer;

architecture Behavioral of Synchronizer is

 component Shift is
  generic(n : positive);
  port ( clk : in std_logic;
         shift : in std_logic;
         din : in std_logic;
         data : inout  unsigned (n-1 downto 0));
 end component;

 component DataSel is
  generic (n : positive);
  port ( sel : in std_logic_vector (1 downto 0);
         data0 : in  unsigned (n-1 downto 0);
         data1 : in  unsigned (n-1 downto 0);
         data2 : in  unsigned (n-1 downto 0);
         data_out : out  unsigned (n-1 downto 0));
 end component;

 component Adder is
  generic (n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         load : in std_logic;
         func : in std_logic;
         a : in  unsigned (n-1 downto 0);
         sum : inout  unsigned (n-1 downto 0));
 end component;

 component UpDownClrCtr is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         inc : in std_logic;
         clr : in std_logic;
         counter : inout unsigned(n-1 downto 0)
         );
 end component;

 type syn_fsm is (idle, chk_dir, dir_upd1, dir_upd2, upd_sum, clr_ena);
 signal syn_state : syn_fsm := idle;

 signal mux_sel : std_logic_vector(1 downto 0);
 constant selD     : std_logic_vector(1 downto 0) := "00";
 constant selIncr1 : std_logic_vector(1 downto 0) := "01";
 constant selIncr2 : std_logic_vector(1 downto 0) := "10";
 signal adder_ena  : std_logic;
 signal adder_load : std_logic;

 signal d     : unsigned(syn_bits-1 downto 0);
 signal incr1 : unsigned(syn_bits-1 downto 0);
 signal incr2 : unsigned(syn_bits-1 downto 0);
 signal aval  : unsigned(syn_bits-1 downto 0);

 signal xinc    : std_logic := '0';
 signal yinc    : std_logic := '0';
 signal clr_pos : std_logic;
 
 signal d_clk     : std_logic;
 signal incr1_clk : std_logic;
 signal incr2_clk : std_logic;

begin

 d_clk <= d_sel and dshift;

 dreg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => d_clk,
   din => din,
   data => d);

 incr1_clk <= incr1_sel and dshift;

 incr1reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => incr1_clk,
   din => din,
   data => incr1);

 incr2_clk <= incr2_sel and dshift;

 incr2reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   shift => incr2_clk,
   din => din,
   data => incr2);

 mux: DataSel
  generic map(syn_bits)
  port map (
   sel => mux_sel,
   data0 => d,
   data1 => incr1,
   data2 => incr2,
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

 syn_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (syn_init = '1') then
    xinc <= '0';                        --clear increment bits
    yinc <= '0';
    clr_pos <= '1';                     --set to clear position
    adder_load <= '1';                  --set to load accumulator
    mux_sel <= SelD;                    --select d to load
    adder_ena <= '1';                   --enable for loading
    synstp <= '0';
    syn_state <= IDLE;
   else
    case syn_state is                   --select state
     when idle =>                       --idle state
      clr_pos <= '0';
      synstp <= '0';
      adder_load <= '0';
      adder_ena <= '0';
      mux_sel <= selD;                  --select 
      if (ch = '1') then                --if encoder change
       syn_state <= chk_dir;            --check for dir change
      end if;

     when chk_dir =>                    --check direction state
      if (dir_ch = '1') then            --if direction change
       syn_state <= dir_upd1;
       mux_sel <= selIncr1;
       adder_ena <= '1';
      else                              --if no direction change
       syn_state <= upd_sum;            --advance to update sum state
      end if;

     when dir_upd1 =>
      mux_sel <= selIncr2;
      syn_state <= dir_upd2;

     when dir_upd2 =>
      syn_state <= upd_sum;

     when upd_sum =>                    --update sum state
      xinc <= '1';
      if (dir = '1') then
       if (sum(syn_bits-1) = '1') then
        mux_sel <= selIncr1;
       else
        mux_sel <= selIncr2;
        synstp <= '1';
        yinc <= '1';
       end if;
      else
       if (sum(syn_bits-1) = '1') then
        mux_sel <= selIncr2;
       else
        mux_sel <= selIncr1;
        synstp <= '1';
        yinc <= '1';
       end if;
      end if;
      adder_ena <= '1';
      syn_state <= clr_ena;

     when clr_ena =>                    --clear clock enable state
      xinc <= '0';
      yinc <= '0';
      adder_ena <= '0';
      synstp <= '0';
      if (ch = '0') then
       syn_state <= idle;               --return to idle state
      end if;
    end case;
   end if;
  end if;
 end process;

end Behavioral;
