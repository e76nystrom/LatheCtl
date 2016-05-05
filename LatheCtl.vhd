--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    19:48:57 04/08/2105
-- Design Name:
-- Module Name:    LatheCtl - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

use RegDef.all;
use CtlBits.all;

entity LatheCtl is
 Port (
  sysclk : in std_logic;
  ja1 : out std_logic;            --test pulse output
  ja2 : out std_logic;            --z limit flag
  ja3 : out std_logic;            --x done
  ja4 : out std_logic;            --z done

  --jb1 : in std_logic;             --data clock
  --jb2 : in std_logic;             --data in
  --jb3 : in std_logic;             --select
  --jb4 : out std_logic;            --data out

  jb1 : in std_logic;             --sck data clock 
  jb2 : out std_logic;            --miso data out
  jb3 : in std_logic;             --mosi data in
  jb4 : in std_logic;             --sel
  
  jc1 : out std_logic;            --z step
  jc2 : out std_logic;            --z direction
  jc3 : out std_logic;            --x step
  jc4 : out std_logic;            --x direction

  --jd1 : in std_logic;             --a input
  --jd2 : in std_logic;             --b input
  --jd3 : in std_logic;             --sync pulse input
  --jd4 : in std_logic;             --serial input

  jd1 : out std_logic;
  jd2 : out std_logic;
  jd3 : out std_logic;
  jd4 : out std_logic;

  led0 : out std_logic;
  led1 : out std_logic;
  led2 : out std_logic;
  led3 : out std_logic;
  led4 : out std_logic;
  led5 : out std_logic;
  led6 : out std_logic;
  led7 : out std_logic;

  sega : out std_logic;
  segb : out std_logic;
  segc : out std_logic;
  segd : out std_logic;
  sege : out std_logic;
  segf : out std_logic;
  segg : out std_logic;

  an0 : out std_logic;
  an1 : out std_logic;
  an2 : out std_logic;
  an3 : out std_logic;

  sw0: in std_logic;
  sw1: in std_logic;
  sw2: in std_logic
  --sw3: in std_logic;
  --sw4: in std_logic;
  --sw5: in std_logic;
  --sw6: in std_logic;
  --sw7: in std_logic;
  );
end LatheCtl;

