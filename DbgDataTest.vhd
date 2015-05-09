--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:34:27 04/07/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/DbgDataTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DbgData
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

ENTITY DbgDataTest IS
END DbgDataTest;

ARCHITECTURE behavior OF DbgDataTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component DbgData
  generic ( data_bits : integer := 16;
            op_bits : integer := 8);
  PORT(
   clk : in std_logic;
   sample : in std_logic;
   dbg_in : in std_logic;
   dbg_op : in  unsigned(op_bits-1 downto 0);
   dsel : in std_logic;
   copy_in : in std_logic;
   shift_in : in std_logic;
   op_in : in  unsigned(op_bits-1 downto 0);
   din : in std_logic;
   copy : out std_logic;
   shift : out std_logic;
   op : out  unsigned(op_bits-1 downto 0);
   dbg_dat : inout  unsigned(data_bits-1 downto 0)
   );
 end component;
 
 constant data_bits : integer := 16;
 constant op_bits : integer := 8;

 --Inputs
 signal clk : std_logic := '0';
 signal sample : std_logic := '0';
 signal dbg_in : std_logic := '0';
 signal dbg_op : unsigned(op_bits-1 downto 0) := (others => '0');
 signal dsel : std_logic := '1';
 signal copy_in : std_logic := '0';
 signal shift_in : std_logic := '0';
 signal op_in : unsigned(op_bits-1 downto 0) := (others => '0');
 signal din : std_logic := '0';

 --BiDirs
 signal dbg_dat : unsigned(data_bits-1 downto 0) := (data_bits-1 downto 0 => '0');

 --Outputs
 signal copy : std_logic;
 signal shift : std_logic;
 signal op : unsigned(op_bits-1 downto 0);

 -- Clock period definitions
 constant clk_period : time := 10 ns;

 constant test_bits : integer := 16; 
 signal tmp : unsigned(test_bits-1 downto 0);

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: DbgData
  generic map (data_bits,op_bits)
  port MAP (
   clk => clk,
   sample => sample,
   dbg_in => dbg_in,
   dbg_op => dbg_op,
   dsel => dsel,
   copy_in => copy_in,
   shift_in => shift_in,
   op_in => op_in,
   din => din,
   copy => copy,
   shift => shift,
   op => op,
   dbg_dat => dbg_dat
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

  dsel <= '1';
  op_in <= to_unsigned(10,op_bits);
  dbg_op <= to_unsigned(15,op_bits);
  copy_in <= '0';
  shift_in <= '0';

  delay(5);
  
  sample <= '1';

  tmp <= to_unsigned(65535,test_bits);
  for i in 0 to 30 loop
   wait until clk = '1';
   if (shift = '1') then
    din <= tmp(0);
    tmp <= shift_right(tmp,1);
   end if;
   wait until clk = '0';
  end loop;

  delay(5);

  sample <= '0';

  delay(10);

  sample <= '1';

  tmp <= to_unsigned(65535,test_bits);
  for i in 0 to 30 loop
   wait until clk = '1';
   if (shift = '1') then
    din <= tmp(0);
    tmp <= shift_right(tmp,1);
   end if;
   wait until clk = '0';
   if (i = 7) then
    dsel <= '0';
   end if;
  end loop;

  delay(5);
   
  sample <= '0';

  delay(1);

  dsel <= '1';

  wait;
 end process;

END;
