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

entity LatheCtl is
 Port (
  sysclk : in std_logic;
  ja1 : out std_logic;            --test pulse output
  ja2 : out std_logic;            --z limit flag
  ja3 : out std_logic;            --x done
  ja4 : out std_logic;            --z done

  jb1 : in std_logic;             --data clock
  jb2 : in std_logic;             --data in
  jb3 : in std_logic;             --select
  jb4 : out std_logic;            --data out

  jc1 : out std_logic;            --z step
  jc2 : out std_logic;            --z direction
  jc3 : out std_logic;            --x step
  jc4 : out std_logic;            --x direction

  jd1 : in std_logic;             --a input
  jd2 : in std_logic;             --b input
  --jd3 : in std_logic;             --sync pulse input
  --jd4 : in std_logic;             --serial input

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
  an3 : out std_logic

  --sw0: in std_logic;
  --sw1: in std_logic;
  --sw2: in std_logic;
  --sw3: in std_logic;
  --sw4: in std_logic;
  --sw5: in std_logic;
  --sw6: in std_logic;
  --sw7: in std_logic;
  );
end LatheCtl;

architecture Behavioral of LatheCtl is

 component LatheClk
  port(
   CLKIN_IN   : in  std_logic; 
   RST_IN     : in  std_logic; 
   CLK0_OUT   : out std_logic; 
   LOCKED_OUT : out std_logic);
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
  load : out std_logic--;
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
   dbg_pulse : out std_logic
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

 component Synchronizer is
  generic ( syn_bits : positive;
            pos_bits : positive);
  port(
   clk : in std_logic;
   syn_init: in std_logic;
   ch : in std_logic;
   dir : in std_logic;
   dir_ch : in std_logic;
   din : in std_logic;
   dshift : in std_logic;
   d_sel : in std_logic;
   incr1_sel : in std_logic;
   incr2_sel : in std_logic;
   xpos : inout unsigned(pos_bits-1 downto 0);
   ypos : inout unsigned(pos_bits-1 downto 0);
   sum : inout unsigned(syn_bits-1 downto 0);
   synstp : out std_logic);
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
   synstp : out std_logic;
   accelFlag : out std_logic;
   done : out std_logic);
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

 component AxisMove is
  generic (accel_bits : positive;
           dist_bits : positive);
  port(
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
   stepOut : inout std_logic;
   info : out unsigned(3 downto 0)
   );
 end component;

 component ZRun is
  port(
   clk : in std_logic;                  --input clock
   rst : in std_logic;                  --reset
   start : in std_logic;                --start axis
   backlash : in std_logic;             --backlash move
   sync : in std_logic;                 --sync pulse
   wait_syn : in std_logic;             --synchronized motion
   dist_zero : in std_logic;            --distance zero
   load_parm : out std_logic;           --load parameters
   upd_loc : out std_logic;             --update location
   running : out std_logic;             --running
   run_sync : out std_logic;            --running synchronized
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

 constant opb : integer := 8;

 constant XLDZCTL : unsigned(opb-1 downto 0) := x"00"; --z control register
 constant XLDXCTL : unsigned(opb-1 downto 0) := x"01"; --x control register
 constant XLDTCTL : unsigned(opb-1 downto 0) := x"02"; --load taper control
 constant XLDPCTL : unsigned(opb-1 downto 0) := x"03"; --position control
 constant XLDCFG  : unsigned(opb-1 downto 0) := x"04"; --configuration
 constant XLDDCTL : unsigned(opb-1 downto 0) := x"05"; --load debug control
 constant XLDDREG : unsigned(opb-1 downto 0) := x"06"; --load display register
 constant XLDDFRQ : unsigned(opb-1 downto 0) := x"06"; --load debug frequency

 constant XREADREG : unsigned(opb-1 downto 0) := x"07"; --read register
 constant XLDPHASE : unsigned(opb-1 downto 0) := x"08"; --load phase counter max
 constant XLDZLOC  : unsigned(opb-1 downto 0) := x"09"; --load cur z location

 constant XLDZD     : unsigned(opb-1 downto 0) := x"0a"; --load z initial d
 constant XLDZINCR1 : unsigned(opb-1 downto 0) := x"0b"; --load z incr1
 constant XLDZINCR2 : unsigned(opb-1 downto 0) := x"0c"; --load z incr2
 constant XLDZDELTA : unsigned(opb-1 downto 0) := x"0d"; --load z delta
 constant XLDXLOC  : unsigned(opb-1 downto 0) := x"0d"; --load cur x location

 constant XLDTD     : unsigned(opb-1 downto 0) := x"0e"; --load taper initial d
 constant XLDTINCR1 : unsigned(opb-1 downto 0) := x"0f"; --load taper incr1
 constant XLDTINCR2 : unsigned(opb-1 downto 0) := x"10"; --load taper incr2

 constant XLDZFREQ : unsigned(opb-1 downto 0) := x"11"; --load z freq gen
 constant XLDZMINV : unsigned(opb-1 downto 0) := x"12"; --load x min velocity
 constant XLDZMAXV : unsigned(opb-1 downto 0) := x"13"; --load z max velocity
 constant XLDZACCL : unsigned(opb-1 downto 0) := x"14"; --load z acceleration
 constant XLDZAFRQ : unsigned(opb-1 downto 0) := x"15"; --load z frequency
 constant XLDZDIST : unsigned(opb-1 downto 0) := x"16"; --load z distance

 constant XLDXFREQ : unsigned(opb-1 downto 0) := x"17"; --load x freq gen
 constant XLDXMINV : unsigned(opb-1 downto 0) := x"18"; --load x min velocity
 constant XLDXMAXV : unsigned(opb-1 downto 0) := x"19"; --load x max velocity
 constant XLDXACCL : unsigned(opb-1 downto 0) := x"1a"; --load x acceleration
 constant XLDXAFRQ : unsigned(opb-1 downto 0) := x"1b"; --load x frequency
 constant XLDXDIST : unsigned(opb-1 downto 0) := x"1c"; --load x distance

 constant XRDZSUM  : unsigned(opb-1 downto 0) := x"1d"; --read z sum in z sync
 constant XRDZXPOS : unsigned(opb-1 downto 0) := x"1e"; --read x pos in z sync
 constant XRDZYPOS : unsigned(opb-1 downto 0) := x"1f"; --read y pos in z sync

 constant XRDZVEL  : unsigned(opb-1 downto 0) := x"20"; --read z velocity
 constant XRDZNXT  : unsigned(opb-1 downto 0) := x"21"; --read z next value
 constant XRDZASTP : unsigned(opb-1 downto 0) := x"22"; --read z accel steps

 constant XRDZDIST : unsigned(opb-1 downto 0) := x"23"; --read z distance
 constant XRDXDIST : unsigned(opb-1 downto 0) := x"24"; --read x distance

 constant XRDZLOC  : unsigned(opb-1 downto 0) := x"25"; --read z location
 constant XRDXLOC  : unsigned(opb-1 downto 0) := x"26"; --read x location

 constant XRDFREQ  : unsigned(opb-1 downto 0) := x"27"; --read spindle frequency
 constant XRDSTATE : unsigned(opb-1 downto 0) := x"28"; --read cur state info

 constant XRDTSUM  : unsigned(opb-1 downto 0) := x"29"; --read sum from taper
 constant XRDTX    : unsigned(opb-1 downto 0) := x"2a"; --read x pos from taper
 constant XRDTY    : unsigned(opb-1 downto 0) := x"2b"; --read y pos from taper

 constant XRDPSYN  : unsigned(opb-1 downto 0) := x"2c"; --read sync phase value
 constant XRDTPHS  : unsigned(opb-1 downto 0) := x"2d"; --read total phase value

 constant XLDZLIM  : unsigned(opb-1 downto 0) := x"2e"; --read z limit
 constant XRDZPOS  : unsigned(opb-1 downto 0) := x"2f"; --read z position

 constant XLDTFREQ  : unsigned(opb-1 downto 0) := x"30"; --load test frequency
 constant XLDTCOUNT : unsigned(opb-1 downto 0) := x"31"; --load test count

 constant XRDXVEL  : unsigned(opb-1 downto 0) := x"32"; --read x velocity
 constant XRDXNXT  : unsigned(opb-1 downto 0) := x"33"; --read x next value
 constant XRDXASTP : unsigned(opb-1 downto 0) := x"34"; --read x accel steps

 constant XLDZSACCEL  : unsigned(opb-1 downto 0) := x"35"; --load z syn accel
 constant XLDZSACLCNT : unsigned(opb-1 downto 0) := x"36"; --load z syn acl cnt

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

 -- clock divider

 constant div_range : integer := 26;
 signal div : unsigned(div_range downto 0);
 alias dig_sel: unsigned(1 downto 0) is div(19 downto 18);

-- z control register

 constant zctl_size : integer := 8;
 signal zCtlReg  : unsigned(zctl_size-1 downto 0);
 alias zReset    : std_logic is zCtlReg(0); --reset
 alias zStart    : std_logic is zCtlReg(1); --run z
 alias zSrcSyn   : std_logic is zCtlReg(2); --one syn clk, zero freq gen
 alias zDirIn    : std_logic is zCtlReg(3); --one dir pos, zero dir neg
 alias zSetLoc   : std_logic is zCtlReg(4); --load location register
 alias zBackl    : std_logic is zCtlReg(5); --backlash move no pos update
 alias zWaitSync : std_logic is zCtlReg(6); --wait for sync to start z
 alias zPulsMult : std_logic is zCtlReg(7); --enable pulse multiplier
 --alias zdir_enc  : std_logic is zCtlReg(7); --one dir from encoder

 signal zctl_sel : std_logic;

 -- x control register
 
 constant xctl_size : integer := 6;
 signal xCtlReg  : unsigned(xctl_size-1 downto 0);
 alias xReset    : std_logic is xCtlReg(0); --reset x
 alias xStart    : std_logic is xCtlReg(1); --run x
 alias xSrcSyn   : std_logic is xCtlReg(2); --one syn clk, zero freq gen
 alias xDirIn    : std_logic is xCtlReg(3); --x direction
 alias xSetLoc   : std_logic is xCtlReg(4); --load location register
 alias xBacklash : std_logic is xCtlReg(5); --backlash move no pos update

 signal xctl_sel : std_logic;

-- taper control register

 constant tctl_size : integer := 3;
 signal tCtlReg  : unsigned(tctl_size-1 downto 0);
 alias tload     : std_logic is tCtlReg(0); --load taper control
 alias tEna      : std_logic is tCtlReg(1); --enable tapering
 alias tZ        : std_logic is tCtlReg(2); --one taper z zero taper x
 signal tCtlSel : std_logic;

-- z position control register

 constant pctl_size : integer := 3;
 signal pctlreg  : unsigned(pctl_size-1 downto 0);
 alias pReset    : std_logic is pctlreg(0); --reset position control
 alias pLimit    : std_logic is pctlreg(1); --signal limit
 alias pZero     : std_logic is pctlreg(2); --signal zero
 signal pCtlSel : std_logic;

-- configuration register

 constant cctl_size : integer := 5;
 signal cCtlReg  : unsigned(cctl_size-1 downto 0);
 alias  zStepPol : std_logic is cCtlReg(0); --z step pulse polarity
 alias  zDirPol  : std_logic is cCtlReg(1); --z direction polarity
 alias  xStepPol : std_logic is cCtlReg(2); --x step pulse polarity
 alias  xDirPol  : std_logic is cCtlReg(3); --x direction polarity
 alias  encPol   : std_logic is cCtlReg(4); --encoder direction polarity
 signal cCtlSel : std_logic;

 -- debug control register

 constant dctl_size : integer := 6;
 signal dctlreg  : unsigned(dctl_size-1 downto 0);
 alias dbgEna   : std_logic is dctlreg(0);
 alias dbgDir   : std_logic is dctlreg(1);
 alias dbgCount : std_logic is dctlreg(2);
 alias dbgInit  : std_logic is dctlreg(3);
 alias dbgRSyn  : std_logic is dctlreg(4);
 alias dbgMove  : std_logic is dctlreg(5);
 signal dctl_sel : std_logic;

-- debug frequency generator

 constant dfreq_bits : integer := 12;
 constant dcount_bits : integer := 20;
 signal dbgfreq_sel : std_logic;
 signal dbgcount_sel : std_logic;
 signal dbgPulse : std_logic;
 --signal dbg1 : std_logic;
 --signal dbg2 : std_logic;

 -- encoder
 
 signal a_in : std_logic;
 signal b_in : std_logic;

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

 -- z synchronizer

 constant syn_bits : integer := 32;
 constant pos_bits : integer := 18;
 constant count_bits : integer := 18;

 signal zd_sel : std_logic;
 signal zincr1_sel : std_logic;
 signal zincr2_sel : std_logic;
 signal zSynAcl_sel : std_logic;
 signal zSynAclCnt_sel : std_logic;
 signal zxpos : unsigned(pos_bits-1 downto 0);
 signal zypos : unsigned(pos_bits-1 downto 0);
 signal zsum : unsigned(syn_bits-1 downto 0);
 signal zLoad : std_logic;
 signal zSyncStep : std_logic;
 signal zSyncAccel : std_logic;
 signal zSyncDone : std_logic;

 -- z frequency generator variables

 constant freq_bits : integer := 18;
 signal zFreqSel : std_logic;
 signal zFreqEna : std_logic;
 signal zFreqStep : std_logic;

 -- z step data selector
 
 --signal zStepSourceSel : std_logic_vector(1 downto 0);
 signal zAxisStep : std_logic;
 
 -- z axis acceleration
 
 constant accel_bits : integer := 26; -- bits in acceleration calculation
 constant dist_bits : integer := 18; -- bits in acceleration calculation

 signal zminv_sel : std_logic;
 signal zmaxv_sel : std_logic;
 signal zaccel_sel: std_logic;
 signal zafreq_sel : std_logic;
 signal zdist_sel : std_logic;
 signal zDistZero : std_logic;
 signal zDistCtr_reg : unsigned(dist_bits-1 downto 0);
 signal zvelocity_reg : unsigned(accel_bits-1 downto 0);
 signal znxt_reg : unsigned(accel_bits-1 downto 0);
 signal zaclStps_reg : unsigned(dist_bits-1 downto 0);
 signal zStep : std_logic;
 signal zInfo : unsigned(3 downto 0);

 -- z run control

 signal zDoneInt : std_logic;
 signal zRunUpdLoc : std_logic;
 signal zLoadParm : std_logic;
 signal zRunning : std_logic;
 signal zRunSync : std_Logic;
 signal zRunInfo : unsigned(3 downto 0);

 -- z step output selector
 
 --signal ZLocSrc : std_logic;
 signal ZLocSrc : std_logic_vector(1 downto 0);
 signal zStepOut : std_logic;
 
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
 signal xFreqStep : std_logic;

 -- x step data selector
 
 signal xAxisStep : std_logic;
 
 -- x axis acceleration
 
 signal xminv_sel : std_logic;
 signal xmaxv_sel : std_logic;
 signal xaccel_sel: std_logic;
 signal xafreq_sel : std_logic;
 signal xdist_sel : std_logic;
 signal xDistZero : std_logic;
 signal xDistCtr_reg : unsigned(dist_bits-1 downto 0);
 signal xvelocity_reg : unsigned(accel_bits-1 downto 0);
 signal xnxt_reg : unsigned(accel_bits-1 downto 0);
 signal xaclStps_reg : unsigned(dist_bits-1 downto 0);
 signal xStep : std_logic;
 signal xInfo : unsigned(3 downto 0);

 -- x run control

 signal xDoneInt : std_logic;
 signal xRunUpdLoc : std_logic;
 signal xLoadParm : std_logic;
 signal xRunning : std_logic;
 signal xRunInfo : unsigned(3 downto 0);

 -- x step output selector
 
 signal XLocSrc : std_logic;
 signal xStepOut : std_logic;
 
 -- x location

 signal xLocSel : std_logic;
 signal xLoc : unsigned(loc_bits-1 downto 0); --x location
 signal xUpdLoc : std_logic;

 -- x output control
 
 signal xStepPulse : std_logic;           --x step output
 signal xStepPulseOut : std_logic;
 signal xDirOut : std_logic;

 -- taper source selector

 signal taperSourceSel : std_logic_vector(1 downto 0);

 -- taper signals

 signal taperStepIn : std_logic;
 signal tStep : std_logic;
 signal td_sel : std_logic;
 signal tincr1_sel : std_logic;
 signal tincr2_sel : std_logic;
 signal txpos : unsigned(pos_bits-1 downto 0);
 signal typos : unsigned(pos_bits-1 downto 0);
 signal tsum : unsigned(syn_bits-1 downto 0);

 -- display signals

 signal anode : std_logic_vector(3 downto 0);
 signal seg : std_logic_vector(6 downto 0);
 constant dsp_bits : integer := 16;
 signal dspReg : unsigned(dsp_bits-1 downto 0);
 signal dsp_sel : std_logic;

 -- outputs for test pulse generators

 signal test1 : std_logic;
 signal test2 : std_logic;

begin

 ja1 <= zUpdLoc;
 ja2 <= zSetLoc;
 ja3 <= xDoneInt;
 ja4 <= zDoneInt;

 dclk <= jb1;
 din  <= jb2;
 dsel <= jb3;
 jb4  <= dout;
 
 jc1 <= test1;
 jc2 <= zStepPulse;
 jc3 <= zRunning;
 jc4 <= test2;

 a_in <= jd1;
 b_in <= jd2;

 led0 <= ch;
 led1 <= a;
 led2 <= b;
 led4 <= enc_dir;
 led5 <= enc_err xor
         zStepPulseOut xor
         zDirOut xor
         zSyncDone xor
         zSyncAccel xor
         xStepPulseOut xor
         xDirOut xor
         pReset xor
         pLimit xor
         pZero xor
         test1 xor
         test2;
 led6 <= dir_ch;
 led7 <= div(div_range);

 --system clock

 sys_clk: LatheClk
  port map (
   CLKIN_IN   => sysclk,
   RST_IN => '0',
   CLK0_OUT   => clk1,
   LOCKED_OUT => lock);

 c1prc: process(clk1)
 begin
  if (rising_edge(clk1)) then
   led3 <= lock;
  end if;
 end process;

 -- clock divider

 clk_div: process(clk1)
 begin
  if (rising_edge(clk1)) then
   div <= div + 1;
  end if;
 end process;

 -- led display

 led_display : Display
  port map ( clk => clk1,
--             dspReg => outReg(dsp_bits-1 downto 0),
             dspReg => xLoc(dsp_bits-1 downto 0),
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

 spi_int: SPI
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

 dout <= outReg(out_bits-1);

 outReg_proc: process(clk1)
 begin
  if (rising_edge(clk1)) then
   if (copy = '1') then
    case op is
     when XRDZXPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & zxpos;
     when XRDZYPOS =>
      outReg <= (out_bits-1 downto pos_bits => '0') & zypos;
     when XRDZSUM =>
      outReg <= zsum;

     when XRDZVEL =>
      outReg <= (out_bits-1 downto accel_bits => '0') & zvelocity_reg;
     when XRDZNXT =>
      outReg <= (out_bits-1 downto accel_bits => znxt_reg(accel_bits-1)) &
                znxt_reg;
     when XRDZASTP =>
      outReg <= (out_bits-1 downto dist_bits => '0') & zaclStps_reg;

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
                xInfo &
                xRunInfo &
                zInfo &
                zRunInfo;

     when XRDTX =>
      outReg <= (out_bits-1 downto pos_bits => '0') & txpos;
     when XRDTY =>
      outReg <= (out_bits-1 downto pos_bits => '0') & typos;
     when XRDTSUM =>
      outReg <= tsum;

     when XRDPSYN =>
      outReg <= (out_bits-1 downto phase_bits => '0') & phasesyn;
     when XRDTPHS =>
      outReg <= totphase;

     when XREADREG =>
      outReg <= (out_bits-1 downto dsp_bits => '0') & dspReg;

     when XRDXNXT =>
      outReg <= (out_bits-1 downto accel_bits => xnxt_reg(accel_bits-1)) &
                xnxt_reg;

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

 zctl_sel <= '1' when ((op = XLDZCTL) and (dshift = '1')) else '0';

 zctl : CtlReg
  generic map (zctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => zctl_sel,
   load => load,
   data => zCtlReg);

 -- x control register

 xctl_sel <= '1' when ((op = XLDXCTL) and (dshift = '1')) else '0';

 xctl : CtlReg
  generic map (xctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => xctl_sel,
   load => load,
   data => xCtlReg);

 -- taper control register

 tCtlSel <= '1' when ((op = XLDTCTL) and (dshift = '1')) else '0';

 tCtl : CtlReg
  generic map (n => tctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => tCtlSel,
   load => load,
   data => tctlreg);

 -- z position control register

 pCtlSel <= '1' when ((op = XLDPCTL) and (dshift = '1')) else '0';

 pCtl : CtlReg
  generic map (n => pctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => pCtlSel,
   load => load,
   data => pCtlReg);

 -- configuration register

 cCtlSel <= '1' when ((op = XLDCFG) and (dshift = '1')) else '0';

 cCtl : CtlReg
  generic map (n => cctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => cCtlSel,
   load => load,
   data => cCtlreg);

 -- debug control register

 dctl_sel <= '1' when ((op = XLDDCTL) and (dshift = '1')) else '0';

 dbgctl : CtlReg
  generic map (n => dctl_size)
  port map (
   clk => clk1,
   din => din,
   shift => dctl_sel,
   load => load,
   data => dctlreg);

 dsp_sel <= '1' when ((op = XLDDREG) and (dshift = '1')) else '0';

 dspctl : CtlReg
  generic map (n => dsp_bits)
  port map (
   clk => clk1,
   din => din,
   shift => dsp_sel,
   load => load,
   data => dspReg);

 -- clock simulator for debugging

 dbgfreq_sel <= '1' when (op = XLDTFREQ) else '0';
 dbgcount_sel <= '1' when (op = XLDTCOUNT) else '0';

 dbg_clk: DbgClk
  generic map (freq_bits => dfreq_bits,
               count_bits => dcount_bits)
  port map(
   clk => clk1,
   dbg_ena => dbgEna,
   dbg_dir => dbgDir,
   dbg_count => dbgCount,
   a => a_in,
   b => b_in,
   din => din,
   dshift => dshift,
   load => zLoad,
   freq_sel => dbgfreq_sel,
   count_sel => dbgcount_sel,
   a_out => a,
   b_out => b,
   dbg_pulse =>dbgPulse
   );

 -- process quadrature signals

 sp_enc: Encoder
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
 
 Tick_Gen: TickGen
  port map(
   clk => clk1,
   tick => freqCtr_tick
   );

 -- spindle pulse frequency counter
 
 Freq_Counter: FreqCounter
  generic map(freqCtr_bits)
  port MAP(
   clk => clk1,
   ch => ch,
   tick => freqCtr_tick,
   freqCtr_reg => freqCtr_reg
   );

 -- pulse multiplier

 pulse_Mult: PulseMult
  generic map(pmult_bits)
  port map(
  clk => clk1,
  ch => ch,
  clkOut => multCh 
  );

 -- phase change selector

 zChSoure: DataSel1_2
  port map(
   sel => zPulsMult,
   d0 => ch,
   d1 => multCh,
   dout =>chOut 
   );

 -- phase counter

 phase_sel <= '1' when (op = XLDPHASE) else '0';
 zLoad <= dbgInit or zLoadParm;
 runSync <= dbgRSyn or zRunSync;

 phase_counter: PhaseCounter
  generic map (phase_bits => phase_bits,
               tot_bits => tot_bits)
  port map (
   clk => clk1,
   ch => chOut,
   sync => div(18),
   dir => enc_dir,
   init => zLoad,
   run_sync => runSync,
   din => din,
   dshift => dshift,
   phase_sel => phase_sel,
   phasesyn => phasesyn,
   totphase => totphase,
   sync_out => zSync);

 -- z axis synchronizer

 zd_sel <= '1' when (op = XLDZD) else '0';
 zincr1_sel <= '1' when (op = XLDZINCR1) else '0';
 zincr2_sel <= '1' when (op = XLDZINCR2) else '0';
 zSynAcl_sel <= '1' when (op = XLDZSACCEL) else '0';
 zSynAclCnt_sel <= '1' when (op = XLDZSACLCNT) else '0';

 --sp_sync: Synchronizer
 -- generic map(syn_bits,pos_bits)
 -- port map (
 --  clk => clk1,
 --  syn_init => zLoad,
 --  ch => chOut,
 --  dir => enc_dir,
 --  dir_ch => dir_ch,
 --  din => din,
 --  dshift => dshift,
 --  d_sel => zd_sel,
 --  incr1_sel => zincr1_sel,
 --  incr2_sel => zincr2_sel,
 --  xpos => zxpos,
 --  ypos => zypos,
 --  sum => zsum,
 --  synstp => zSyncStep);

 sp_sync: SyncAccel
  generic map(syn_bits,pos_bits,count_bits)
  port map (
   clk => clk1,
   init => zLoad,
   ena => runSync,
   decel => '1',
   ch => chOut,
   dir => enc_dir,
   dir_ch => dir_ch,
   din => din,
   dshift => dshift,
   d_sel => zd_sel,
   incr1_sel => zincr1_sel,
   incr2_sel => zincr2_sel,
   accel_sel => zSynAcl_sel,
   accelCount_sel => zSynAclCnt_sel,
   xpos => zxpos,
   ypos => zypos,
   sum => zsum,
   synstp => zSyncStep,
   accelFlag => zSyncAccel,
   done => zSyncDone);

-- z frequency generator

 zFreqSel <= '1' when (op = XLDZFREQ) else '0';
 zFreqEna <= '1' when ((zRunning = '1') and (zSrcSyn = '0')) else '0';
 
 zFreqGen: FreqGen
  generic map(freq_bits)
  port map(
   clk => clk1,
   ena => zFreqEna,
   din => din,
   dshift => dshift,
   freq_sel => zFreqSel,
   pulse_out => zFreqStep 
   );

 -- z step data selector

 --zStepSoure: DataSel1_2
 -- port map(
 --  sel => zSrcSyn,
 --  d0 => zFreqStep,
 --  d1 => zSyncStep,
 --  dout =>zAxisStep 
 --  );

 --zStepSourceSel <= dbgMove & zSrcSyn;

 --zStepSoure: DataSel1_4
 -- port map(
 --  sel => zStepSourceSel,
 --  d0 => zFreqStep,
 --  d1 => zSyncStep,
 --  d2 => dbgPulse,
 --  d3 => dbgPulse,
 --  dout =>zAxisStep 
 --  );
 
 zStepSoure: DataSel1_2
  port map(
   sel => dbgMove,
   d0 => zFreqStep,
   d1 => dbgPulse,
   dout =>zAxisStep
   );

 -- z acceleration

 zminv_sel <= '1' when (op = XLDZMINV) else '0';
 zmaxv_sel <= '1' when (op = XLDZMAXV) else '0';
 zaccel_sel <= '1' when (op = XLDZACCL) else '0';
 zafreq_sel <= '1' when (op = XLDZAFRQ) else '0';
 zdist_sel <= '1' when (op = XLDZDIST) else '0';

 z_move: AxisMove
  generic map (accel_bits,dist_bits)
  port map (
   clk => clk1,
   ena => zRunning,
   step => zAxisStep,
   rst => zReset,
   din => din,
   dshift => dshift,
   minv_sel => zminv_sel,
   maxv_sel => zmaxv_sel,
   accel_sel => zaccel_sel,
   freq_sel => zafreq_sel,
   dist_sel => zdist_sel,
   dist_ctr => zDistCtr_reg,
   velocity => zvelocity_reg,
   nxt => znxt_reg,
   acl_stps => zaclStps_reg,
   dist_zero => zDistZero,
   stepOut => zstep,
   info => zInfo
   );

 -- z run control

 z_run: ZRun
  port map (
   clk => clk1,
   rst => zReset,
   start => zStart,
   backlash => zBackl,
   sync => zSync,
   wait_syn => zWaitSync,
   dist_zero => zDistZero,
   load_parm => zLoadParm,
   upd_loc => zRunUpdLoc,
   running => zRunning,
   run_sync => zrunSync,
   done_int => zDoneInt,
   info => zRunInfo
   );

 -- z output step data selector

 --zLocSrc <= '1' when ((tEna = '1') and (tZ = '1')) else '0';

 --zOutSource: DataSel1_2
 -- port map(
 --  sel => zLocSrc,
 --  d0 => zStep,
 --  d1 => tStep,
 --  dout => zStepOut 
 --  );

 zLocSrc <= "00" when (tena = '0') and (zSrcSyn = '0') else
            "01" when (tena = '0') and (zSrcSyn = '1') else
            "10" when (tena = '1') and (tz = '1') else
            "11";
 
 zOutSource: DataSel1_4
  port map(
   sel => zLocSrc,
   d0 => zStep,
   d1 => zSyncStep,
   d2 => tStep,
   d3 => '0',
   dout => zStepOut 
   );
 
 -- z location

 zLocSel <= '1' when (op = XLDZLOC) else '0';
 zUpdLoc <= '1' when ((zRunUpdLoc = '1') or
                      ((tEna = '1') and (tZ = '1'))) else '0';

 z_loc : LocCounter
  generic map (loc_bits)  
  port map (
   clk => clk1,
   step => zstep,
   dir => zDirIn,
   upd_loc => zUpdLoc,
   din => din,
   dshift => dshift,
   load => zSetLoc,
   loc_sel => zLocSel,
   loc => zLoc
   );

 -- z pulse out

 zPulseOut: PulseGen
  port map (
   clk => clk1,
   step_in => zStepOut,
   step_out => zStepPulse);

 zStepPulseOut <= zStepPulse xor zStepPol;
 zDirOut <= zDirIn xor zDirPol;

-- x frequency generator

 xFreqSel <= '1' when (op = XLDXFREQ) else '0';
 xFreqEna <= '1' when ((xRunning = '1') and (xSrcSyn = '0')) else '0';

 xFreqGen: FreqGen
  generic map(freq_bits)
  port map(
   clk => clk1,
   ena => xFreqEna,
   din => din,
   dshift => dshift,
   freq_sel => xFreqSel,
   pulse_out => xFreqStep 
   );

 -- x step data selector

 xStepSoure: DataSel1_2
  port map(
   sel => xSrcSyn,
   d0 => xFreqStep,
   d1 => zSyncStep,
   dout =>xAxisStep 
   );
 
 -- x acceleration

 xminv_sel <= '1' when (op = XLDXMINV) else '0';
 xmaxv_sel <= '1' when (op = XLDXMAXV) else '0';
 xaccel_sel <= '1' when (op = XLDXACCL) else '0';
 xafreq_sel <= '1' when (op = XLDXAFRQ) else '0';
 xdist_sel <= '1' when (op = XLDXDIST) else '0';

 x_move: AxisMove
  generic map (accel_bits,dist_bits)
  port map (
   clk => clk1,
   ena => xRunning,
   step => xAxisStep,
   rst => xLoadParm,
   din => din,
   dshift => dshift,
   minv_sel => xminv_sel,
   maxv_sel => xmaxv_sel,
   accel_sel => xaccel_sel,
   freq_sel => xafreq_sel,
   dist_sel => xdist_sel,
   dist_ctr => xDistCtr_reg,
   velocity => xvelocity_reg,
   nxt => xnxt_reg,
   acl_stps => xaclStps_reg,
   dist_zero => xDistZero,
   stepOut => xStep,
   info => xInfo
   );

 -- x run control

 x_Run: XRun port map(
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

 xLocSrc <= '1' when ((tEna = '1') and (tZ = '0')) else '0';

 xOutSource: DataSel1_2
  port map(
   sel => xLocSrc,
   d0 => xStep,
   d1 => tStep,
   dout => xStepOut 
   );
 
 -- x location

 xLocSel <= '1' when (op = XLDXLOC) else '0';
 xUpdLoc <= '1' when ((xRunUpdLoc = '1') or
                      ((tEna = '1') and (tZ = '0'))) else '0';

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

 xPulseOut: PulseGen
  port map (
   clk => clk1,
   step_in => xStepOut,
   step_out => xStepPulse);

 xStepPulseOut <= xStepPulse xor xStepPol;
 xDirOut <= xDirIn xor XDirPol;

 -- taper step source

 taperSourceSel <= dbgMove & tz;

 taperSource: DataSel1_4
  port map(
   sel => taperSourceSel,
   d0 => xAxisStep,
   d1 => zAxisStep,
   d2 => dbgPulse,
   d3 => dbgPulse,
   dout => taperStepIn
   );

 -- taper generator

 td_sel <= '1' when (op = XLDTD) else '0';
 tincr1_sel <= '1' when (op = XLDTINCR1) else '0';
 tincr2_sel <= '1' when (op = XLDTINCR2) else '0';

 taperCtl: Taper
  generic map(syn_bits,pos_bits)
  port map(
   clk => clk1,
   init => tload,
   step => taperStepIn,
   din => din,
   dshift => dshift,
   d_sel => td_sel,
   incr1_sel => tincr1_sel,
   incr2_sel => tincr2_sel,
   xpos => txpos,
   ypos => typos,
   sum => tsum,
   stepOut => tStep
   );

 tstOut1: PulseGen
  port map (
   clk => clk1,
   step_in => ch,
   step_out => test1);

 tstOut2: PulseGen
  generic map (step_width => 50)
  port map (
   clk => clk1,
   step_in => multCh,
   step_out => test2);

end Behavioral;