architecture Behavioral of LatheCtl is

 component latheClk is
  port (
   clk_in  : in  std_logic;
   clk_out : out std_logic;
   reset   : in  std_logic;
   locked  : out std_logic);
 end component;

 component ClockEnable is
  Port (
   clk : in  std_logic;
   ena : in  std_logic;
   clkena : out std_logic);
 end component;

 component Display is
  port(
   clk : in std_logic;
   dspReg : in unsigned(15 downto 0);
   dig_sel : in unsigned(1 downto 0);
   anode : out std_logic_vector(3 downto 0);
   seg : out std_logic_vector(6 downto 0)
   );
 end component;

 component SPI
  generic (op_bits : positive := 8);
  port(
   clk : in std_logic;
   dclk : in std_logic;
   dsel : in std_logic;
   din : in std_logic;
   op : inout unsigned(op_bits-1 downto 0);
   copy : out std_logic;
   shift : out std_logic;
   load : out std_logic
   --;
   );
 end component;

 component LoadReg
  generic (op_bits : positive := 8;
           in_bits: positive := 32;
           out_bits : positive := 32);
  port(
   clk : in  std_logic;
   op: in unsigned(op_bits-1 downto 0);
   regnum : unsigned(op_bits-1 downto 0);
   load : in  std_logic;
   data_in : in  unsigned (out_bits-1 downto 0);
   data_out : out unsigned (out_bits-1 downto 0));
 end component;

 component CtlReg is
  generic(n : positive);
  port(
   clk : in std_logic;
   din : in std_logic;
   shift : in std_logic;
   load : in std_logic;
   data : inout  unsigned (n-1 downto 0));
 end component;

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
   b_out : out std_logic;
   dbg_pulse : out std_logic;
   dbg_done : out std_logic
   );
 end component;

 component Encoder is
  port(
   clk : in std_logic;
   a : in std_logic;
   b : in std_logic;
   ch : inout std_logic;
   dir : inout std_logic;
   dir_ch : out std_logic;
   err : out std_logic);
 end component;

 component TickGen
  PORT(
   clk : in std_logic;
   tick : out std_logic
   );
 end component;

 component FreqCounter
  generic (freq_bits : positive);
  PORT(
   clk : in std_logic;
   ch : in std_logic;
   tick : in std_logic;
   freqCtr_reg : out unsigned(freq_bits-1 downto 0)
   );
 end component;

 component PulseMult
  generic (n : positive);
  port(
   clk : IN  std_logic;
   ch : IN  std_logic;
   clkOut : OUT  std_logic
   );
 end component;

 component PhaseCounter
  generic (phase_bits : positive;
           tot_bits : positive);
  port(
   clk : in std_logic;
   ch : in std_logic;
   sync : in std_logic;
   dir : in std_logic;
   init : in std_logic;
   run_sync : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   phase_sel : in std_logic;
   phasesyn : inout unsigned(phase_bits-1 downto 0);
   totphase : inout unsigned(tot_bits-1 downto 0);
   sync_out : out std_logic);
 end component;

 component SyncAccel is
  generic ( syn_bits : positive;
            pos_bits : positive;
            count_bits : positive);
  port(
   clk : in std_logic;
   init: in std_logic;
   ena: in std_logic;
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
   accelSum  : inout unsigned(syn_bits-1 downto 0);
   synstp : out std_logic;
   test1 : out std_logic;
   test2 : out std_logic;
   accelFlag : out std_logic
   --testFlag : out std_logic_vector(1 downto 0)
   --done : inout std_logic
   );
 end component;

 component FreqGen is
  generic(freq_bits : positive);
  port(
   clk : in std_logic;
   ena : in std_logic;
   dshift : in std_logic;
   freq_sel : in std_logic;
   din : in std_logic;
   pulse_out : out std_logic
   );
 end component;

 component DataSel1_2 is
  port(
   sel : in std_logic;
   d0 : in std_logic;
   d1 : in std_logic;
   dout : out std_logic);
 end component;

 component DataSel1_4 is
  port(
   sel : in std_logic_vector(1 downto 0);
   d0 : in std_logic;
   d1 : in std_logic;
   d2 : in std_logic;
   d3 : in std_logic;
   dout : out std_logic);
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

 component ZRun is
  port(
   clk : in std_logic;                  --input clock
   init : in std_logic;                 --initalize
   start : in std_logic;                --start axis
   backlash : in std_logic;             --backlash move
   sync : in std_logic;                 --sync pulse
   wait_syn : in std_logic;             --synchronized motion
   dist_zero : in std_logic;            --distance zero
   load_parm : out std_logic;           --load parameters
   upd_loc : out std_logic;             --update location
   running : out std_logic;             --running
   done_int : out std_logic;            --done interrupt
   info : out unsigned(3 downto 0)
   );
 end component;

 component LocCounter is
  generic(loc_bits : positive);
  Port(
   clk : in  std_logic;
   step : in std_logic;                 --input step pulse
   dir : in std_logic;                  --direction
   upd_loc : in std_logic;              --location update enabled
   din : in std_logic;                  --shift data in
   dshift : in std_logic;               --shift clock in
   load : in std_logic;                 --load location
   loc_sel : in std_logic;              --location register selected
   loc : inout unsigned(loc_bits-1 downto 0) --current location
   );
 end component;

 component XRun
  port(
   clk : in std_logic;
   rst : in std_logic;
   start : in std_logic;
   backlash : in std_logic;
   dist_zero : in std_logic;
   load_parm : out std_logic;
   upd_loc : out std_logic;
   running : out std_logic;
   done_int : out std_logic;
   info : out unsigned(3 downto 0)
   );
 end component;

 component Taper
  generic (syn_bits : positive;
           pos_bits : positive);
  port(
   clk : in std_logic;
   init : in std_logic;
   step : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   d_sel : in std_logic;
   incr1_sel : in std_logic;
   incr2_sel : in std_logic;
   xpos : inout unsigned(pos_bits-1 downto 0);
   ypos : inout unsigned(pos_bits-1 downto 0);
   sum : inout unsigned(syn_bits-1 downto 0);
   stepOut : out std_logic
   );
 end component;

 component PulseGen is
  generic(step_width : positive := 200);
  port(
   clk : in std_logic;
   step_in : in std_logic;
   step_out : out std_logic);
 end component;

-- sysem clock

 signal clk1 : std_logic;               --system clock
 signal lock : std_logic;               --clock pll locked

-- spi interface signals

 signal dclk : std_logic;               --data clock
 signal din : std_logic;                --data in mosi
 signal dsel : std_logic;               --select line
 signal dout : std_logic;               --data out miso

 -- spi interface

 constant out_bits : positive := 32;
 signal copy : std_logic;               --copy to output register
 signal dshift : std_logic;             --shift data
 signal load : std_logic;               --load to register
 signal op : unsigned(opb-1 downto 0);  --operation code
 signal outReg : unsigned(out_bits-1 downto 0); --output register
 --signal opx : unsigned(opb-1 downto 0); --operation code

 -- clock divider

 constant div_range : integer := 26;
 signal div : unsigned(div_range downto 0);
 alias dig_sel: unsigned(1 downto 0) is div(19 downto 18);

