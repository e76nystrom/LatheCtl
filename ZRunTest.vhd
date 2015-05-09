--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   05:34:45 02/01/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/ZRunTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ZRun
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

ENTITY ZRunTest IS
END ZRunTest;

ARCHITECTURE behavior OF ZRunTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component ZRun
  PORT(
   clk : in std_logic;
   init : in std_logic;
   start : in std_logic;
   backlash : in std_logic;
   sync : in std_logic;
   wait_syn : in std_logic;
   dist_zero : in std_logic;
   upd_loc : out std_logic;
   load_parm : out std_logic;
   running : out std_logic;
   run_sync : out std_logic;
   done_int : out std_logic;
   info : out unsigned(3 downto 0)
   );
 end component;

 component LocCounter is
  generic(loc_bits : positive);
  Port ( clk : in  STD_LOGIC;
         step : in std_logic;         --input step pulse
         dir : in std_logic;          --direction
         upd_loc : in std_logic;      --location update enabled
         din : in std_logic;          --shift data in
         dshift : in std_logic;       --shift clock in
         load : in std_logic;         --load location
         loc_sel : in std_logic;      --location register selected
         loc : inout unsigned(loc_bits-1 downto 0) --current location
         );
 end component;

 constant loc_bits : integer := 16;

 --Inputs
 signal clk : std_logic := '0';
 signal init : std_logic := '0';
 signal start : std_logic := '0';
 signal backlash : std_logic := '0';
 signal sync : std_logic := '0';
 signal wait_syn : std_logic := '0';
 signal dist_zero : std_logic := '0';

 signal step : std_logic := '0';
 signal dir : std_logic := '0';
 signal upd_loc : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal loc_sel : std_logic := '0';

 signal loc : unsigned(loc_bits-1 downto 0);

 --Outputs
 signal load_parm : std_logic;
 signal running : std_logic;
 signal done_int : std_logic;
 signal run_sync : std_logic;
 signal info : unsigned(3 downto 0);
 
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

 signal tst_backlash : std_logic := '0';
 signal tst_sync : std_logic := '1';

 constant step0 : integer := 10;
 constant step1 : integer := 5;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: ZRun
  port map (
   clk => clk,
   init => init,
   start => start,
   backlash => backlash,
   sync => sync,
   wait_syn => wait_syn,
   dist_zero => dist_zero,
   load_parm => load_parm,
   upd_loc => upd_loc,
   running => running,
   run_sync => run_sync,
   done_int => done_int,
   info => info
   );

 loc_counter: LocCounter
  generic map(loc_bits)
  port map (
   clk => clk,
   step => step,
   dir => dir,
   upd_loc => upd_loc,
   din => din,
   dshift => dshift,
   load => load_parm,
   loc_sel => loc_sel,
   loc => loc
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

  init <= '1';
  delay(2);
  init <= '0';
  delay(1);

  dir <= '1';
  if (tst_backlash = '1') then
   backlash <= '1';
  end if;

  if (tst_sync = '1') then
   wait_syn <= '1';
  end if;

  start <= '1';
  wait for clk_period;

  for i in 0 to step0-1 loop
   step <= '1';
   wait for clk_period;
   step <= '0';
   wait for clk_period*3;
  end loop;

  if (tst_backlash = '1') then
   dist_zero <= '1';
   delay(5);
   start <= '0';
   dist_zero <= '0';

   delay(3);

   backlash <= '0';
   start <= '1';
   wait for clk_period*2;
  end if;

  if (tst_sync = '1') then
   sync <= '1';
   wait for clk_period;
   sync <= '0';
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

  wait;
 end process;

END;
