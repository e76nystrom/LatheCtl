--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:42:45 02/03/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/TaperTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Taper
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY TaperTest IS
END TaperTest;

ARCHITECTURE behavior OF TaperTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component Taper
  generic (syn_bits : positive;
           pos_bits : positive);
  PORT(
   clk : in std_logic;
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
   xIncOut : out std_logic;
   stepOut : out std_logic
   );
 end component;

 constant syn_bits : integer := 32;
 constant pos_bits : integer := 18;

 --Inputs
 signal clk : std_logic := '0';
 signal init : std_logic := '0';
 signal step : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal d_sel : std_logic := '0';
 signal incr1_sel : std_logic := '0';
 signal incr2_sel : std_logic := '0';

 signal xpos : unsigned(pos_bits-1 downto 0);
 signal ypos : unsigned(pos_bits-1 downto 0);
 signal sum : unsigned(syn_bits-1 downto 0);

 --Outputs
 signal xIncOut : std_logic;
 signal stepOut : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 
 signal tmp : signed(syn_bits-1 downto 0);

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 shared variable dx : integer;
 shared variable dy : integer;
 shared variable d : integer;
 shared variable incr1 : integer;
 shared variable incr2 : integer;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: Taper
  generic map(syn_bits,pos_bits)
  port MAP (
   clk => clk,
   init => init,
   step => step,
   din => din,
   dshift => dshift,
   d_sel => d_sel,
   incr1_sel => incr1_sel,
   incr2_sel => incr2_sel,
   xpos => xpos,
   ypos => ypos,
   sum => sum,
   xIncOut => xIncOut,
   stepOut => stepOut
   );

 -- Clock process definitions
 clk_process :process
 begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
 end process;
 

 -- Stimulus process
 stim_proc: process
 begin		
  -- hold reset state for 100 ns.
  wait for 100 ns;	

  wait for clk_period*10;

  -- insert stimulus here 

  -- insert stimulus here

  dx := 2540 * 8;
  dy := 600;

  incr1 := 2 * dy;
  incr2 := 2 * (dy - dx);
  d := incr1 - dx;

  tmp <= to_signed(d,syn_bits);
  d_sel <= '1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  d_sel <= '0';

  tmp <= to_signed(incr1,syn_bits);
  incr1_sel <= '1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  incr1_sel <= '0';

  tmp <= to_signed(incr2,syn_bits);
  incr2_sel <='1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  incr2_sel <='0';

  delay(5);

  init <= '1';
  delay(5);
  init <= '0';

  delay(10);

   for j in 0 to 400 loop
   step <= '1';
   delay(4);
   step <= '0';
   delay(2);
  end loop;
  
  wait;
 end process;

END;