-- z control register

 signal zCtl_sel : std_logic;           --select for shifting data in
 signal zCtl_load : std_logic;          --select for loading contorl reg

 -- x control register

 signal xCtl_sel : std_logic;           --select for shifting data in
 signal xCtl_load : std_logic;          --select for loading contorl reg

-- taper control register

 signal tctl_sel : std_logic;           --select for shifting data in
 signal tctl_load : std_logic;          --select for loading contorl reg
 signal taperZ : std_logic;
 signal taperX : std_logic;

-- z position control register

 signal pCtl_sel : std_logic;           --select for shifting data in
 signal pCtl_load : std_logic;          --select for loading contorl reg

-- configuration register

 signal cCtl_sel : std_logic;           --select for shifting data in
 signal cCtl_load : std_logic;          --select for loading contorl reg

 -- debug control register

 signal dCtl_sel : std_logic;           --select for shifting data in
 signal dCtl_load : std_logic;          --select for loading contorl reg

-- debug frequency generator

 constant dfreq_bits : integer := 12;
 constant dcount_bits : integer := 20;
 signal dbgfreq_sel : std_logic;
 signal dbgcount_sel : std_logic;
 signal dbgFreqClk : std_logic;
 signal zLoad : std_logic;
 signal xLoad : std_logic;
 signal dbgDone : std_logic;

 -- encoder

 signal a_in : std_logic;
 signal b_in : std_logic;
 signal sync_in : std_logic;

 signal a : std_logic;
 signal b : std_logic;
 signal ch : std_logic;
 signal encDirIn : std_logic;
 signal enc_dir : std_logic;
 signal enc_err : std_logic;
 signal dir_ch : std_logic;

-- tick generator

 signal freqCtr_tick : std_logic;

 -- frequency counter

 constant freqCtr_bits : integer := 18;

 signal freqCtr_reg : unsigned(freqCtr_bits-1 downto 0);

 -- pulse multiplier variables

 constant pmult_bits : positive := 16;
 signal multCh : std_logic;
 signal chOut : std_logic;

 -- phase counter variables

 constant phase_bits : positive := 16;
 constant tot_bits : positive := 32;

 signal phasesyn : unsigned(phase_bits-1 downto 0); --phase count on syn pulse
 signal totphase : unsigned(tot_bits-1 downto 0);   --test counter
 signal zSync : std_logic;              --sync pulse one per rev
 signal phase_sel : std_logic;
 signal runSync : std_logic;

 -- z frequency generator variables

 constant freq_bits : integer := 18;
 signal zFreqSel : std_logic;
 signal zFreqEna : std_logic;
 signal zFreqClock : std_logic;

 -- z load source

 signal zSyncInit : std_logic;

 -- z enable source

 signal zTaperSel : std_logic;
 signal zSyncEna : std_logic;

 -- z step input clock

 signal zClockIn : std_logic;

 -- z axis sync and accel

 constant syn_bits : integer := 32;
 constant pos_bits : integer := 18;
 constant count_bits : integer := 18;

 signal zd_sel : std_logic;
 signal zincr1_sel : std_logic;
 signal zincr2_sel : std_logic;
 signal zSynAcl_sel : std_logic;
 signal zSynAclCnt_sel : std_logic;
 signal zXPos : unsigned(pos_bits-1 downto 0);
 signal zYPos : unsigned(pos_bits-1 downto 0);
 signal zSum : unsigned(syn_bits-1 downto 0);
 signal zAccelSum : unsigned(syn_bits-1 downto 0);
 signal zStepOut : std_logic;
 signal zAccel : std_logic;
 signal zTest1 : std_logic;
 signal zTest2 : std_logic;
 --signal zTestFlag : std_logic_vector(1 downto 0);

 -- z axis distance counter

 constant dist_bits : integer := 18; -- bits in acceleration calculation
 signal zdist_sel : std_logic;
 signal zDecel : std_logic;
 signal zDistCtr_reg : unsigned(dist_bits-1 downto 0);
 signal zaclStps_reg : unsigned(dist_bits-1 downto 0);
 signal zDistZero : std_logic;

 -- z run control

 signal zDoneInt : std_logic;
 signal zRunUpdLoc : std_logic;
 signal zLoadParm : std_logic;
 signal zRunning : std_logic;
 signal zRunInfo : unsigned(3 downto 0);

 -- z location

 constant loc_bits : positive := 18;
 signal zLocSel : std_logic;
 signal zLoc : unsigned(loc_bits-1 downto 0); --z location
 signal zUpdLoc : std_logic;

 -- z output control

 signal zStepPulse : std_logic;           --z step output
 signal zStepPulseOut : std_logic;
 signal zDirOut : std_logic;

 -- x frequency generator variables

 signal xFreqSel : std_logic;
 signal xFreqEna : std_logic;
 signal xFreqClock : std_logic;

 -- x load source

 signal xSyncInit : std_logic;

 -- x enable source

 signal xTaperSel : std_logic;
 signal xSyncEna : std_logic;

 -- x step input selector

 signal xClockIn : std_logic;

 -- x axis sync an accel

 signal xd_sel : std_logic;
 signal xincr1_sel : std_logic;
 signal xincr2_sel : std_logic;
 signal xSynAcl_sel : std_logic;
 signal xSynAclCnt_sel : std_logic;
 signal xXPos : unsigned(pos_bits-1 downto 0);
 signal xYPos : unsigned(pos_bits-1 downto 0);
 signal xSum : unsigned(syn_bits-1 downto 0);
 signal xAccelSum : unsigned(syn_bits-1 downto 0);
 signal xStepOut : std_logic;
 signal xAccel : std_logic;
 signal xTest1 : std_logic;
 signal xTest2 : std_logic;
 --signal xTestFlag : std_logic_vector(1 downto 0);

 -- x axis distance counter

 signal xdist_sel : std_logic;
 signal xDecel : std_logic;
 signal xDistCtr_reg : unsigned(dist_bits-1 downto 0);
 signal xaclStps_reg : unsigned(dist_bits-1 downto 0);
 signal xDistZero : std_logic;

 -- x run control

 signal xDoneInt : std_logic;
 signal xRunUpdLoc : std_logic;
 signal xLoadParm : std_logic;
 signal xRunning : std_logic;
 signal xRunInfo : unsigned(3 downto 0);

 -- x location

 signal xLocSel : std_logic;
 signal xLoc : unsigned(loc_bits-1 downto 0); --x location
 signal xUpdLoc : std_logic;

 -- x output control

 signal xStepPulse : std_logic;           --x step output
 signal xStepPulseOut : std_logic;
 signal xDirOut : std_logic;

 -- display signals

 signal dsp_sel : std_logic;
 signal dsp_load : std_logic;

 signal anode : std_logic_vector(3 downto 0);
 signal seg : std_logic_vector(6 downto 0);
 constant dsp_bits : integer := 16;
 signal dspReg : unsigned(opb-1 downto 0);
 signal dspUpd : std_logic;
 signal dspData : unsigned(15 downto 0);

 -- outputs for test pulse generators

 signal test1 : std_logic;
 signal test2 : std_logic;
 signal test3 : std_logic;
 signal test4 : std_logic;

