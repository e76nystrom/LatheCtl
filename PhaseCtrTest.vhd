--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:31:53 02/01/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/PhaseCtrTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PhaseCounter
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

ENTITY PhaseCtrTest IS
END PhaseCtrTest;

ARCHITECTURE behavior OF PhaseCtrTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component PhaseCounter
  generic (phase_bits : positive;
           tot_bits : positive);
  PORT(
   clk : in std_logic;
   ch : in std_logic;
   sync : in std_logic;
   dir : in std_logic;
   init : in std_logic;
   run_sync : in std_logic;
   din : in std_logic;
   phase_sel : in std_logic;
   syn_sel : in std_logic;
   tot_sel : in std_logic;
   read_val : in std_logic;
   syn_out : out std_logic;
   tot_out : out std_logic;
   sync_out : out std_logic
   );
 end component;
 
 constant phase_bits : integer := 16;
 constant total_bits : integer := 16;

 --Inputs
 signal clk : std_logic := '0';
 signal ch : std_logic := '0';
 signal sync : std_logic := '0';
 signal dir : std_logic := '0';
 signal init : std_logic := '0';
 signal run_sync : std_logic := '0';
 signal din : std_logic := '0';
 signal phase_sel : std_logic := '0';
 signal syn_sel : std_logic := '0';
 signal tot_sel : std_logic := '0';
 signal read_val : std_logic := '0';

 --Outputs
 signal syn_out : std_logic;
 signal tot_out : std_logic;
 signal sync_out : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 
 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 signal tmp : signed(phase_bits-1 downto 0);
 signal tmp1 : signed(total_bits-1 downto 0);

 shared variable phase_val : integer;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: PhaseCounter
  generic map(phase_bits,total_bits)
  port MAP (
   clk => clk,
   ch => ch,
   sync => sync,
   dir => dir,
   init => init,
   run_sync => run_sync,
   din => din,
   phase_sel => phase_sel,
   syn_sel => syn_sel,
   tot_sel => tot_sel,
   read_val => read_val,
   syn_out => syn_out,
   tot_out => tot_out,
   sync_out => sync_out
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

  phase_val := 16;

  tmp <= to_signed(phase_val,phase_bits);
  phase_sel <= '1';
  for i in 0 to phase_bits loop
   wait until clk = '1';
   din <= tmp(phase_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  phase_sel <= '0';

  init <= '1';
  delay(3);
  init <= '0';
  delay(1);

  run_sync <= '1';

  for i in 0 to 30 loop
   ch <= '1';
   wait for clk_period;
   ch <= '0';
   wait for clk_period*2;
  end loop;

  sync <= '1';
  delay(3);
  sync <= '0';
  delay(1);

  for i in 0 to 30 loop
   ch <= '1';
   wait for clk_period;
   ch <= '0';
   wait for clk_period*2;
  end loop;

  read_val <= '1';
  delay(1);
  read_val <= '0';

  tmp <= (phase_bits-1 downto 0 => '0');
  syn_sel <= '1';
  for i in 0 to phase_bits loop
   wait until clk = '1';
   tmp <= tmp(phase_bits-2 downto 0) & syn_out;
   wait until clk = '0';
  end loop;
  syn_sel <= '0';

  tmp1 <= (total_bits-1 downto 0 => '0');
  tot_sel <= '1';
  for i in 0 to total_bits loop
   wait until clk = '1';
   tmp1 <= tmp1(total_bits-2 downto 0) & tot_out;
   wait until clk = '0';
  end loop;
  tot_sel <= '0';

  wait;
 end process;

END;
