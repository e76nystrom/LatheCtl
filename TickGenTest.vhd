--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:25:28 04/04/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/TickGenTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TickGen
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

ENTITY TickGenTest IS
END TickGenTest;

ARCHITECTURE behavior OF TickGenTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component TickGen
 generic(div : positive);
  PORT(
   clk : in std_logic;
   tick : out std_logic
   );
 end component;

 --Inputs
 signal clk : std_logic := '0';

 --Outputs
 signal tick : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;

 constant tick_len : integer := 50;
 
 signal tmp : signed(3 downto 0) := (3 downto 0 => '0');

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: TickGen
  generic map(tick_len)
  port MAP (
  clk => clk,
  tick => tick
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

  wait for clk_period*50;

  -- insert stimulus here 

  wait;
 end process;

END;