begin

 -- test 1 output pulse

 tstOut1 : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => zClockIn,
   step_out => test1);

 -- test 2 output pulse

 tstOut2 : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => zTest1,
   step_out => test2);

 -- test 3 output pulse

 tstOut3 : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => zTest2,
   step_out => test3);

 -- test 4 output pulse

 tstOut4 : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => zSyncInit,
   step_out => test4);

 --port a

 ja1 <= zStart;
 ja2 <= test1;
 --ja3 <= zDoneInt;
 --ja4 <= xDoneInt;
 ja3 <= zDoneInt;
 ja4 <= zDistZero;

 --port b

 --dclk <= jb1;
 --din  <= jb2;
 --dsel <= jb3;
 --jb4  <= dout;

 dclk <= jb1;
 jb2  <= dout;
 din  <= jb3;
 dsel <= jb4;

 --port c
 
 --jc1 <= zStepPulseOut;
 --jc2 <= xStepPUlseOUt;
 --jc3 <= zSyncEna;
 --jc4 <= xSyncEna;

 jc1 <= test2;
 jc2 <= test3;
 jc3 <= test4;
 jc4 <= zSyncEna;

 --port d

 --a_in <= jd1;
 --b_in <= jd2;
 --sync_in <= jd3;

 jd1 <= dbgRsyn;
 jd2 <= zSrcSyn;
 jd3 <= runSync;
 jd4 <= zRunning;

 a_in <= sw0;
 b_in <= sw1;
 sync_in <= sw2;
 
 --leds

 led0 <= ch;
 led1 <= a;
 led2 <= b;
 led4 <= enc_dir;
 led5 <= enc_err xor
         zStepPulseOut xor
         zDirOut xor
         xStepPulseOut xor
         xDirOut xor
         pReset xor
         pLimit xor
         pZero xor
         zEncDir xor
         test2 xor
         test3 xor
         xTest1 xor
         xTest2 xor
         '0';
 led6 <= dir_ch;
 led7 <= div(div_range);

 --system clock

 sys_Clk : latheClk
  port map (
   CLK_IN  => sysClk,
   CLK_OUT => clk1,
   RESET   => '0',
   LOCKED  => lock
   );

 c1prc : process(clk1)
 begin
  if (rising_edge(clk1)) then
   led3 <= lock;
  end if;
 end process;

 -- clock divider

 clk_div : process(clk1)
 begin
  if (rising_edge(clk1)) then
   div <= div + 1;
  end if;
 end process;

 -- display update clock

 clk_ena : ClockEnable
  port map (
   clk => clk1,
   ena => div(20),
   clkena =>dspUpd);

 -- display data

 dspDataProc : process(clk1)
 begin
  if (rising_edge(clk1)) then
   if ((dspUpd = '1') and (dsel = '1')) then
    dspData <= outReg(15 downto 0);
   end if;
  end if;
 end process;

 -- led display

 led_display : Display
  port map (
   clk => clk1,
   dspReg => dspData,
   dig_sel => dig_sel,
   anode => anode,
   seg => seg);

 -- anode outputs

 an0 <= anode(0);
 an1 <= anode(1);
 an2 <= anode(2);
 an3 <= anode(3);

