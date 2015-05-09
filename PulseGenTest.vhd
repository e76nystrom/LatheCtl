--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:24:52 04/04/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/PulseGenTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PulseGen
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

ENTITY PulseGenTest IS
END PulseGenTest;

ARCHITECTURE behavior OF PulseGenTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component PulseGen
  generic(step_width : positive);
   PORT(
    clk : in std_logic;
    step_in : in std_logic;
    step_out : out std_logic
    );
 end component;

 --Inputs
 signal clk : std_logic := '0';
 signal step_in : std_logic := '0';

 --Outputs
 signal step_out : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 constant width : integer := 5;
 
 signal tmp : signed(3 downto 0) := (3 downto 0 => '0');

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: PulseGen
  generic map (width)
  port MAP (
   clk => clk,
   step_in => step_in,
   step_out => step_out
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

  for j in 0 to 5 loop
   step_in <= '1';
   wait until clk = '1';
   step_in <= '0';
   wait until clk = '0';
   
   for i in 0 to 25 loop
    wait until clk = '1';
    wait until clk = '0';
   end loop;
  end loop;

  for j in 0 to 5 loop
   step_in <= '1';
   delay(10);
   step_in <= '0';
   
   for i in 0 to 25 loop
    wait until clk = '1';
    wait until clk = '0';
   end loop;
  end loop;
  
  wait;
 end process;

END;
