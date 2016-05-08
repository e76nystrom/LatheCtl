library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package CtlBits is

-- z control register

 constant zCtl_size : integer := 9;
 signal zCtlReg : unsigned(zCtl_size-1 downto 0);
 alias zReset     : std_logic is zCtlreg(0); -- x01 reset flag
 alias zStart     : std_logic is zCtlreg(1); -- x02 start z
 alias zSrcSyn    : std_logic is zCtlreg(2); -- x04 run z synchronized
 alias zDirIn     : std_logic is zCtlreg(3); -- x08 move z in positive dir
 alias zDirPos    : std_logic is zCtlreg(3); -- x08 move z in positive dir
 alias zSetLoc    : std_logic is zCtlreg(4); -- x10 set z location
 alias zBacklash  : std_logic is zCtlreg(5); -- x20 backlash move no pos upd
 alias zWaitSync  : std_logic is zCtlreg(6); -- x40 wait for sync to start
 alias zPulsMult  : std_logic is zCtlreg(7); -- x80 enable pulse multiplier
 alias zEncDir    : std_logic is zCtlreg(8); -- x100 z direction from encoder

-- x control register

 constant xCtl_size : integer := 6;
 signal xCtlReg : unsigned(xCtl_size-1 downto 0);
 alias xReset     : std_logic is xCtlreg(0); -- x01 x reset
 alias xStart     : std_logic is xCtlreg(1); -- x02 start x
 alias xSrcSyn    : std_logic is xCtlreg(2); -- x04 run x synchronized
 alias xDirIn     : std_logic is xCtlreg(3); -- x08 move x in positive dir
 alias xDirPos    : std_logic is xCtlreg(3); -- x08 x positive direction
 alias xSetLoc    : std_logic is xCtlreg(4); -- x10 set x location
 alias xBacklash  : std_logic is xCtlreg(5); -- x20 x backlash move no pos upd

-- taper control register

 constant tCtl_size : integer := 2;
 signal tCtlReg : unsigned(tCtl_size-1 downto 0);
 alias tEna       : std_logic is tCtlreg(0); -- x01 taper enable
 alias tZ         : std_logic is tCtlreg(1); -- x02 one for taper z

-- position control register

 constant pCtl_size : integer := 3;
 signal pCtlReg : unsigned(pCtl_size-1 downto 0);
 alias pReset     : std_logic is pCtlreg(0); -- x01 reset position
 alias pLimit     : std_logic is pCtlreg(1); -- x02 set flag on limit reached
 alias pZero      : std_logic is pCtlreg(2); -- x04 set flag on zero reached

-- configuration register

 constant cCtl_size : integer := 5;
 signal cCtlReg : unsigned(cCtl_size-1 downto 0);
 alias zStepPol   : std_logic is cCtlreg(0); -- x01 z step pulse polarity
 alias zDirPol    : std_logic is cCtlreg(1); -- x02 z direction polarity
 alias xStepPol   : std_logic is cCtlreg(2); -- x04 x step pulse polarity
 alias xDirPol    : std_logic is cCtlreg(3); -- x08 x direction polarity
 alias encPol     : std_logic is cCtlreg(4); -- x10 encoder dir polarity

-- debug control register

 constant dCtl_size : integer := 7;
 signal dCtlReg : unsigned(dCtl_size-1 downto 0);
 alias DbgEna     : std_logic is dCtlreg(0); -- x01 enable debugging
 alias DbgSel     : std_logic is dCtlreg(1); -- x02 select dbg encoder
 alias DbgDir     : std_logic is dCtlreg(2); -- x04 debug direction
 alias DbgCount   : std_logic is dCtlreg(3); -- x08 gen count num dbg clks
 alias DbgInit    : std_logic is dCtlreg(4); -- x10 init z modules
 alias DbgRsyn    : std_logic is dCtlreg(5); -- x20 running in sync mode
 alias DbgMove    : std_logic is dCtlreg(6); -- x40 used debug clock for move

-- status register

 constant stat_size : integer := 7;
 signal statReg : unsigned(stat_size-1 downto 0);
 alias sZDoneInt  : std_logic is statreg(0); -- x01 z done interrrupt
 alias sXDoneInt  : std_logic is statreg(1); -- x02 x done interrupt
 alias sDbgDone   : std_logic is statreg(2); -- x04 debug done
 alias sZStart    : std_logic is statreg(3); -- x08 z start
 alias sXStart    : std_logic is statreg(4); -- x10 x start
 alias sFreqReady : std_logic is statreg(5); -- x20 frequency reading ready
 alias sEncDirIn  : std_logic is statreg(6); -- x40 encoder direction in

end CtlBits;

package body CtlBits is

end CtlBits;