-- segment outputs

 sega <= seg(6);
 segb <= seg(5);
 segc <= seg(4);
 segd <= seg(3);
 sege <= seg(2);
 segf <= seg(1);
 segg <= seg(0);

 -- spi interface

 spi_int : SPI
  generic map (op_bits => opb)
  port map (
   clk => clk1,
   dclk => dclk,
   dsel => dsel,
   din => din,
   op => op,
   copy => copy,
   shift => dshift,
   load => load
   );

 -- spi return data

 --opx <= op when copy = '1' else dspreg;
 dout <= outReg(out_bits-1);

 outReg_proc : process(clk1)
 begin
  if (rising_edge(clk1)) then
--   if (copy = '1') or ((dspUpd = '1') and (dsel = '1')) then
   if (copy = '1') then
    case op is
     when XRDZXPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & zXPos;
     when XRDZYPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & zYPos;
     when XRDZSUM =>
      outReg <= zSum;
     when XRDZACLSUM =>
      outReg <= zAccelSum;
     when XRDZASTP =>
      outReg <= (out_bits-1 downto dist_bits => '0') & zaclStps_Reg;

     when XRDXXPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & xXPos;
     when XRDXYPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & xYPos;
     when XRDXSUM =>
      outReg <= xSum;
     when XRDXACLSUM =>
      outReg <= xAccelSum;
     when XRDXASTP =>
      outReg <= (out_bits-1 downto dist_bits => '0') & xaclStps_Reg;

     when XRDZDIST =>
      outReg <= (out_bits-1 downto dist_bits => '0') & zDistCtr_reg;
     when XRDXDIST =>
      outReg <= (out_bits-1 downto dist_bits => '0') & xDistCtr_reg;

     when XRDZLOC =>
      outReg <= (out_bits-1 downto loc_bits => zLoc(loc_bits-1)) & zLoc;
     when XRDXLOC =>
      outReg <= (out_bits-1 downto loc_bits => xLoc(loc_bits-1)) & xLoc;

     when XRDFREQ =>
      outReg <= (out_bits-1 downto freqCtr_bits => '0') & freqCtr_reg;
     when XRDSTATE =>
      outReg <= (15 downto 0 => '0') &
                (3 downto 0 => '0') &
                xRunInfo &
                (3 downto 0 => '0') &
                zRunInfo;

     when XRDPSYN =>
      outReg <= (out_bits-1 downto phase_bits => '0') & phasesyn;
     when XRDTPHS =>
      outReg <= totphase;

     when XREADREG =>
      outReg <= (out_bits-1 downto opb => '0') & dspReg;

     when XRDSR =>
      outReg <= (out_bits-1 downto 5 => '0') &
                xStart & zStart & dbgDone & xDoneInt & zDoneInt;

     when others =>
      outReg <= x"55aa55aa";
    end case;
   else
    if (dshift = '1') then
     outReg <= outReg(out_bits-2 downto 0) & outReg(out_bits-1);
    end if;
   end if;
  end if;
 end process;

 -- z control register

 zCtl_sel <= '1' when ((op = XLDZCTL) and (dshift = '1')) else '0';
 zCtl_load <= '1' when ((op = XLDZCTL) and (load = '1')) else '0';

 zctl : CtlReg
  generic map (zCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => zCtl_sel,
   load => zCtl_load,
   data => zCtlReg);

 -- x control register

 xCtl_sel <= '1' when ((op = XLDXCTL) and (dshift = '1')) else '0';
 xCtl_load <= '1' when ((op = XLDXCTL) and (load = '1')) else '0';

 xctl : CtlReg
  generic map (xCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => xCtl_sel,
   load => xCtl_load,
   data => xCtlReg);

 -- taper control register

 tCtl_sel <= '1' when ((op = XLDTCTL) and (dshift = '1')) else '0';
 tCtl_load <= '1' when ((op = XLDTCTL) and (load = '1')) else '0';

 tCtl : CtlReg
  generic map (n => tCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => tCtl_Sel,
   load => tCtl_load,
   data => tctlReg);

 -- z position control register

 pCtl_sel <= '1' when ((op = XLDPCTL) and (dshift = '1')) else '0';
 pCtl_load <= '1' when ((op = XLDPCTL) and (load = '1')) else '0';

 pCtl : CtlReg
  generic map (n => pCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => pCtl_sel,
   load => pCtl_load,
   data => pCtlReg);

 -- configuration control register

 cCtl_sel <= '1' when ((op = XLDCFG) and (dshift = '1')) else '0';
 cCtl_load <= '1' when ((op = XLDCFG) and (load = '1')) else '0';

 cCtl : CtlReg
  generic map (n => cCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => cCtl_sel,
   load => cCtl_load,
   data => cCtlReg);

 -- debug control register

 dCtl_sel <= '1' when ((op = XLDDCTL) and (dshift = '1')) else '0';
 dCtl_load <= '1' when ((op = XLDDCTL) and (load = '1')) else '0';

 dbgctl : CtlReg
  generic map (n => dCtl_size)
  port map (
   clk => clk1,
   din => din,
   shift => dCtl_sel,
   load => dCtl_load,
   data => dCtlReg);

 -- display control register

 dsp_sel <= '1' when ((op = XLDDREG) and (dshift = '1')) else '0';
 dsp_load <= '1' when ((op = XLDDREG) and (load = '1')) else '0';

 dspctl : CtlReg
  generic map (n => opb)
  port map (
   clk => clk1,
   din => din,
   shift => dsp_sel,
   load => dsp_load,
   data => dspReg);

 -- clock simulator for debugging

 dbgfreq_sel <= '1' when (op = XLDTFREQ) else '0';
 dbgcount_sel <= '1' when (op = XLDTCOUNT) else '0';

 dbg_clk : DbgClk
  generic map (freq_bits => dfreq_bits,
               count_bits => dcount_bits)
  port map (
   clk => clk1,
   dbg_ena => dbgEna,
   dbg_sel => dbgSel,
   dbg_dir => dbgDir,
   dbg_count => dbgCount,
   a => a_in,
   b => b_in,
   din => din,
   dshift => dshift,
   load => dbgInit,
   freq_sel => dbgfreq_sel,
   count_sel => dbgcount_sel,
   a_out => a,
   b_out => b,
   dbg_pulse => dbgFreqClk,
   dbg_done => dbgDone
   );

 -- process quadrature signals

 sp_enc : Encoder
  port map (
   clk => clk1,
   a => a,
   b => b,
   ch => ch,
   dir => encDirIn,
   dir_ch => dir_ch,
   err => enc_err);

 enc_dir <= encDirIn xor encPol;

 -- ten ms tick generator

 Tick_Gen : TickGen
  port map (
   clk => clk1,
   tick => freqCtr_tick
   );

 -- spindle pulse frequency counter

 Freq_Counter : FreqCounter
  generic map (freqCtr_bits)
  port map (
   clk => clk1,
   ch => ch,
   tick => freqCtr_tick,
   freqCtr_reg => freqCtr_reg
   );

 -- pulse multiplier

 pulse_Mult : PulseMult
  generic map (pmult_bits)
  port map (
   clk => clk1,
   ch => ch,
   clkOut => multCh
   );

 -- phase change selector

 zChSoure : DataSel1_2
  port map (
   sel => zPulsMult,
   d0 => ch,
   d1 => multCh,
   dout => chOut
   );

 -- phase counter

 phase_sel <= '1' when (op = XLDPHASE) else '0';
 --runSync <= '1' when (dbgRSyn = '1') else
 --           '1' when ((zRunning = '1') and (zSrcSyn = '1')) else
 --           '0';
 runSync = '1';
 
 phase_counter : PhaseCounter
  generic map (phase_bits => phase_bits,
               tot_bits => tot_bits)
  port map (
   clk => clk1,
   ch => chOut,
   sync => sync_in,
   dir => enc_dir,
   init => zReset,
   run_sync => runSync,
   din => din,
   dshift => dshift,
   phase_sel => phase_sel,
   phasesyn => phasesyn,
   totphase => totphase,
   sync_out => zSync);

