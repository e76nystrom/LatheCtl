--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:14:10 01/30/2015 
-- Design Name: 
-- Module Name:    Taper - Behavioral 
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

entity Taper is
 generic (syn_bits : positive;
          pos_bits : positive);
 port ( clk : in std_logic;
        init : in std_logic;
        step : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        d_sel : in std_logic;
        incr1_sel : in std_logic;
        incr2_sel : in std_logic;
        xpos : inout unsigned(pos_bits-1 downto 0);
        ypos : inout unsigned(pos_bits-1 downto 0);
        sum : inout unsigned (syn_bits-1 downto 0);
        stepOut : out std_logic);
end Taper;

architecture Behavioral of Taper is

 component Shift is
  generic(n : positive);
  port ( clk : in std_logic;
         din : in std_logic;
         shift : in std_logic;
         data : inout unsigned (n-1 downto 0));
 end component;

 component DataSel is
  generic (n : positive);
  port ( sel : in std_logic_vector (1 downto 0);
         data0 : in unsigned (n-1 downto 0);
         data1 : in unsigned (n-1 downto 0);
         data2 : in unsigned (n-1 downto 0);
         data_out : out unsigned (n-1 downto 0));
 end component;

 component Adder is
  generic (n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         load : in std_logic;
         func : in std_logic;
         a : in unsigned (n-1 downto 0);
         sum : inout unsigned (n-1 downto 0));
 end component;

 component UpCounter is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         clr : in std_logic;
         counter : inout unsigned(n-1 downto 0)
         );
 end component;

 component ShiftOut is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         load : in std_logic;
         dout : out std_logic;
         data : in unsigned(n-1 downto 0)
         );
 end component;

 type fsm is (idle, upd_sum, clr_ena);
 signal state : fsm := idle;

 signal mux_sel : std_logic_vector(1 downto 0);
 constant selD     : std_logic_vector(1 downto 0) := "00";
 constant selIncr1 : std_logic_vector(1 downto 0) := "01";
 constant selIncr2 : std_logic_vector(1 downto 0) := "10";
 signal adder_ena : std_logic;
 signal adder_load : std_logic;

 signal d_shift : std_logic;
 signal incr1_shift : std_logic;
 signal incr2_shift : std_logic;

 signal d : unsigned(syn_bits-1 downto 0);
 signal incr1 : unsigned(syn_bits-1 downto 0);
 signal incr2 : unsigned(syn_bits-1 downto 0);
 signal aval : unsigned(syn_bits-1 downto 0);

 signal xinc : std_logic := '0';
 signal yinc : std_logic := '0';
 signal clr_pos : std_logic;
 
begin

 d_shift <= d_sel and dshift;

 dreg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   din => din,
   shift => d_shift,
   data => d);

 incr1_shift <= incr1_sel and dshift;

 incr1reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   din => din,
   shift => incr1_shift,
   data => incr1);

 incr2_shift <= incr2_sel and dshift;

 incr2reg: Shift
  generic map(syn_bits)
  port map (
   clk => clk,
   din => din,
   shift => incr2_shift,
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
   func => '1',
   a => aval,
   sum => sum);

 xposreg: UpCounter
  generic map(pos_bits)
  port map (
   clk => clk,
   ena => xinc,
   clr => clr_pos,
   counter => xpos);

 yposreg: UpCounter
  generic map(pos_bits)
  port map (
   clk => clk,
   ena => yinc,
   clr => clr_pos,
   counter => ypos);

 taper_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init ='1') then
    stepOut <= '0';
    clr_pos <= '1';
    mux_sel <= SelD;
    adder_load <= '1';
    adder_ena <= '1';
    state <= clr_ena;
   else 
    case state is                       --select state
     when idle =>                       --idle state
      if (step = '1') then              --if step
       state <= upd_sum;                --update sum
      end if;
      
     when upd_sum =>                    --update sum state
      xinc <= '1';
      if (sum(syn_bits-1) = '1') then
       mux_sel <= selIncr1;
      else
       mux_sel <= selIncr2;
       stepOut <= '1';
       yinc <= '1';
      end if;
      adder_ena <= '1';
      state <= clr_ena;                 --clear various bits

     when clr_ena =>                    --clear clock enable state
      stepOut <= '0';
      xinc <= '0';
      yinc <= '0';
      clr_pos <= '0';
      adder_ena <= '0';
      adder_load <= '0';
      if (step = '0') then              --if step pulse gone
       state <= idle;                   --return to idle state
      end if;
    end case;
   end if;
  end if;
 end process;

end Behavioral;
