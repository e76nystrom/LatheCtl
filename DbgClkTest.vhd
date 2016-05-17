------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:15:29 04/05/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/DbgClkTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DbgClk
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

ENTITY DbgClkTest IS
END DbgClkTest;

ARCHITECTURE behavior OF DbgClkTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component DbgClk
  generic(freq_bits : positive;
          count_bits : positive);
  port(
   clk : in std_logic;
   dbg_ena : in std_logic;
   dbg_sel : in std_logic;
   dbg_dir : in std_logic;
   dbg_count : in std_logic;
   a : in std_logic;
   b : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   load : in std_logic;
   freq_sel : in std_logic;
   count_sel : in std_logic;
   a_out : out std_logic;
   b_out : out std_logic
   );
 end component;

 --Inputs
 signal clk : std_logic := '0';
 signal dbg_ena : std_logic := '0';
 signal dbg_sel : std_logic := '0';
 signal dbg_dir : std_logic := '0';
 signal dbg_count : std_logic := '0';
 signal a : std_logic := '0';
 signal b : std_logic := '0';
 signal din : std_logic := '0';
 signal load : std_logic := '0';
 signal dshift : std_logic := '0';
 signal freq_sel : std_logic := '0';
 signal count_sel : std_logic := '0';

 --Outputs
 signal a_out : std_logic;
 signal b_out : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 constant freq_bits : integer := 4;
 constant count_bits : integer := 5;

 shared variable freq_val : integer;
 shared variable count_val : integer;
 signal tmp : signed(freq_bits-1 downto 0) := (freq_bits-1 downto 0 => '0');
 signal tmp1 : signed(count_bits-1 downto 0) := (count_bits-1 downto 0 => '0');
 
BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: DbgClk
  generic map (freq_bits,count_bits)
  port MAP (
  clk => clk,
  dbg_ena => dbg_ena,
  dbg_sel => dbg_sel,
  dbg_dir => dbg_dir,
  dbg_count => dbg_count,
  a => a,
  b => b,
  din => din,
  dshift => dshift,
  load => load,
  freq_sel => freq_sel,
  count_sel => count_sel,
  a_out => a_out,
  b_out => b_out
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

  dbg_ena <= '0';

  b <= '0';
  a <= '0';

  delay(2);
  
  b <= '0';
  a <= '1';

  delay(2);
  
  b <= '1';
  a <= '1';

  delay(2);
  
  b <= '1';
  a <= '0';

  delay(2);

  b <= '0';
  a <= '0';

  delay(2);
  freq_val := 3;

  tmp <= to_signed(freq_val,freq_bits);
  freq_sel <= '1';
  dshift <= '1';
  for i in 0 to freq_bits loop
   wait until clk = '1';
   din <= tmp(freq_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  freq_sel <= '0';

  count_val := 5 - 1;

  tmp1 <= to_signed(count_val,count_bits);
  count_sel <= '1';
  dshift <= '1';
  for i in 0 to count_bits loop
   wait until clk = '1';
   din <= tmp1(count_bits - 1);
   tmp1 <= shift_left(tmp1,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  count_sel <= '0';

  load <= '1';
  wait until clk = '1';
  load <= '0';
  dbg_sel <= '1';
  delay(1);
  
  dbg_ena <= '1';
  delay(100);
  dbg_dir <= '1';
  delay(50);
  dbg_dir <= '0';
  delay(5);
  dbg_ena <= '0';
  delay(20);
  dbg_count <= '1';
  dbg_ena <= '1';
  delay(50);
  count_val := 4 - 1;

  tmp1 <= to_signed(count_val,count_bits);
  count_sel <= '1';
  dshift <= '1';
  for i in 0 to count_bits loop
   wait until clk = '1';
   din <= tmp1(count_bits - 1);
   tmp1 <= shift_left(tmp1,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  count_sel <= '0';

  load <= '1';
  wait until clk = '1';
  load <= '0';
  delay(1);
  
  delay(50);

  dbg_ena <= '0';
  dbg_count <= '0';
  
  wait;
 end process;

END;