-- z frequency generator

 zFreqSel <= '1' when (op = XLDZFREQ) else '0';
 zFreqEna <= '1' when ((zRunning = '1') and (zSrcSyn = '0')) else '0';

 zFreqGen : FreqGen
  generic map (freq_bits)
  port map (
   clk => clk1,
   ena => zFreqEna,
   din => din,
   dshift => dshift,
   freq_sel => zFreqSel,
   pulse_out => zFreqClock
   );

 -- z init source

 taperZ <= '1' when (tena = '1') and (tz = '1') else '0';

 --zLoad <= dbgInit or zLoadParm;
 --xLoad <= dbgInit or xLoadParm;

 zLoad <= zLoadParm;
 xLoad <= xLoadParm;

 zLoadSoure : DataSel1_2
  port map (
   sel => taperZ,
   d0 => zLoad,
   d1 => xLoad,
   dout => zSyncInit
   );

 -- z enable source

 ztaperSel <= '1' when (tena = '1') and (tz = '1') and (xRunUpdLoc = '1')
              else '0';

 zEnableSoure : DataSel1_2
  port map (
   --sel => taperZ,
   sel => ztaperSel,
   d0 => zRunning,
   d1 => xRunning,
   dout => zSyncEna
   );

 -- z input step data selector

 zClockIn <= zFreqClock when ((dbgMove = '0')  and (zSrcSyn = '0') and
                             ((tena = '0') or (tz = '0'))) else
             chout      when ((dbgMove = '0')  and (zSrcSyn = '1') and
                             ((tena = '0') or (tz = '0'))) else
             xStepOut   when (dbgMove = '-') and (tena = '1') and (tz = '1') else
             dbgFreqClk when (dbgMove = '1') and ((tEna = '0') or (tz = '0')) else
             '0';

 -- z axis synchronizer

 zd_sel <= '1' when (op = XLDZD) else '0';
 zincr1_sel <= '1' when (op = XLDZINCR1) else '0';
 zincr2_sel <= '1' when (op = XLDZINCR2) else '0';
 zSynAcl_sel <= '1' when (op = XLDZACCEL) else '0';
 zSynAclCnt_sel <= '1' when (op = XLDZACLCNT) else '0';

 z_SyncAccel : SyncAccel
  generic map (syn_bits,pos_bits,count_bits)
  port map (
   clk => clk1,
   init => zSyncInit,
   ena => zSyncEna,
   decel => zDecel,
   ch => zClockIn,
   dir => enc_dir,
   dir_ch => dir_ch,
   din => din,
   dshift => dshift,
   d_sel => zd_sel,
   incr1_sel => zincr1_sel,
   incr2_sel => zincr2_sel,
   accel_sel => zSynAcl_sel,
   accelCount_sel => zSynAclCnt_sel,
   xpos => zXPos,
   ypos => zYPos,
   sum => zSum,
   accelSum => zAccelSum,
   synstp => zStepOut,
   test1 => zTest1,
   test2 => zTest2,
   accelFlag => zAccel
   --testFlag => zTestFlag
   );

 -- z distance counter

 zdist_sel <= '1' when (op = XLDZDIST) else '0';

 zDistCounter : DistCounter
  generic map (dist_bits)
  port map (
   clk => clk1,
   accelFlag => zAccel,
   step => zStepOut,
   init => zLoad,
   din => din,
   dshift => dshift,
   dist_sel => zdist_sel,
   distCtr => zDistCtr_reg,
   aclSteps => zaclStps_reg,
   decel => zDecel,
   dist_zero => zDistZero
   );

