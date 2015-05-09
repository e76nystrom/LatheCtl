--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:57:09 04/20/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/LatheCtl/PulseMultTest.vhd
-- Project Name:  LatheCtl
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PulseMult
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
--USE ieee.numeric_std.ALL;

ENTITY PulseMultTest IS
END PulseMultTest;

ARCHITECTURE behavior OF PulseMultTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 COMPONENT PulseMult
  generic (n : positive);
  port(
   clk : in  std_logic;
   ch : in  std_logic;
   clkOut : out  std_logic
   );
 end component;

 --Inputs
 signal clk : std_logic := '0';
 signal ch : std_logic := '0';

 --Outputs
 signal clkOut : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 constant clkOut_period : time := 10 ns;
 
 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: PulseMult
  generic map (8)
  PORT MAP
  (
   clk => clk,
   ch => ch,
   clkOut => clkOut
   );

 -- Clock process definitions
 clk_process :process
 begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
 end process;
 
 clkOut_process :process
 begin
  clk <= '0';
  wait for clkOut_period/2;
  clk <= '1';
  wait for clkOut_period/2;
 end process;
 

 -- Stimulus process
 stim_proc: process
 begin		
  -- hold reset state for 100 ns.
  wait for 100 ns;	

  wait for clk_period*10;

  -- insert stimulus here 

  for i in 0 to 20 loop
   ch <= '1';
   delay(1);
   ch <= '0';
   delay(80 - i);
  end loop;
  
  wait;
 end process;

END;
