--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:56:06 01/26/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/SyncAccelTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Synchronizer
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

ENTITY SyncAccelTest IS
END SyncAccelTest;

ARCHITECTURE behavior OF SyncAccelTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component SyncAccel
  generic ( syn_bits : positive;
            pos_bits : positive;
            count_bits : positive);
  PORT(
   clk : in std_logic;
   init : in std_logic;
   ena : in std_logic;
   decel : in std_logic;
   ch : in std_logic;
   dir : in std_logic;
   dir_ch : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   d_sel : in std_logic;
   incr1_sel : in std_logic;
   incr2_sel : in std_logic;
   accel_sel : in std_logic;
   accelcount_sel : in std_logic;
   xpos : inout unsigned(pos_bits-1 downto 0);
   ypos : inout unsigned(pos_bits-1 downto 0);
   sum : inout unsigned(syn_bits-1 downto 0);
   accelSum : inout unsigned(syn_bits-1 downto 0);
   synstp : out std_logic;
   test1 : out std_logic;
   test2 : out std_logic;
   accelFlag : out std_logic);
 end component;

 component DistCounter
  generic (dist_bits : positive);
  port(
   clk : in std_logic;
   accelFlag : in std_logic;
   step : in std_logic;
   init : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   dist_sel : in std_logic;    
   distCtr : inout unsigned(dist_bits-1 downto 0);
   aclSteps : inout unsigned(dist_bits-1 downto 0);
   decel : inout std_logic;
   dist_zero : out std_logic
   );
 end component;

 constant syn_bits : integer := 32;
 constant pos_bits : integer := 18;
 constant dist_bits : integer := 18;
 constant count_bits : integer := 18;

 --Inputs
 signal clk : std_logic := '0';
 signal init : std_logic := '0';
 signal ena : std_logic := '0';
 signal decel : std_logic := '0';
 signal ch : std_logic := '0';
 signal dir : std_logic := '0';
 signal dir_ch : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal d_sel : std_logic := '0';
 signal incr1_sel : std_logic := '0';
 signal incr2_sel : std_logic := '0';
 signal accel_sel : std_logic := '0';
 signal accelcount_sel : std_logic := '0';

 signal dist_sel : std_logic := '0';

 signal xpos : unsigned(pos_bits-1 downto 0);
 signal ypos : unsigned(pos_bits-1 downto 0);
 signal sum : unsigned(syn_bits-1 downto 0);
 signal accelSum : unsigned(syn_bits-1 downto 0);

 signal distCtr : unsigned(dist_bits-1 downto 0);
 signal aclSteps : unsigned(dist_bits-1 downto 0);

 --Outputs
 signal synstp : std_logic;
 signal accelFlag : std_logic;
 signal test1 : std_logic;
 signal test2 : std_logic;

 signal distZero : std_logic;
 
 constant clk_period : time := 10 ns;
 
 signal tmp : signed(syn_bits-1 downto 0);
 signal tmp1 : signed(count_bits-1 downto 0);
 signal tmp2 : signed(dist_bits-1 downto 0);

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 shared variable dx : integer;
 shared variable dy : integer;
 shared variable d  : integer;
 shared variable incr1 : integer;
 shared variable incr2 : integer;
 shared variable accelVal : integer;
 shared variable accelCount : integer;
 shared variable dist : integer;

 signal syncEna : std_logic;

BEGIN

 syncEna = ena and not distZero;

 -- Instantiate the Unit Under Test (UUT)
 uut: SyncAccel
  generic map(syn_bits => syn_bits,
              pos_bits => pos_bits,
              count_bits => count_bits)
  port map (
   clk => clk,
   init => init,
   ena => syncEna,
   decel => decel,
   ch => ch,
   dir => dir,
   dir_ch => dir_ch,
   din => din,
   dshift => dshift,
   d_sel => d_sel,
   incr1_sel => incr1_sel,
   incr2_sel => incr2_sel,
   accel_sel => accel_sel,
   accelCount_sel => accelCount_sel,
   xpos => xpos,
   ypos => ypos,
   sum => sum,
   accelSum => accelSum,
   synstp => synstp,
   accelFlag => accelFlag
   );

 zDistCounter: DistCounter
  generic map (dist_bits)
  port map (
  clk => clk,
  accelFlag => accelFlag,
  step => synstp,
  init => init,
  din => din,
  dshift => dshift,
  dist_sel => dist_sel,
  distCtr => distCtr,
  aclSteps => aclSteps,
  decel => decel,
  dist_zero => distZero
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

  dx := 2540 * 8;
  dy := 600;

  --dx := 87381248;
  --dy := 341258;

  dist := 2;

  incr1 := 2 * dy;
  incr2 := 2 * (dy - dx);
  d := incr1 - dx;

  accelVal := 8;
  accelCount := 99;

  --accelVal := 0;
  --accelCount := 0;
  
  tmp <= to_signed(d,syn_bits);
  d_sel <= '1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  d_sel <= '0';

  delay(1);

  tmp <= to_signed(incr1,syn_bits);
  incr1_sel <= '1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  incr1_sel <= '0';

  delay(1);

  tmp <= to_signed(incr2,syn_bits);
  incr2_sel <= '1';
  dshift <= '1';
  wait until clk = '0';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  incr2_sel <='0';

  delay(1);

  tmp <= to_signed(accelVal,syn_bits);
  accel_sel <= '1';
  dshift <= '1';
  for i in 0 to syn_bits loop
   wait until clk = '1';
   din <= tmp(syn_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  accel_sel <='0';
  
  --tmp <= to_signed(accel,syn_bits);
  --accel_sel <= '1';
  --wait until clk = '0';
  --for i in 0 to syn_bits-1 loop
  -- dshift <= '1';
  -- din <= tmp(syn_bits - 1);
  -- wait until clk = '1';
  -- tmp <= shift_left(tmp,1);
  -- wait until clk = '0';
  -- dshift <= '0';
  -- delay(2);
  --end loop;
  --dshift <= '0';
  --accel_sel <= '0';

  delay(1);

  tmp1 <= to_signed(accelCount,count_bits);
  accelCount_sel <= '1';
  dshift <= '1';
  for i in 0 to count_bits loop
   wait until clk = '1';
   din <= tmp1(count_bits - 1);
   tmp1 <= shift_left(tmp1,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  accelCount_sel <='0';
  
  delay(1);

  tmp2 <= to_signed(dist,dist_bits);
  dist_sel <= '1';
  wait until clk = '0';
  for i in 0 to dist_bits-1 loop
   dshift <= '1';
   din <= tmp2(dist_bits - 1);
   wait until clk = '1';
   tmp2 <= shift_left(tmp2,1);
   wait until clk = '0';
   dshift <= '0';
   delay(2);
  end loop;
  dshift <= '0';
  dist_sel <= '0';

  delay(5);
    
  init <= '1';
  delay(5);
  init <= '0';

  ena <= '1';
  
  delay(5);

  dir <= '1';
  dir_ch <= '0';
  for j in 0 to 1000 loop
   ch <= '1';
   delay(4);
   ch <= '0';
   delay(2);
  end loop;

  wait;
 end process;

END;
