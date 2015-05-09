--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:26:55 01/26/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/ShiftTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Shift
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

ENTITY ShiftTest IS
END ShiftTest;

ARCHITECTURE behavior OF ShiftTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component Shift
  generic(n : positive);
  PORT(
   clk : in std_logic;
   ena : in std_logic;
   shift_in : in std_logic;
   data : inout  unsigned(n-1 downto 0)
   );
 end component;
 
 constant reg_size : integer := 4;

 --Inputs
 signal clk : std_logic := '0';
 signal ena : std_logic := '0';
 signal shift_in : std_logic := '0';

 --BiDirs
 signal data : unsigned(reg_size-1 downto 0);
 signal tmp : unsigned(reg_size-1 downto 0);

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 
 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: Shift
  generic map(reg_size)
  port MAP (
   clk => clk,
   ena => ena,
   shift_in => shift_in,
   data => data
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
  ena <= '0';
  shift_in <= '0';
--  data <= (reg_size-1 downto 0 => '0');
  
  -- hold reset state for 100 ns.
  wait for 100 ns;	

  wait for clk_period*10;

  -- insert stimulus here 

  for j in 0 to 15 loop
   tmp <= to_unsigned(j,reg_size);
   ena <= '1';
   for i in 0 to reg_size loop
    wait until clk = '1';
    shift_in <= tmp(reg_size - 1);
    tmp <= shift_left(tmp,1);
    wait until clk = '0';
   end loop;
   ena <= '0';
   wait until clk = '1';
   wait until clk = '0';
   assert to_integer(data) = j report "Error" severity ERROR;
  end loop;

  wait;
 end process;

END;
