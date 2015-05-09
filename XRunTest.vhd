--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:31:05 02/01/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/XRunTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: XRun
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

ENTITY XRunTest IS
END XRunTest;

ARCHITECTURE behavior OF XRunTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component XRun
  generic(loc_bits : positive);
  PORT(
   clk : in std_logic;
   rst : in std_logic;
   start : in std_logic;
   dir : in std_logic;
   backlash : in std_logic;
   taper_start : in std_logic;
   taper_step : in std_logic;
   dist_zero : in std_logic;
   step : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   loc_sel : in std_logic;
   loc : inout unsigned(loc_bits-1 downto 0);
   load_parm : out std_logic;
   running : out std_logic;
   done_int : out std_logic
   );
 end component;
 
 constant loc_bits : integer := 16;

 --Inputs
 signal clk : std_logic := '0';
 signal rst : std_logic := '0';
 signal start : std_logic := '0';
 signal dir : std_logic := '0';
 signal backlash : std_logic := '0';
 signal taper_start : std_logic := '0';
 signal taper_step : std_logic := '0';
 signal dist_zero : std_logic := '0';
 signal step : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal loc_sel : std_logic := '0';

 signal loc : unsigned(loc_bits-1 downto 0);
 
 --Outputs
 signal loc_out : std_logic;
 signal load_parm : std_logic;
 signal running : std_logic;
 signal done_int : std_logic;

-- Clock period definitions
 constant clk_period : time := 10 ns;
 
 signal tmp : signed(loc_bits-1 downto 0);

 shared variable loc_val : integer;

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 signal tst_backlash : std_logic := '1';
 signal tst_taper : std_logic := '0';

 constant step0 : integer := 10;
 constant step1 : integer := 5;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: XRun
  generic map(loc_bits)
  port MAP (
   clk => clk,
   rst => rst,
   start => start,
   dir => dir,
   backlash => backlash,
   taper_start => taper_start,
   taper_step => taper_step,
   dist_zero => dist_zero,
   step => step,
   din => din,
   dshift => dshift,
   loc_sel => loc_sel,
   loc => loc,
   load_parm => load_parm,
   running => running,
   done_int => done_int
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
  loc_val := 16;

  tmp <= to_signed(loc_val,loc_bits);
  loc_sel <= '1';
  dshift <= '1';
  for i in 0 to loc_bits loop
   wait until clk = '1';
   din <= tmp(loc_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  loc_sel <= '0';

  delay(2);

  rst <= '1';
  delay(2);
  rst <= '0';
  delay(1);

  dir <= '1';

  if (tst_taper = '0') then             --normal motion test
   if (tst_backlash = '1') then         --backlash
    backlash <= '1';
   end if;
   start <= '1';
   wait for clk_period;

   for i in 0 to step0-1 loop
    step <= '1';
    wait for clk_period;
    step <= '0';
    wait for clk_period*3;
   end loop;

   if (tst_backlash = '1') then         --backlash
    dist_zero <= '1';
    delay(5);
    start <= '0';
    dist_zero <= '0';

    delay(3);

    backlash <= '0';
    start <= '1';
    wait for clk_period*2;
   end if;
   
   for i in 0 to step1-1 loop
    step <= '1';
    wait for clk_period;
    step <= '0';
    wait for clk_period*3;
   end loop;

   dist_zero <= '1';
   delay(5);
   start <= '0';
  else                                  --taper test
   taper_start <= '1';
   wait for clk_period;

   for i in 0 to step0-1 loop
    step <= '1';
    wait for clk_period;
    step <= '0';
    wait for clk_period*3;
   end loop;

   taper_start <= '0';
  end if;

  wait;
 end process;

END;
