--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:37:41 02/01/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/FreqCtrTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FreqCounter
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
 
ENTITY FreqCtrTest IS
END FreqCtrTest;
 
ARCHITECTURE behavior OF FreqCtrTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component FreqCounter
  generic (freq_bits : positive);
  PORT(
   clk : in std_logic;
   init : in std_logic;
   ch : in std_logic;
   tick : in std_logic;
   freqCtr_reg : inout unsigned(freq_bits-1 downto 0);
   ready : out std_logic
   );
 end component;

 constant freq_bits : integer := 16;

 --Inputs
 signal clk : std_logic := '0';
 signal init : std_logic := '0';
 signal ch : std_logic := '0';
 signal tick : std_logic := '0';

 --Outputs
 signal freqCtr_reg : unsigned(freq_bits-1 downto 0);
 signal ready : std_logic;

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
 uut: FreqCounter
  generic map(freq_bits)
  port MAP (
  clk => clk,
  init => init,
  ch => ch,
  tick => tick,
  freqCtr_reg => freqCtr_reg,
  ready => ready
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

  init <= '1';
  wait until clk = '1';
  init <= '0';
  wait until clk = '0';

  tick <= '1';
  wait until clk = '1';
  tick <= '0';
  wait until clk = '0';

  for i in 0 to 4 loop
   ch <= '1';
   wait until clk = '1'; 
   ch <= '0';
   delay(1);
  end loop;

  for i in 0 to 99 loop
   ch <= '1';
   wait until clk = '1'; 
   ch <= '0';
   delay(1);
  end loop;

  tick <= '1';
  wait until clk = '1';
  tick <= '0';
  wait until clk = '0';

  for i in 0 to 4 loop
   ch <= '1';
   wait until clk = '1'; 
   ch <= '0';
   delay(1);
  end loop;

  delay(10);
  
  tick <= '1';
  wait until clk = '1';
  tick <= '0';
  wait until clk = '0';

  for i in 0 to 4 loop
   ch <= '1';
   wait until clk = '1'; 
   ch <= '0';
   delay(1);
  end loop;

  wait;
 end process;

END;
