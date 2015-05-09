--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:56:06 01/26/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/SyncTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Synchronizer
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

ENTITY SyncTest IS
END SyncTest;

ARCHITECTURE behavior OF SyncTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component Synchronizer
  generic ( syn_bits : positive;
            pos_bits : positive);
  PORT(
   clk : in std_logic;
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
 end component;

 constant syn_bits : integer := 32;
 constant pos_bits : integer := 18;

 --Inputs
 signal clk : std_logic := '0';
 signal ch : std_logic := '0';
 signal dir : std_logic := '0';
 signal dir_ch : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal d_sel : std_logic := '0';
 signal incr1_sel : std_logic := '0';
 signal incr2_sel : std_logic := '0';
 signal syn_init : std_logic := '0';

 signal xpos : unsigned(pos_bits-1 downto 0);
 signal ypos : unsigned(pos_bits-1 downto 0);
 signal sum : unsigned(syn_bits-1 downto 0);

 --Outputs
 signal synstp : std_logic;
 signal dout : std_logic;
 
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
 uut: Synchronizer
  generic map(syn_bits => syn_bits,
              pos_bits => pos_bits)
  port MAP (
   clk => clk,
   syn_init => syn_init,
   ch => ch,
   dir => dir,
   dir_ch => dir_ch,
   din => din,
   dshift => dshift,
   d_sel => d_sel,
   incr1_sel => incr1_sel,
   incr2_sel => incr2_sel,
   xpos => xpos,
   ypos => ypos,
   sum => sum,
   synstp => synstp
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
  incr2_sel <= '1';
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
    
  syn_init <= '1';
  delay(5);
  syn_init <= '0';

  delay(5);

  dir <= '1';
  dir_ch <= '0';
  for j in 0 to 40 loop
   ch <= '1';
   delay(4);
   ch <= '0';
   delay(2);
  end loop;

  wait;
 end process;

END;
