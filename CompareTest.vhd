--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:07:28 01/27/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/CompareTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Compare
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
 
ENTITY CompareTest IS
END CompareTest;
 
ARCHITECTURE behavior OF CompareTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component Compare
  generic (n : positive);
  PORT(
   a : in  unsigned(n-1 downto 0);
   b : in  unsigned(n-1 downto 0);
   cmp_ge : in std_logic;
   cmp : out std_logic
   );
 end component;
 
 signal clk : std_logic := '0';

 --Inputs
 constant bits : integer := 16;   -- bits in acceleration calculation
 signal a : unsigned(bits-1 downto 0) := (others => '0');
 signal b : unsigned(bits-1 downto 0) := (others => '0');

 --Outputs
 signal cmp_ge : std_logic;
 signal cmp : std_logic;
 -- No clocks detected in port list. Replace clk below with 
 -- appropriate port name 
 
 constant clk_period : time := 10 ns;
 
BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: Compare
  generic map(bits)
  port MAP (
   a => a,
   b => b,
   cmp_ge => cmp_ge,
   cmp => cmp
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
  cmp_ge <= '1';
  a <= to_unsigned(10,bits);
  b <= to_unsigned(5,bits);
  wait for clk_period*10;
  a <= to_unsigned(5,bits);
  wait for clk_period*10;
  b <= to_unsigned(10,bits);
  wait for clk_period*10;
  cmp_ge <= '0';
  a <= to_unsigned(10,bits);
  b <= to_unsigned(5,bits);
  wait for clk_period*10;
  a <= to_unsigned(5,bits);
  wait for clk_period*10;
  b <= to_unsigned(10,bits);
  wait for clk_period*10;

  wait;
 end process;

END;
