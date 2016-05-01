--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:48:59 01/26/2015
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6/AxisTest.vhd
-- Project Name:  Spartan6
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AxisMove
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

ENTITY AxisTest IS
END AxisTest;

ARCHITECTURE behavior OF AxisTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component AxisMove
  generic (accel_bits : positive;
           dist_bits : positive);
  PORT(
   clk : in std_logic;
   ena : in std_logic;
   step : in std_logic;
   rst : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   minv_sel : in std_logic;
   maxv_sel : in std_logic;
   accel_sel : in std_logic;
   freq_sel : in std_logic;
   dist_sel : in std_logic;
   dist_ctr : inout unsigned(dist_bits-1 downto 0);
   velocity : inout unsigned(accel_bits-1 downto 0);
   nxt : inout unsigned(accel_bits-1 downto 0);
   acl_stps : inout unsigned(dist_bits-1 downto 0);
   dist_zero : out std_logic;
   stepOut : inout std_logic
   );
 end component;

 constant accel_bits : integer := 26;   -- bits in acceleration calculation
 constant dist_bits : integer := 18;   -- bits in acceleration calculation

 --Inputs
 signal clk : std_logic := '0';
 signal ena : std_logic := '0';
 signal step : std_logic := '0';
 signal rst : std_logic := '0';
 signal din : std_logic := '0';
 signal copy : std_logic := '0';
 signal dshift : std_logic := '0';
 signal minv_sel : std_logic := '0';
 signal maxv_sel : std_logic := '0';
 signal accel_sel : std_logic := '0';
 signal freq_sel : std_logic := '0';
 signal dist_sel : std_logic := '0';
 signal steps : unsigned(dist_bits-1 downto 0) := (dist_bits-1 downto 0 => '0');

 --BiDirs
 signal distCtr_reg : unsigned(dist_bits-1 downto 0);
 signal velocity_reg : unsigned(accel_bits-1 downto 0);
 signal nxt_reg : unsigned(accel_bits-1 downto 0);
 signal aclStps_reg : unsigned(dist_bits-1 downto 0);

 --Outputs
 signal dist_zero : std_logic;
 signal stepOut : std_logic;

 -- No clocks detected in port list. Replace <clock> below with 
 -- appropriate port name 
 
 constant clk_period : time := 10 ns;
 
 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 signal tmp : signed(accel_bits-1 downto 0);
 signal tmp1 : signed(dist_bits-1 downto 0) := (dist_bits-1 downto 0 => '0');

 shared variable minvel : integer;
 shared variable maxvel : integer;
 shared variable accel  : integer;
 shared variable freq   : integer;
 shared variable dist   : integer;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: AxisMove
  generic map (accel_bits,dist_bits)
  port MAP (
  clk => clk,
  ena => ena,
  step => step,
  rst => rst,
  din => din,
  dshift => dshift,
  minv_sel => minv_sel,
  maxv_sel => maxv_sel,
  accel_sel => accel_sel,
  freq_sel => freq_sel,
  dist_sel => dist_sel,
  dist_ctr => distCtr_reg,
  velocity => velocity_reg,
  nxt => nxt_reg,
  acl_stps => aclStps_reg,
  dist_zero => dist_zero,
  stepOut => stepOut
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

  freq := 256000;
  minvel := 25600;
  --maxvel := 256000;
  maxvel := 4 * minvel + 50;
  accel := 512;
  dist := 100;

  tmp <= to_signed(minvel,accel_bits);
  minv_sel <= '1';
  dshift <= '1';
  for i in 0 to accel_bits loop
   wait until clk = '1';
   din <= tmp(accel_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  minv_sel <= '0';

  tmp <= to_signed(maxvel,accel_bits);
  maxv_sel <= '1';
  dshift <= '1';
  for i in 0 to accel_bits loop
   wait until clk = '1';
   din <= tmp(accel_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  maxv_sel <= '0';

  tmp <= to_signed(accel,accel_bits);
  accel_sel <= '1';
  dshift <= '1';
  for i in 0 to accel_bits loop
   wait until clk = '1';
   din <= tmp(accel_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  accel_sel <= '0';

  tmp <= to_signed(freq,accel_bits);
  freq_sel <= '1';
  dshift <= '1';
  for i in 0 to accel_bits loop
   wait until clk = '1';
   din <= tmp(accel_bits - 1);
   tmp <= shift_left(tmp,1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  freq_sel <= '0';

  tmp1 <= to_signed(dist,dist_bits);
  dist_sel <= '1';
  wait until clk = '0';
  for i in 0 to dist_bits-1 loop
   dshift <= '1';
   din <= tmp1(dist_bits - 1);
   wait until clk = '1';
   tmp1 <= shift_left(tmp1,1);
   wait until clk = '0';
   dshift <= '0';
   delay(2);
  end loop;
  dshift <= '0';
  dist_sel <= '0';

  rst <= '1';
  delay(1);
  rst <= '0';

  delay(5);

  ena <= '1';
  for i in 0 to 500 loop
   step <= '1';
   delay(1);
   step <= '0';
   steps <= steps + 1;
   delay(7);
  end loop;
  ena <= '0';

  wait;
 end process;

END;