-- z run control

 z_run : ZRun
  port map (
   clk => clk1,
   init => zReset,
   start => zStart,
   backlash => zBacklash,
   sync => zSync,
   wait_syn => zWaitSync,
   dist_zero => zDistZero,
   load_parm => zLoadParm,
   upd_loc => zRunUpdLoc,
   running => zRunning,
   done_int => zDoneInt,
   info => zRunInfo
   );

 -- z location update source

 z_LocUpdSrc : DataSel1_2
  port map (
   sel => taperZ,
   d0 => zRunUpdLoc,
   d1 => xRunUpdLoc,
   dout => zUpdLoc
   );

 -- z location

 zLocSel <= '1' when (op = XLDZLOC) else '0';

 z_loc : LocCounter
  generic map (loc_bits)
  port map (
   clk => clk1,
   step => zstepOut,
   dir => zDirIn,
   upd_loc => zUpdLoc,
   din => din,
   dshift => dshift,
   load => zSetLoc,
   loc_sel => zLocSel,
   loc => zLoc
   );

 -- z pulse out

 zPulseOut : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => zStepOut,
   step_out => zStepPulse);

 zStepPulseOut <= zStepPulse xor zStepPol;
 zDirOut <= zDirIn xor zDirPol;

-- x frequency generator

 xFreqSel <= '1' when (op = XLDXFREQ) else '0';
 xFreqEna <= '1' when ((xRunning = '1') and (xSrcSyn = '0')) else '0';

 xFreqGen : FreqGen
  generic map (freq_bits)
  port map (
   clk => clk1,
   ena => xFreqEna,
   din => din,
   dshift => dshift,
   freq_sel => xFreqSel,
   pulse_out => xFreqClock
   );

 -- x init source

 taperX <= '1' when (tena = '1') and (tz = '0') else '0';

 xLoadSoure : DataSel1_2
  port map (
   sel => taperX,
   d0 => xLoad,
   d1 => zLoad,
   dout => xSyncInit
   );

 -- x enable source

 xtaperSel <= '1' when (tena = '1') and (tz = '0') and (zRunUpdLoc = '1')
              else '0';

 xEnableSoure : DataSel1_2
  port map (
   --sel => taperX,
   sel => xTaperSel,
   d0 => xRunning,
   d1 => zRunning,
   dout => xSyncEna
   );

 -- x input step data selector

 xClockIn <= xFreqClock when ((dbgMove = '0')  and (xSrcSyn = '0') and
                              ((tena = '0') or (tz = '1'))) else
             chOut      when ((dbgMove = '0')  and (xSrcSyn = '1') and
                              ((tena = '0') or (tz = '1'))) else
             zStepOut   when (dbgMove = '-') and (tena = '1') and (tz = '0') else
             dbgFreqClk when (dbgMove = '1') and ((tEna = '0') or (tz = '1')) else
             '1';

 -- x axis synchronizer

 xd_sel <= '1' when (op = XLDXD) else '0';
 xincr1_sel <= '1' when (op = XLDXINCR1) else '0';
 xincr2_sel <= '1' when (op = XLDXINCR2) else '0';
 xSynAcl_sel <= '1' when (op = XLDXACCEL) else '0';
 xSynAclCnt_sel <= '1' when (op = XLDXACLCNT) else '0';

 x_SyncAccel : SyncAccel
  generic map (syn_bits,pos_bits,count_bits)
  port map (
   clk => clk1,
   init => xSyncInit,
   ena => xSyncEna,
   decel => xDecel,
   ch => xClockIn,
   dir => enc_dir,
   dir_ch => dir_ch,
   din => din,
   dshift => dshift,
   d_sel => xd_sel,
   incr1_sel => xincr1_sel,
   incr2_sel => xincr2_sel,
   accel_sel => xSynAcl_sel,
   accelCount_sel => xSynAclCnt_sel,
   xpos => xXPos,
   ypos => xYPos,
   sum => xSum,
   accelSum => xAccelSum,
   synstp => xStepOut,
   test1 => xTest1,
   test2 => xTest2,
   accelFlag => xAccel
   --testFlag => xTestFlag
   );

 -- x distance counter

 xdist_sel <= '1' when (op = XLDXDIST) else '0';

 xDistCounter : DistCounter
  generic map (dist_bits)
  port map (
   clk => clk1,
   accelFlag => xAccel,
   step => xStepOut,
   init => xLoad,
   din => din,
   dshift => dshift,
   dist_sel => xdist_sel,
   distCtr => xDistCtr_reg,
   aclSteps => xaclStps_reg,
   decel => xDecel,
   dist_zero => xDistZero
   );

 -- x run control

 x_Run : XRun
  port map (
   clk => clk1,
   rst => xReset,
   start => xStart,
   backlash => xBacklash,
   dist_zero => xDistZero,
   load_parm => xLoadParm,
   upd_loc => xRunUpdLoc,
   running => xRunning,
   done_int => xDoneInt,
   info => xRunInfo
   );

 -- x location update source

 x_LocUpdSrc : DataSel1_2
  port map (
   sel => taperx,
   d0 => xRunUpdLoc,
   d1 => zRunUpdLoc,
   dout => xUpdLoc
   );

 -- x location

 xLocSel <= '1' when (op = XLDXLOC) else '0';

 x_loc : LocCounter
  generic map (loc_bits)
  port map (
   clk => clk1,
   step => xStepOut,
   dir => xDirIn,
   upd_loc => xUpdLoc,
   din => din,
   dshift => dshift,
   load => xSetLoc,
   loc_sel => xLocSel,
   loc => xLoc
   );

 -- x pulse out

 xPulseOut : PulseGen
  generic map (step_width => 25)
  port map (
   clk => clk1,
   step_in => xStepOut,
   step_out => xStepPulse);

 xStepPulseOut <= xStepPulse xor xStepPol;
 xDirOut <= xDirIn xor XDirPol;

end Behavioral;
