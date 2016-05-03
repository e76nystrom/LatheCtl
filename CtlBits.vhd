library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package CtlBits is

-- z control register

 constant zctl_size : integer := 9;
 signal zctlReg : unsigned(zctl_size-1 downto 0);
 alias zReset     : std_logic is zctlreg(0); -- x01 reset flag
 alias zStart     : std_logic is zctlreg(1); -- x02 start z
 alias zSrcSyn    : std_logic is zctlreg(2); -- x04 run z synchronized
 alias zDirIn     : std_logic is zctlreg(3); -- x08 move z in positive dir
 alias zDirPos    : std_logic is zctlreg(3); -- x08 move z in positive dir
 alias zSetLoc    : std_logic is zctlreg(4); -- x10 set z location
 alias zBacklash  : std_logic is zctlreg(5); -- x20 backlash move no pos upd
 alias zWaitSync  : std_logic is zctlreg(6); -- x40 wait for sync to start
 alias zPulsMult  : std_logic is zctlreg(7); -- x80 enable pulse multiplier
 alias zEncDir    : std_logic is zctlreg(8); -- x100 z direction from encoder

-- x control register

 constant xctl_size : integer := 6;
 signal xctlReg : unsigned(xctl_size-1 downto 0);
 alias xReset     : std_logic is xctlreg(0); -- x01 x reset
 alias xStart     : std_logic is xctlreg(1); -- x02 start x
 alias xSrcSyn    : std_logic is xctlreg(2); -- x04 run x synchronized
 alias xDirIn     : std_logic is xctlreg(3); -- x08 move x in positive dir
 alias xDirPos    : std_logic is xctlreg(3); -- x08 x positive direction
 alias xSetLoc    : std_logic is xctlreg(4); -- x10 set x location
 alias xBacklash  : std_logic is xctlreg(5); -- x20 x backlash move no pos upd

-- taper control register

 constant tctl_size : integer := 2;
 signal tctlReg : unsigned(tctl_size-1 downto 0);
 alias tEna       : std_logic is tctlreg(0); -- x01 taper enable
 alias tZ         : std_logic is tctlreg(1); -- x02 one for taper z

-- position control register

 constant pctl_size : integer := 3;
 signal pctlReg : unsigned(pctl_size-1 downto 0);
 alias pReset     : std_logic is pctlreg(0); -- x01 reset position
 alias pLimit     : std_logic is pctlreg(1); -- x02 set flag on limit reached
 alias pZero      : std_logic is pctlreg(2); -- x04 set flag on zero reached

-- configuration register

 constant cctl_size : integer := 5;
 signal cctlReg : unsigned(cctl_size-1 downto 0);
 alias zStepPol   : std_logic is cctlreg(0); -- x01 z step pulse polarity
 alias zDirPol    : std_logic is cctlreg(1); -- x02 z direction polarity
 alias xStepPol   : std_logic is cctlreg(2); -- x04 x step pulse polarity
 alias xDirPol    : std_logic is cctlreg(3); -- x08 x direction polarity
 alias encPol     : std_logic is cctlreg(4); -- x10 encoder dir polarity

-- debug control register

 constant dctl_size : integer := 7;
 signal dctlReg : unsigned(dctl_size-1 downto 0);
 alias DbgEna     : std_logic is dctlreg(0); -- x01 enable debugging
 alias DbgSel     : std_logic is dctlreg(1); -- x02 select dbg encoder
 alias DbgDir     : std_logic is dctlreg(2); -- x04 debug direction
 alias DbgCount   : std_logic is dctlreg(3); -- x08 gen count num dbg clks
 alias DbgInit    : std_logic is dctlreg(4); -- x10 init z modules
 alias DbgRsyn    : std_logic is dctlreg(5); -- x20 running in sync mode
 alias DbgMove    : std_logic is dctlreg(6); -- x40 used debug clock for move

end CtlBits;

package body CtlBits is

end CtlBits;
