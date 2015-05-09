import sys
import serial
from sys import stdout
from time import sleep
from math import floor,log

fData = False
jLoc = '../../Java/Lathe/src/lathe/'
cLoc = '../../Picc/Lathe.X/'
xLoc = '../../Xilinx/LatheCtl/'

cmdList = \
[\
 "feed table",

 ["LOADFEEDTBL","load value into pass table"],

  "z motion commands",

 ["CMDS","remaining do not take a value"],
 ["ZMOVE","start z movement"],
 ["ZSTOP","stop z movement"],
 ["ZHOME","set current z location as home"],
 ["ZSETLOC",""],
 ["ZGOHOME","z go to home position"],

  "x motion commands",

 ["XMOVE","start x movement"],
 ["XSTOP","stop x movement"],
 ["XHOME","set current x location as home"],
 ["XSETLOC",""],
 ["XGOHOME","x go to home position"],

  "start operations",

 ["CMDTURN","start turn operation"],
 ["CMDFACE","start face operation"],
 ["CMDTAPER","start taper operation"],
 ["CMDARC","start arc operation"],
 ["CMDTHREAD","start threading operation"],

  "end operations",

 ["CMDPAUSE","pause current operation"],
 ["CMDRESUME","resume current operation"],
 ["CMDSTOP","stop current operation"],

  "load operation parameters",

 ["LOADZPRM","call load xilinx z parameters"],
 ["LOADXPRM","call load xilinx x parameters"],
 ["LOADSPRM","call load xilinx sync parameters"],
 ["LOADTPRM","call load xilinx taper parameters"],

  "read feed table",

 ["READFEEDTBL","read from feed table"],

  "state information",

 ["READSTAT","read status"],
 ["READISTATE","read states of state machines"],

  "load processor and xilinx parameters",

 ["LOADVAL","load parameters"],
 ["LOADXREG","load xilinx registers"],
 ["READVAL","read parameters"],
 ["READXREG","read xilinx registers"],

  "location and debug info",

 ["READLOC","read location"],
 ["READDBG","read debug message"]
]

if fData:
    cFile = open(cLoc + 'cmdList.h','w')
    cFile.write("enum COMMANDS\n{\n");
    jFile = open(jLoc + 'Cmd.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public enum Cmd\n{\n");
cmds = {}
val = 0
for i in range(0,len(cmdList)):
    data = cmdList[i]
    if not isinstance(data,basestring):
        if (len(data) != 0):
            regName = data[0]
            regComment = data[1]
            if fData:
                tmp = " %s," % (regName)
                cFile.write("%s/* 0x%02x %s */\n" % 
                            (tmp.ljust(32),val,regComment))
                jFile.write("%s/* 0x%02x %s */\n" % 
                            (tmp.ljust(32),val,regComment))
            cmds[regName] = val
            val += 1
    else:
        if fData:
            if (len(data) > 0):
                cFile.write("\n// %s\n\n" % (data))
                jFile.write("\n// %s\n\n" % (data))
            else:
                cFile.write("\n")
                jFile.write("\n")
if fData:
    cFile.write("};\n")
    cFile.close()
    jFile.write("};\n")
    jFile.close()

#for key in cmds:
#    print key,cmds[key]

parmList = \
[\
 "phase parameters",

 ["PRMPHASE","encoder counts per rev","int16_t","SYNCHG"],

  "z synchronized motion parameters",

 ["PRMSDX","synchronized dx","int32_t","SYNCHG"],
 ["PRMSDYINI","synchronized initial dy","int32_t","SYNCHG"],
 ["PRMSDY","synchronized final dy","int32_t","SYNCHG"],
 ["PRMSD","synchronized d","int32_t"],
 ["PRMSINCR1","synchronized incr1","int32_t"],
 ["PRMSINCR2","synchronized incr2","int32_t"],
 ["PRMSACCEL","synchronized accel rate","int16_t","SYNCHG"],
 ["PRMSACLCLKS","synchronized accel clocks","int32_t","SYNCHG"],

  "taper parameters",

 ["PRMTDX","taper dx","int32_t","TAPCHG"],
 ["PRMTDY","taper dy","int32_t","TAPCHG"],
 ["PRMTD","taper d","int32_t"],
 ["PRMTINCR1","taper incr1","int32_t"],
 ["PRMTINCR2","taper incr2","int32_t"],

  "z move and location",

 ["PRMZLOCIN","received z location","int32_t"],
 ["PRMZDISTIN","received z distance to move","int32_t"],
 ["PRMZDIST","z move distance","int32_t"],
 ["PRMZLOC","z location","int32_t"],
 ["PRMZSTART","z start","int32_t"],
 ["PRMZEND","z end","int32_t"],
 ["PRMZCUR","z current location","int32_t"],
 ["PRMZREF","z reference","int32_t"],
 ["PRMZTOTFEED","z total feed","int32_t"],
 ["PRMZFEED","z feed per pass","int32_t"],
 ["PRMZRETRACT","z retract value","int32_t"],
 ["PRMZRTCLOC","z retract location","int32_t"],

  "z unsynchronized motion",

 ["PRMZFREQ","z frequency count","int32_t","ZMVCHG"],
 ["PRMZDX","z move dx value","int32_t","ZMVCHG"],
 ["PRMZD","z move d value","int32_t"],
 ["PRMZINCR1","z move incr1 value","int32_t"],
 ["PRMZINCR2","z move incr2 value","int32_t"],
 ["PRMZDYINI","z move initial dy value","int32_t","ZMVCHG"],
 ["PRMZDYJOG","z move jog dy value","int32_t"],
 ["PRMZDYMAX","z move max dy value","int32_t"],
 ["PRMZACCEL","z move accel rate","int32_t","ZMVCHG"],
 ["PRMZACLJOG","z move jog accel clocks","int32_t","ZMVCHG"],
 ["PRMZACLMAX","z move max accel clocks","int32_t","ZMVCHG"],
 ["PRMZBACKLASH","z backlash","int32_t"],
 ["PRMZCTLREG","z control register","uint16_t"],

  "x move and location",

 ["PRMXLOCIN","received x location","int32_t"],
 ["PRMXDISTIN","received x distance to move","int32_t"],
 ["PRMXDIST","x move distance","int32_t"],
 ["PRMXLOC","x location","int32_t"],
 ["PRMXSTART","x start","int32_t"],
 ["PRMXEND","x end","int32_t"],
 ["PRMXCUR","x current location","int32_t"],
 ["PRMXREF","x reference","int32_t"],
 ["PRMXTOTFEED","x total feed","int32_t"],
 ["PRMXFEED","x feed per pass","int32_t"],
 ["PRMXRETRACT","x retract value","int32_t"],
 ["PRMXRTCLOC","x retract location","int32_t"],

  "x unsynchronized motion",

 ["PRMXFREQ","x frequency count","int32_t","XMVCHG"],
 ["PRMXDX","x move dx value","int32_t","XMVCHG"],
 ["PRMXDYINI","x move initial dy value","int32_t","XMVCHG"],
 ["PRMXD","x move d value","int32_t"],
 ["PRMXINCR1","x move incr1 value","int32_t"],
 ["PRMXINCR2","x move incr2 value","int32_t"],
 ["PRMXDYJOG","x move jog dy value","int32_t"],
 ["PRMXDYMAX","x move max dy value","int32_t"],
 ["PRMXACCEL","x move accel rate","int32_t","XMVCHG"],
 ["PRMXACLJOG","x move jog accel clocks","int32_t","XMVCHG"],
 ["PRMXACLMAX","x move max accel clocks","int32_t","XMVCHG"],
 ["PRMXBACKLASH","x backlash","int32_t"],
 ["PRMXCTLREG","x control register","uint16_t"],

  "threading",

 ["PRMTHTAN","tangent of thread angle","int32_t"],
 ["PRMTHFEED","threading feed","int16_t"],
 ["PRMTHZOFFSET","threading z offset","int16_t"],

  "feed index",

 ["PRMFEEDIDX","threading feed table index","int16_t"],

  "pass count parameters",

 ["PRMPASSES","total number of passes","int16_t"],
 ["PRMSPASSINT","spring pass interval","int16_t"],
 ["PRMSPASSES","number of spring passes","int16_t"],

  "pass counters",

 ["PRMPASS","current pass","int16_t"],
 ["PRMSPASSCTR","spring pass counter","int16_t"],
 ["PRMSPRING","current spring pass","int16_t"],

  "feed direction",

 ["PRMFEEDDIR","feed direction","char"],
 ["PRMFEEDLIMIT","feed limit","char"],

  "control registers",

 ["PRMTRNCTL","turn control register","int16_t"],
 ["PRMTAPERCTLF","taper control register","int16_t"],
 ["PRMTHREADCTL","thread control register","int16_t"],

  "state variables",

 ["PRMZSTATE","z state","char"],
 ["PRMXSTATE","x state","char"],
 ["PRMTSTATE","turn state","char"],
 ["PRMFSTATE","face state","char"],

  "debug registers",

 ["PRMDBGREG","debug register","int16_t"],

  "limit registers",

 ["PRMZLIM","","int32_t"],
 ["PRMPSTATE","","int32_t"],
]

if fData:
    cFile = open(cLoc + 'parmList.h','w')
    cFile.write("enum PARM\n{\n")
    c1File = open(cLoc + 'remparm.h','w')
    c1File.write("T_PARM remparm[] =\n{\n")
    c2File = open(cLoc + 'remvardef.h','w')
    jFile = open(jLoc + 'Parm.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public enum Parm\n{\n")
parms = {}
val = 0
for i in range(0,len(parmList)):
    data = parmList[i]
    if not isinstance(data,basestring):
        regName = data[0]
        varName = regName[3:].lower()
        regComment = data[1]
        varType = data[2]
        regAct = '0';
        if (len(data) >= 4):
            regAct = data[3]
        if fData:
            tmp = " %s," % (regName)
            cFile.write("%s/* 0x%02x %s */\n" % 
                        (tmp.ljust(32),val,regComment))
            tmp = " PARM(%s,%s)," % (varName,regAct)
            c1File.write("%s/* 0x%02x %s */\n" % 
                         (tmp.ljust(32),val,regComment))
            tmp = " EXT %s %s;" % (varType,varName)
            c2File.write("%s/* 0x%02x %s */\n" % 
                         (tmp.ljust(32),val,regComment))
            tmp = "  %s," % (regName)
            jFile.write("%s/* 0x%02x %s */\n" % 
                        (tmp.ljust(32),val,regComment))
        parms[regName] = val
        val += 1
    else:
        if fData:
            cFile.write("\n// %s\n\n" % (data))
            c1File.write("\n// %s\n\n" % (data))
            c2File.write("\n// %s\n\n" % (data))
            jFile.write("\n// %s\n\n" % (data))
if fData:
    cFile.write("};\n")
    cFile.close()
    c1File.write("};\n")
    c1File.close()
    c2File.close()
    jFile.write("};\n")
    jFile.close()

#for key in parms:
#    print key,parms[key]

#enum XILINX
xilinxList = \
[ \
  "load control registers",

 ["XLDZCTL","z control register"],
 ["XLDXCTL","x control register"],
 ["XLDTCTL","load taper control"],
 ["XLDPCTL","position control"],
 ["XLDCFG","configuration"],
 ["XLDDCTL","load debug control"],
 ["XLDDREG","load display reg"],
 ["XREADREG","read register"],

  "phase counter",

 ["XLDPHASE","load phase max"],

  "load z motion",

 ["XLDZFREQ","load z frequency"],
 ["XLDZD","load z initial d"],
 ["XLDZINCR1","load z incr1"],
 ["XLDZINCR2","load z incr2"],
 ["XLDZACCEL","load z syn accel"],
 ["XLDZACLCNT","load z syn acl cnt"],
 ["XLDZDIST","load z distance"],
 ["XLDZLOC","load z location"],

  "load x motion",

 ["XLDXFREQ","load x frequency"],
 ["XLDXD","load x initial d"],
 ["XLDXINCR1","load x incr1"],
 ["XLDXINCR2","load x incr2"],
 ["XLDXACCEL","load x syn accel"],
 ["XLDXACLCNT","load x syn acl cnt"],
 ["XLDXDIST","load x distance"],
 ["XLDXLOC","load x location"],

  "read z motion",

 ["XRDZSUM","read z sync sum"],
 ["XRDZXPOS","read z sync x pos"],
 ["XRDZYPOS","read z sync y pos"],
 ["XRDZACLSUM","read z acl sum"],
 ["XRDZASTP","read z acl stps"],

  "read x motion",

 ["XRDXSUM","read x sync sum"],
 ["XRDXXPOS","read x sync x pos"],
 ["XRDXYPOS","read x sync y pos"],
 ["XRDXACLSUM","read x acl sum"],
 ["XRDXASTP","read z acl stps"],

  "read distance",

 ["XRDZDIST","read z distance"],
 ["XRDXDIST","read x distance"],

  "read location",

 ["XRDZLOC","read z location"],
 ["XRDXLOC","read x location"],

  "read frequency and state",

 ["XRDFREQ","read encoder freq"],
 ["XRDSTATE","read state info"],

  "read phase",

 ["XRDPSYN","read sync phase val"],
 ["XRDTPHS","read tot phase val"],

  "phase limit info",

 ["XLDZLIM","load z limit"],
 ["XRDZPOS","read z position"],

  "test info",

 ["XLDTFREQ","load test freq"],
 ["XLDTCOUNT","load test count"]
]

if fData:
    cFile = open(cLoc + 'xilinxreg.h','w')
    cFile.write("enum XILINX\n{\n");
    jFile = open(jLoc + 'Xilinx.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public enum Xilinx\n {\n");
    j1File = open(jLoc + 'XilinxStr.java','w')
    j1File.write("package lathe;\n\n");
    j1File.write("public class XilinxStr\n{\n");
    j1File.write(" public static final String[] xilinxStr =\n {\n");
    xFile = open(xLoc + 'RegDef.vhd','w')
    xFile.write("library IEEE;\n")
    xFile.write("use IEEE.STD_LOGIC_1164.all;\n")
    xFile.write("use IEEE.NUMERIC_STD.ALL;\n\n")
    xFile.write("package RegDef is\n\n")
    xFile.write("constant opb : positive := 8;\n\n")
xRegs = {}
val = 0
for i in range(0,len(xilinxList)):
    data = xilinxList[i]
    if not isinstance(data,basestring):
        regName = data[0]
        regComment = data[1]
        if fData:
            tmp = " %s," % (regName)
            cFile.write("%s/* 0x%02x %s */\n" % 
                        (tmp.ljust(32),val,regComment));
            tmp = "  %s," % (regName)
            jFile.write("%s/* 0x%02x %s */\n" % 
                        (tmp.ljust(32),val,regComment));
            tmp = "  \"%s\"," % (regName)
            j1File.write("%s/* 0x%02x %s */\n" % 
                        (tmp.ljust(32),val,regComment));
            xFile.write(('constant %-12s : unsigned(opb-1 downto 0) ' +
                         ':= x"%02x"; --%s\n') %
                        (regName,val,regComment))
        xRegs[regName] = val
        val += 1
    else:
        if fData:
            if (len(data) > 0):
                cFile.write("\n// %s\n\n" % (data))
                jFile.write("\n// %s\n\n" % (data))
                xFile.write("\n-- %s\n\n" % (data))
            else:
                cFile.write("\n");
                jFile.write("\n");
                xFile.write("\n");
if fData:
    cFile.write("};\n")
    cFile.close()
    jFile.write("};\n")
    jFile.close()
    j1File.write(" };\n\n};\n")
    jFile.close()
    xFile.write("\nend RegDef;\n\n")
    xFile.write("package body RegDef is\n\n")
    xFile.write("end RegDef;\n")
    xFile.close()

# for key in xRegs:
#     print "%-12s %02x" % (key,xRegs[key])

bitList =\
[\
 "z control register",

 ["zctl"],
 ["zReset",     1,0,"reset flag"],
 ["zStart",     1,1,"start z"],
 ["zSrc_Syn",   1,2,"run z synchronized"],
 ["zSrc_Frq",   0,2,"run z from clock source"],
 ["zDir_In",    1,3,"move z in positive dir"],
 ["zDir_Pos",   1,3,"move z in positive dir"],
 ["zDir_Neg",   0,3,"move z in negative dir"],
 ["zSet_Loc",   1,4,"set z location"],
 ["zBacklash",  1,5,"backlash move no pos upd"],
 ["zWait_Sync", 1,6,"wait for sync to start"],
 ["zPuls_Mult", 1,7,"enable pulse multiplier"],
 ["zEnc_Dir",   1,8,"z direction from encoder"],

 "x control register",

 ["xctl"],
 ["xReset",     1,0,"x reset"],
 ["xStart",     1,1,"start x"],
 ["xSrc_Syn",   1,2,"run x synchronized"],
 ["xSrc_Frq",   0,2,"run x from clock source"],
 ["xDir_In",    1,3,"move x in positive dir"],
 ["xDir_Pos",   1,3,"x positive direction"],
 ["xDir_Neg",   0,3,"x negative direction"],
 ["xSet_Loc",   1,4,"set x location"],
 ["xBacklash",  1,5,"x backlash move no pos upd"],

 "taper control register",

 ["tctl"],
 ["tEna",    1,0,"taper enable"],
 ["tZ",      1,1,"one for taper z"],
 ["tX",      0,1,"zero for taper x"],

 "position control register",

 ["pctl"],
 ["pReset",   1,0,"reset position"],
 ["pLimit",   1,1,"set flag on limit reached"],
 ["pZero",    1,2,"set flag on zero reached"],

 "configuration register",

 ["cctl"],
 ["zStep_Pol", 1,0,"z step pulse polarity"],
 ["zDir_Pol",  1,1,"z direction polarity"],
 ["xStep_Pol", 1,2,"x step pulse polarity"],
 ["xDir_Pol",  1,3,"x direction polarity"],
 ["enc_Pol",   1,4,"encoder dir polarity"],

 "debug control register",

 ["dctl"],
 ["Dbg_Ena",   1,0,"enable debugging"],
 ["Dbg_Dir",   1,1,"debug direction"],
 ["Dbg_Count", 1,2,"gen count num dbg clks"],
 ["Dbg_Init",  1,3,"init z modules"],
 ["Dbg_Rsyn",  1,4,"running in sync mode"],
 ["Dbg_Move",  1,5,"used debug clock for move"],

 ""
]

if fData:
    cFile = open(cLoc + 'xilinxbits.h','w')
    jFile = open(jLoc + 'XilinxBits.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public class XilinxBits\n{\n");
    xFile = open(xLoc + 'CtlBits.vhd','w')
    xFile.write("library IEEE;\n")
    xFile.write("use IEEE.STD_LOGIC_1164.all;\n")
    xFile.write("use IEEE.NUMERIC_STD.ALL;\n\n")
    xFile.write("package CtlBits is\n")
regName = ""
bitStr = []
lastShift = -1
for i in range(0,len(bitList)):
    data = bitList[i]
    if not isinstance(data,basestring):
        if len(data) == 1:
            xLst = []
            regName = data[0]
            maxShift = 0
        else:
            var = data[0]
            cVar = var.upper()
            xVar = var.replace("_","")
            bit = data[1]
            shift = data[2]
            comment = data[3]

            if fData:
                tmp =  "#define %-12s  (%s << %s)" % (cVar,bit,shift)
                cFile.write("%s/* %s */\n" % 
                            (tmp.ljust(32),comment));
                tmp =  (" public static final int %-10s = (%s << %s);" %
                        (cVar,bit,shift))
                jFile.write("%s /* %s */\n" % 
                            (tmp,comment));
                if bit != 0:
                    if (shift != lastShift):
                        tmp =  "  \"%s\"," % (cVar)
                        bitStr.append("%s/* 0x%02x %s */\n"
                                      % (tmp.ljust(32),bit << shift,comment))
                    xLst.append((" alias %-10s : std_logic is %sreg(%d); " +
                                 "-- %s\n") %
                                (xVar,regName,shift,comment))
                    if (shift > maxShift):
                        maxShift = shift
            globals()[cVar] = bit << shift
            lastShift = shift
    else:
        if fData:
            if (len(regName) > 0):
                xFile.write(" constant %s_size : integer := %d;\n" %
                            (regName,maxShift + 1))
                xFile.write(" signal %sReg : unsigned(%s_size-1 downto 0);\n" %
                            (regName,regName))
                for i in range(0,len(xLst)):
                    xFile.write(xLst[i])
                if (len(bitStr) != 0):
                    jFile.write(("\n public static final " +
                                "String[] %sBits =\n {\n") % (regName))
                    for i in range(0,len(bitStr)):
                        jFile.write(bitStr[i])
                    jFile.write(" };\n");
                    bitStr = []
            if (len(data) != 0):
                cFile.write("\n// %s\n\n" % (data))
                jFile.write("\n// %s\n\n" % (data))
                xFile.write("\n-- %s\n\n" % (data))
if fData:
    cFile.close()
    jFile.write("};\n")
    jFile.close()
    xFile.write("\nend CtlBits;\n\n")
    xFile.write("package body CtlBits is\n\n")
    xFile.write("end CtlBits;\n")
    xFile.close()

stateList =\
[\
 "z control states",

 "enum zStates",
 "{",
 ["ZIDLE","idle"],
 ["ZWAITBKLS","wait for backlash move complete"],
 ["ZSTARTMOVE","start z move"],
 ["ZWAITMOVE","wait for move complete"],
 ["ZDONE","clean up state"],
 "};",

 "x control states",

 "enum xStates",
 "{",
 ["XIDLE","idle"],
 ["XWAITBKLS","wait for backlash move complete"],
 ["XSTARTMOVE","start x move"],
 ["XWAITMOVE","wait for move complete"],
 ["XDONE","clean up state"],
 "};",

 "turn control states",

 "enum tStates",
 "{",
 ["TIDLE","idle"],
 ["TCKRTC","check for x retracted"],
 ["TWTRTC0","wait for x to retract"],
 ["TCKSTR","check for at start position"],
 ["TWSTART","wait for start position"],
 ["TFEED","feed x in"],
 ["TWTFEED","wait for x feed to complete"],
 ["TTURN","set up turn move"],
 ["TWTTURN","perform turn operation"],
 ["TRTC","retract x after turn"],
 ["TWTRTC1","wait for x retract to complete"],
 ["TRTN","return to start position"],
 ["TWTRTN","wait for return to start"],
 ["TUPDPASS","update pass"],
 ["TUPDSPRING","update spring pass"],
 ["TDONE","clean up state"],
 "};",

 "facing control states",

 "enum fStates",
 "{",
 ["FIDLE","idle"],
 ["FCKRTC","check for z retracted"],
 ["FWTRTC0","wait for z to retract"],
 ["FCKSTR","check for x at start position"],
 ["FWSTART","wait for x start position"],
 ["FFEED","feed z in"],
 ["FWTFEED","wait for z feed to complete"],
 ["FFACE","set up facing move"],
 ["FWTFACE","perform facing operation"],
 ["FRTC","retract z after facing"],
 ["FWTRTC1","wait for z retract to complete"],
 ["FRTN","return to start position"],
 ["FWTRTN","wait for return to start"],
 ["FUPDPASS","update pass"],
 ["FUPDSPRING","update spring pass"],
 ["FDONE","clean up state"],
 "};"
]

if fData:
    cFile = open(cLoc + 'ctlstates.h','w')
    jFile = open(jLoc + 'CtlStates.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public class CtlStates\n{\n");
val = 0
for i in range(0,len(stateList)):
    data = stateList[i]
    if not isinstance(data,basestring):
        state = data[0]
        comment = data[1]
        if fData:
            tmp =  " %s," % (state)
            cFile.write("%s/* %2d %s */\n" % 
                        (tmp.ljust(32),val,comment));
            jFile.write('  "%-10s %s",\n' % (state,comment));
        val += 1
    else:
        if fData:
            if data.startswith("enum"):
                tmp = data.split()
                cFile.write("%s %s\n" % (tmp[0],tmp[1].upper()))
                tmp =  " public static final String[] %s = \n" % (tmp[1])
                jFile.write(tmp)
                val = 0
            elif data.startswith("{") or data.startswith("}"):
                cFile.write("%s\n" % (data))
                jFile.write(" %s\n" % (data))
            else:
                cFile.write("\n// %s\n\n" % (data))
                jFile.write("\n // %s\n\n" % (data))
if fData:
    cFile.close()
    jFile.write("};\n")
    jFile.close()

regList =\
[\
 "z move command bits",

 ["ZMSK","(3 << 0)","z move mask"],
 ["ZMOV","(1 << 0)","z a set distance"],
 ["ZJOG","(2 << 0)","z while cmd are present"],
 ["ZSYN","(3 << 0)","z dist sync to rotation"],
 ["ZPOS","(1 << 2)","z in positive direction"],
 ["ZNEG","(0 << 2)","z in negative direction"],

 "x move command bits",

 ["XMSK","(3 << 0)","xmove mask"],
 ["XMOV","(1 << 0)","x a set distance"],
 ["XJOG","(2 << 0)","x while cmd are present"],
 ["XSYN","(3 << 0)","x dist sync to rotation"],
 ["XPOS","(1 << 2)","x in positive direction"],
 ["XNEG","(0 << 2)","x in negative direction"],

 "turn control bits",

 ["TURNSYN","(1 << 0)","turn with sync motion"],
 ["TURNCONT","(1 << 1)","cont turning operation"],

 "taper control bits",

 ["TAPERX","(1 << 0)","taper x axis"],
 ["TAPERZ","(1 << 1)","taper z axis"],
 ["TAPEROUT","(1 << 2)","one taper out, zero in"],

 "thread control bits",

 ["THREAD","(1 << 0)","threading enabled"],
 ["TINTERNAL","(1 << 1)","internal threads"],

 "debug control bits",

 ["DBGPASS","(1 << 0)","pause before each pass"],
 ["DBGEND","(1 << 1)","pause at end of a pass"],
 ["DBGSEQ","(1 << 2)","generate sequence data"]
]

if fData:
    cFile = open(cLoc + 'ctlbits.h','w')
    jFile = open(jLoc + 'CtlBits.java','w')
    jFile.write("package lathe;\n\n");
    jFile.write("public class CtlBits\n{\n");
for i in range(0,len(regList)):
    data = regList[i]
    if not isinstance(data,basestring):
        var = data[0]
        val = data[1]
        comment = data[2]
        if fData:
            tmp =  "#define %-12s %s" % (var,val)
            cFile.write("%s /* %s */\n" % 
                        (tmp.ljust(32),comment));
            tmp =  " public static final int %-10s = %s;" % (var,val)
            jFile.write("%s /* %s */\n" % 
                        (tmp,comment));
        globals()[var] = eval(val)
    else:
        if fData:
            cFile.write("\n// %s\n\n" % (data))
            jFile.write("\n// %s\n\n" % (data))
if fData:
    cFile.close()
    jFile.write("};\n")
    jFile.close()

def setParm(parm,val):
    if ser is None:
        return
    cmd = '\x01%x %x %x ' % (cmds['LOADVAL'],parms[parm],val)
    ser.write(cmd)
    rsp = "";
    while True:
        tmp = ser.read(1)
        if (len(tmp) == 0):
            print "timeout"
            break;
        if (tmp == '*'):
            break
        rsp = rsp + tmp;

def getParm(parm):
    if ser is None:
        return
    cmd = '\x01%x %x ' % (cmds['READVAL'],parms[parm])
    ser.write(cmd)
    rsp = "";
    while True:
        tmp = ser.read(1)
        if (len(tmp) == 0):
            print "timeout"
            break;
        if (tmp == '*'):
            result = rsp.split()
            if (len(result) == 3):
                return(int(result[2],16))
        rsp = rsp + tmp;

def setXReg(reg,val,dbgprint=True):
    global ser
    if ser is None:
        return
    if not (reg in xRegs):
        print "invalid register " + reg
        return
    val = int(val)
    if dbgprint:
        print "%-12s %8x %12d" % (reg,val & 0xffffffff,val)
    cmd = '\x01%x %x %08x ' % (cmds['LOADXREG'],xRegs[reg],val & 0xffffffff)
    ser.write(cmd)
    rsp = "";
    while True:
        tmp = ser.read(1)
        if (len(tmp) == 0):
            print "timeout"
            break;
        if (tmp == '*'):
            break
        rsp = rsp + tmp;

def getXReg(reg):
    global ser
    if ser is None:
        return(0)
    if not (reg in xRegs):
        print "invalid register " + reg
        return(0);
    cmd = '\x01%x %x ' % (cmds['READXREG'],xRegs[reg])
    ser.write(cmd)
    rsp = "";
    while True:
        tmp = ser.read(1)
        if (len(tmp) == 0):
            print "timeout"
            break;
        if (tmp == '*'):
            result = rsp.split()
            if (len(result) == 3):
                val = int(result[2],16)
                if val & 0x80000000:
                    val = -((val ^ 0xffffffff) + 1)
                return(val)
        rsp = rsp + tmp;

def dspXReg(reg,label='',dbgprint=True):
    val = getXReg(reg)
    if dbgprint:
        print "%-12s %8x %12d %s" % (reg,val & 0xffffffff,val,label)
    return(val)

def command(cmd):
    global ser
    if ser is None:
        return("");
    cmd = '\x01%x ' % (cmds[cmd])
    ser.write(cmd)
    rsp = ""
    while True:
        tmp = ser.read(1)
        if (len(tmp) == 0):
            print "timeout"
            break
        if (tmp == '*'):
            break
        rsp = rsp + tmp;
    return(rsp.strip("\n\r"))

# z synchronized motion test without acceleration

def test1(runClocks,dist=100,dbgprint=True):
    if (runClocks == 0):
        runClocks = 1
    if (dist == 0):
        dist = 100

    dx = (2540 * 8)
    dy = 600

    incr1 = (2 * dy)
    incr2 = (2 * (dy - dx))
    d = (incr1 - dx)

    print "dx %d dy %d" % (dx,dy)
    print "incr1 %d incr2 %d\n" % (incr1,incr2)

    zSynAccel = 0
    zSynAclCnt = 0

    setXReg('XLDDCTL',0,dbgprint) # disable debug mode
    setXReg('XLDZCTL',0,dbgprint) # clear z mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDZCTL',0,dbgprint)

    setXReg('XLDDREG',0x1234,dbgprint)	# load display register

    setXReg('XLDPHASE',8192,dbgprint)   # load phase count

    setXReg('XLDZD',d,dbgprint)		# load d value
    setXReg('XLDZINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDZINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDZACCEL',zSynAccel,dbgprint)   # load z accel
    setXReg('XLDZACLCNT',zSynAclCnt,dbgprint) # load z accel count

    setXReg('XLDZDIST',dist,dbgprint) # load z distance
    setXReg('XLDZLOC',20,dbgprint)    # set location

    setXReg('XLDZCTL',ZRESET | ZSET_LOC,dbgprint) # reset z and load location
    setXReg('XLDZCTL',0,dbgprint)    # clear reset

    setXReg('XLDZCTL',ZSRC_SYN | ZDIR_POS,dbgprint)
    setXReg('XLDZCTL',ZSTART | ZSRC_SYN | ZDIR_POS,dbgprint)

    setXReg('XLDTFREQ',10000,dbgprint)	# load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    setXReg('XLDDCTL',DBG_INIT,dbgprint) # initialize z modules
    setXReg('XLDDCTL',0,dbgprint)        # clear

    setXReg('XLDDCTL',(DBG_ENA |           # enable debugging
                       DBG_COUNT |         # run for number in count
                       DBG_RSYN |          # enable sync
                       DBG_MOVE),dbgprint) # debug axis move

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    dspXReg('XREADREG',"freq",dbgprint)

    dspXReg('XRDFREQ',"freq",dbgprint)
    dspXReg('XRDPSYN',"phase syn",dbgprint)
    dspXReg('XRDTPHS',"tot phase",dbgprint)

    xPos = dspXReg('XRDZXPOS',"xpos",dbgprint)
    dspXReg('XRDZYPOS',"ypos",dbgprint)
    dspXReg('XRDZSUM',"sum",dbgprint)

    dspXReg('XRDZDIST',"dist",dbgprint)
    dspXReg('XRDZLOC',"loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)

    clocks = 0
    x = 0
    y = 0
    sum = d
    while (clocks < xPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2

    print "\nx %d y %d sum %d" % (x,y,sum)

# x synchronized motion test without acceleration

def test2(runClocks,dist=100,dbgprint=True):
    if (runClocks == 0):
        runClocks = 1
    if (dist == 0):
        dist = 100

    dx = (2540 * 8)
    dy = 600

    incr1 = (2 * dy)
    incr2 = (2 * (dy - dx))
    d = (incr1 - dx)

    print "dx %d dy %d" % (dx,dy)
    print "incr1 %d incr2 %d\n" % (incr1,incr2)

    xSynAccel = 0
    xSynAclCnt = 0

    setXReg('XLDDCTL',0,dbgprint) # disable debug mode
    setXReg('XLDXCTL',0,dbgprint) # clear x mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDXCTL',0,dbgprint)

    setXReg('XLDDREG',0x1234,dbgprint)	# load display register

    setXReg('XLDPHASE',8192,dbgprint)   # load phase count

    setXReg('XLDXD',d,dbgprint)		# load d value
    setXReg('XLDXINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDXINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDXACCEL',xSynAccel,dbgprint)   # load x accel
    setXReg('XLDXACLCNT',xSynAclCnt,dbgprint) # load x accel count

    setXReg('XLDXDIST',dist,dbgprint) # load x distance
    setXReg('XLDXLOC',1000,dbgprint)    # set location

    setXReg('XLDXCTL',XRESET | XSET_LOC,dbgprint) # reset x and load location
    setXReg('XLDXCTL',0,dbgprint)    # clear reset

    setXReg('XLDXCTL',XSRC_SYN | XDIR_POS,dbgprint)
    setXReg('XLDXCTL',XSTART | XSRC_SYN | XDIR_POS,dbgprint)

    setXReg('XLDTFREQ',10000,dbgprint)	# load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    setXReg('XLDDCTL',DBG_INIT,dbgprint) # initialize x modules
    setXReg('XLDDCTL',0,dbgprint)        # clear

    setXReg('XLDDCTL',(DBG_ENA |           # enable debugging
                       DBG_COUNT |         # run for number in count
                       DBG_RSYN |          # enable sync
                       DBG_MOVE),dbgprint) # debug axis move

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    dspXReg('XREADREG',"freq",dbgprint)

    dspXReg('XRDFREQ',"freq",dbgprint)
    dspXReg('XRDPSYN',"phase syn",dbgprint)
    dspXReg('XRDTPHS',"tot phase",dbgprint)

    xPos = dspXReg('XRDXXPOS',"xpos",dbgprint)
    dspXReg('XRDXYPOS',"ypos",dbgprint)
    dspXReg('XRDXSUM',"sum",dbgprint)

    dspXReg('XRDXDIST',"dist",dbgprint)
    dspXReg('XRDXLOC',"loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)

    clocks = 0
    x = 0
    y = 0
    sum = d
    while (clocks < xPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2

    print "\nx %d y %d sum %d" % (x,y,sum)

# taper x without acceleration

def test2a(runClocks,dist=100,dbgprint=True):
    if (runClocks == 0):
        runClocks = 1
    if (dist == 0):
        dist = 100

    dx = (2540 * 8)
    dy = 600

    incr1 = (2 * dy)
    incr2 = (2 * (dy - dx))
    d = (incr1 - dx)

    print "dx %d dy %d" % (dx,dy)
    print "incr1 %d incr2 %d\n" % (incr1,incr2)

    xSynAccel = 0
    xSynAclCnt = 0

    setXReg('XLDDCTL',0,dbgprint) # disable debug mode
    setXReg('XLDZCTL',0,dbgprint) # clear z mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDXCTL',0,dbgprint)

    setXReg('XLDDREG',0x1234,dbgprint)	# load display register

    setXReg('XLDPHASE',8192,dbgprint)   # load phase count

    setXReg('XLDZD',d,dbgprint)		# load d value
    setXReg('XLDZINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDZINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDZACCEL',xSynAccel,dbgprint)   # load z accel
    setXReg('XLDZACLCNT',xSynAclCnt,dbgprint) # load z accel count

    setXReg('XLDXD',d,dbgprint)		# load d value
    setXReg('XLDXINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDXINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDXACCEL',xSynAccel,dbgprint)   # load x accel
    setXReg('XLDXACLCNT',xSynAclCnt,dbgprint) # load x accel count

    setXReg('XLDTCTL',TENA,dbgprint) # set for taper x

    setXReg('XLDZDIST',dist,dbgprint) # load z distance
    setXReg('XLDZLOC',20,dbgprint)    # set location

    setXReg('XLDZCTL',ZRESET | ZSET_LOC,dbgprint) # reset z and load location
    setXReg('XLDZCTL',0,dbgprint)    # clear reset

    setXReg('XLDXLOC',100,dbgprint)    # set x location

    setXReg('XLDXCTL',XSET_LOC,dbgprint) # load x location
    setXReg('XLDXCTL',XDIR_POS,dbgprint) # clear load and set positive

    setXReg('XLDZCTL',ZSRC_SYN | ZDIR_POS,dbgprint)
    setXReg('XLDZCTL',ZSTART | ZSRC_SYN | ZDIR_POS,dbgprint)

    setXReg('XLDTFREQ',10000,dbgprint)	# load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    setXReg('XLDDCTL',DBG_INIT,dbgprint) # initialize x modules
    setXReg('XLDDCTL',0,dbgprint)        # clear

    setXReg('XLDDCTL',(DBG_ENA |           # enable debugging
                       DBG_COUNT |         # run for number in count
                       DBG_RSYN |          # enable sync
                       DBG_MOVE),dbgprint) # debug axis move

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    dspXReg('XREADREG',"freq",dbgprint)

    dspXReg('XRDFREQ',"freq",dbgprint)
    dspXReg('XRDPSYN',"phase syn",dbgprint)
    dspXReg('XRDTPHS',"tot phase",dbgprint)

    zXPos = dspXReg('XRDZXPOS',"z xpos",dbgprint)
    dspXReg('XRDZYPOS',"z ypos",dbgprint)
    dspXReg('XRDZSUM',"z sum",dbgprint)

    xXPos = dspXReg('XRDXXPOS',"x xpos",dbgprint)
    dspXReg('XRDXYPOS',"x ypos",dbgprint)
    dspXReg('XRDXSUM',"x sum",dbgprint)

    dspXReg('XRDZDIST',"z dist",dbgprint)
    dspXReg('XRDZLOC',"z loc",dbgprint)
    dspXReg('XRDXLOC',"x loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)
    setXReg('XLDZCTL',0,dbgprint)

    clocks = 0
    x = 0
    y = 0
    sum = d
    while (clocks < zXPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2

    print "\nx %d y %d sum %d" % (x,y,sum)

# taper z without acceleration

def test2b(runClocks,dist=100,dbgprint=True):
    if (runClocks == 0):
        runClocks = 1
    if (dist == 0):
        dist = 100

    dx = (2540 * 8)
    dy = 600

    incr1 = (2 * dy)
    incr2 = (2 * (dy - dx))
    d = (incr1 - dx)

    print "dx %d dy %d" % (dx,dy)
    print "incr1 %d incr2 %d\n" % (incr1,incr2)

    xSynAccel = 0
    xSynAclCnt = 0

    setXReg('XLDDCTL',0,dbgprint) # disable debug mode
    setXReg('XLDZCTL',0,dbgprint) # clear z mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDXCTL',0,dbgprint)

    setXReg('XLDDREG',xRegs['XRDZSUM'],dbgprint) # load display register

    setXReg('XLDPHASE',8192,dbgprint)   # load phase count

    setXReg('XLDXD',d,dbgprint)		# load d value
    setXReg('XLDXINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDXINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDXACCEL',xSynAccel,dbgprint)   # load x accel
    setXReg('XLDXACLCNT',xSynAclCnt,dbgprint) # load x accel count

    setXReg('XLDZD',d,dbgprint)		# load d value
    setXReg('XLDZINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDZINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDZACCEL',xSynAccel,dbgprint)   # load x accel
    setXReg('XLDZACLCNT',xSynAclCnt,dbgprint) # load x accel count

    setXReg('XLDTCTL',TENA | TZ,dbgprint) # set for taper z

    setXReg('XLDXDIST',dist,dbgprint) # load x distance
    setXReg('XLDXLOC',20,dbgprint)    # set location

    setXReg('XLDXCTL',XRESET | XSET_LOC,dbgprint) # reset x and load location
    setXReg('XLDXCTL',0,dbgprint)    # clear reset

    setXReg('XLDZLOC',100,dbgprint)    # set z location

    setXReg('XLDZCTL',ZSET_LOC,dbgprint) # load z location
    setXReg('XLDZCTL',ZDIR_POS,dbgprint) # clear load and set positive

    setXReg('XLDXCTL',XSRC_SYN | XDIR_POS,dbgprint)
    setXReg('XLDXCTL',XSTART | XSRC_SYN | XDIR_POS,dbgprint)

    setXReg('XLDTFREQ',10000,dbgprint)	# load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    setXReg('XLDDCTL',DBG_INIT,dbgprint) # initialize x modules
    setXReg('XLDDCTL',0,dbgprint)        # clear

    setXReg('XLDDCTL',(DBG_ENA |           # enable debugging
                       DBG_COUNT |         # run for number in count
                       DBG_RSYN |          # enable sync
                       DBG_MOVE),dbgprint) # debug axis move

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    dspXReg('XREADREG',"freq",dbgprint)

    dspXReg('XRDFREQ',"freq",dbgprint)
    dspXReg('XRDPSYN',"phase syn",dbgprint)
    dspXReg('XRDTPHS',"tot phase",dbgprint)

    xXPos = dspXReg('XRDXXPOS',"x xpos",dbgprint)
    dspXReg('XRDXYPOS',"x ypos",dbgprint)
    dspXReg('XRDXSUM',"x sum",dbgprint)

    zXPos = dspXReg('XRDZXPOS',"z xpos",dbgprint)
    dspXReg('XRDZYPOS',"z ypos",dbgprint)
    dspXReg('XRDZSUM',"z sum",dbgprint)

    dspXReg('XRDXDIST',"x dist",dbgprint)
    dspXReg('XRDXLOC',"x loc",dbgprint)
    dspXReg('XRDZLOC',"Z loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)

    clocks = 0
    x = 0
    y = 0
    sum = d
    while (clocks < xXPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2

    print "\nx %d y %d sum %d" % (x,y,sum)

# z unsynchronized move with acceleration

def testxx(runClocks=100,runSteps=0,dbgprint=True,dbg=False,pData=False):
    cFreq = 50000000            # clock frequency
    mult = 8                    # freq gen multiplier
    stepsRev = 1600             # steps per revolution
    pitch = .1                  # pitch
    scale = 1 << 6              # scale factor

    minFeed = 10                # min feed ipm
    maxFeed = 40                # max feed ipm
    accelRate = 4               # acceleration rate in per sec squared

    stepsInch = stepsRev / pitch # steps per inch
    stepsMinMax = maxFeed * stepsInch # max steps per min
    stepsSecMax = stepsMinMax / 60.0  # max steps per second
    freqGenMax = stepsSecMax * mult # frequency generator maximum
    print "stepsSecMax %6.0f freqGenMax %7.0f" % (stepsSecMax,freqGenMax)

    stepsMinMin = minFeed * stepsInch # max steps per min
    stepsSecMin = stepsMinMin / 60.0  # max steps per second
    freqGenMin = stepsSecMin * mult # frequency generator maximum
    print "stepsSecMin %6.0f freqGenMin %7.0f" % (stepsSecMin,freqGenMin)

    freqDivider = int(floor(cFreq / freqGenMax)) - 1 # calc divider
    print "freqDivider %3.0f" % freqDivider

    accelTime = maxFeed / (60.0 * accelRate) # acceleration time
    print "accelTime %8.6f" % (accelTime)

    accelRateSteps = stepsSecMax / accelTime # rate steps per sec sqr
    print "accelRateSteps %6.0f" % (accelRateSteps)

    accelSteps = accelTime * stepsSecMax # accel time in steps
    accelClocks = accelTime * freqGenMax # accel time in clocks
    print "accelSteps %3.0f accelClocks %6.0f" % (accelSteps,accelClocks)

    stepAreaClocks = accelClocks * freqGenMax / 2 # step area in clocks
    bits = int(floor(log(stepAreaClocks,2))) + 1
    print "stepAreaClocks %10.0f bits %2d" % (stepAreaClocks,bits)

    velPerClock = freqGenMax / accelClocks    # velocity per clock
    velPerClock *= scale
    areaPerStep = stepAreaClocks / accelSteps # accel area per step
    areaPerStep *= scale
    bits = int(floor(log(areaPerStep,2))) + 1
    print ("velPerClock %7.2f areaPerStep %10.0f bits %2d" %
           (velPerClock,areaPerStep,bits))

    finalVelocity = int(accelClocks) * int(velPerClock) # final velocity
    print "finalVelocity %d" % (finalVelocity)

    minVelocity = freqGenMin * scale;
    clocksMin = minVelocity / velPerClock
    minAreaClocks = (freqGenMin * clocksMin) / 2
    stepsMin = (minAreaClocks * scale) / areaPerStep
    print ("clocksMin %d stepsMin %d freqGenMin %d minAreaClocks %d" %
           (clocksMin,stepsMin,freqGenMin,minAreaClocks))

    print "accelSteps %d" % (accelSteps - stepsMin)

    if pData:
        from pylab import plot,grid,show
        from array import array
        time = array('f')
        data = array('f')
        data1 = array('f')
        time.append(0)
        data.append(0)
        data1.append(0)

    f = open('accel.txt','w')
    area = 0
    totalArea = 0
    clocks = 0
    steps = 1
    velocity = 0
    chkMin = True
    lastT = 0
    while (steps < accelSteps):
        while (area < areaPerStep):
            clocks += 1
            velocity += int(velPerClock)
            area += velocity
            totalArea += velocity
        steps += 1
        curT = clocks / freqGenMax
        deltaT = curT - lastT
        if pData:
            time.append(curT)
            data.append(velocity)
            data1.append(1.0 / deltaT)
        f.write("clock %5d time %8.6f step %4d velocity %6d\n" %
                (clocks,deltaT,steps,velocity))
        lastT = curT
        area -= areaPerStep
        if chkMin & dbg:
            print "clock %5d step %4d velocity %6d" % (clocks,steps,velocity)
        if chkMin & (velocity >= (freqGenMin * scale)):
            chkMin = False
            print ("clocks %d velocity %d steps %d area %d delta %d" %
                   (clocks,velocity / scale,steps,totalArea / scale,
                    totalArea/scale - minAreaClocks))
    print ("clocks %d %8.6f velocity %d totalArea %d delta %d" % 
           (clocks,clocks / freqGenMax,velocity / scale,totalArea / scale,
            totalArea / scale - int(stepAreaClocks)))
    f.close()
    stdout.flush()

    # setXReg('XLDZCTL',0,dbgprint)
    # setXReg('XLDZCTL',ZRST,dbgprint) # reset z axis
    # setXReg('XLDZCTL',0,dbgprint)

    # setXReg('XLDDCTL',0,dbgprint) # disable debug mode
    # setXReg('XLDZCTL',0,dbgprint) # clear z mode
    # setXReg('XLDDCTL',0,dbgprint)

    # if (runClocks > 0):
    #     setXReg('XLDTFREQ',freqDivider,dbgprint) # load test frequency
    #     setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    # else:
    #     setXReg('XLDZFREQ',freqDivider,dbgprint)

    # setXReg('XLDZMINV',minVelocity,dbgprint)
    # setXReg('XLDZMAXV',finalVelocity,dbgprint)
    # setXReg('XLDZACCL',velPerClock,dbgprint)
    # setXReg('XLDZAFRQ',areaPerStep,dbgprint)

    # setXReg('XLDZDIST',2 * accelSteps + runSteps,dbgprint)
    # setXReg('XLDZLOC',0,dbgprint) # set location
    # setXReg('XLDZCTL',ZSET_LOC | ZRST,dbgprint) # set z loc and load dist
    # setXReg('XLDZCTL',0,dbgprint)        # clear

    # if  (runClocks > 0):
    #     setXReg('XLDDCTL',DBG_MOVE,dbgprint) # select clock

    # dspXReg('XRDZDIST',"dist",dbgprint)

    # setXReg('XLDZCTL',(ZSTART |
    #                    ZDIR_POS |
    #                    ZWAIT_SYN),dbgprint)

    # if  (runClocks > 0):
    #     setXReg('XLDDCTL',(DBG_ENA |           # enable debugging
    #                        DBG_COUNT |         # run for number in count
    #                        DBG_MOVE),dbgprint) # debug axis move
    # stdout.flush()
    # sleep(1.3)

    # dspXReg('XRDZVEL',"vel",True)
    # dspXReg('XRDZNXT',"nxt",True)
    # dspXReg('XRDZASTP',"a steps",dbgprint)

    # dspXReg('XRDZDIST',"dist",dbgprint)
    # dspXReg('XRDZLOC',"loc",dbgprint)
    # setXReg('XLDZCTL',0,dbgprint)
    # dspXReg('XRDSTATE',"state",dbgprint)

    # if pData:
    #     stdout.flush()
    #     plot(time,data,'b',time,data1,'r',aa="true")
    #     grid(True)
    #     show()

# z unsynchronized motion with acceleration

def test3(runClocks=100,dist=20,dbgprint=True,dbg=False,pData=False):
    if pData:
        from pylab import plot,grid,show
        from array import array
        time = array('f')
        data = array('f')
        time.append(0)
        data.append(0)

    cFreq = 50000000            # clock frequency
    mult = 64                   # freq gen multiplier
    stepsRev = 1600             # steps per revolution
    pitch = .1                  # leadscrew pitch
    scale = 8                   # scale factor

    minFeed = 10                # min feed ipm
    maxFeed = 40                # max feed ipm
    accelRate = 5               # acceleration rate in per sec^2

    stepsInch = stepsRev / pitch      # steps per inch
    stepsMinMax = maxFeed * stepsInch # max steps per min
    stepsSecMax = stepsMinMax / 60.0  # max steps per second
    freqGenMax = int(stepsSecMax) * mult # frequency generator maximum
    print "stepsSecMax %6.0f freqGenMax %7.0f" % (stepsSecMax,freqGenMax)

    stepsMinMin = minFeed * stepsInch # max steps per min
    stepsSecMin = stepsMinMin / 60.0  # max steps per second
    freqGenMin = stepsSecMin * mult   # frequency generator maximum
    print "stepsSecMin %6.0f freqGenMin %7.0f" % (stepsSecMin,freqGenMin)

    freqDivider = int(floor(cFreq / freqGenMax - 1)) # calc divider
    print "freqDivider %3.0f" % freqDivider

    accelTime = (maxFeed - minFeed) / (60.0 * accelRate) # acceleration time
    accelClocks = int(accelTime * freqGenMax)
    print "accelTime %8.6f clocks %d" % (accelTime,accelClocks)

    for scale in range(0,10):
        dyMin = int(stepsSecMin) << scale
        dyMax = int(stepsSecMax) << scale
        dx = int(freqGenMax) << scale
        dyDelta = dyMax - dyMin
        print "\ndx %d dyMin %d dyMax %d dyDelta %d" % (dx,dyMin,dyMax,dyDelta)

        incPerClock = dyDelta / float(accelClocks)
        intIncPerClock = int(incPerClock)
        dyDeltaC = intIncPerClock * accelClocks
        dyIni = dyMax - dyDeltaC
        err = int(dyDelta - dyDeltaC) >> scale
        bits = int(floor(log(2*dx,2))) + 1
        print ("dyIni %d dyMax %d dyDelta %d incPerClock %4.2f err %d bits %d" %
               (dyIni,dyMax,dyDeltaC,incPerClock,err,bits))
        if (err == 0):
            break

    # incr1 = 2 * dyMax
    # incr2 = incr1 - 2 * dx
    # d = incr1 - dx
    # bits = int(floor(log(abs(incr2),2))) + 1
    # print ("incr1 %d incr2 %d d %d bits %d" %
    #        (incr1,incr2,d,bits))

    print ""
    clocks = 0
    lastT = 0
    lastC = 0
    x = 0
    y = 0
    incr1 = 2 * dyIni
    incr2 = incr1 - 2 * dx
    d = incr1 - dx

    bits = int(floor(log(abs(incr2),2))) + 1
    print ("dx %d dy %d incr1 %d incr2 %d d %d bits %d" %
           (dx,dyIni,incr1,incr2,d,bits))

    zSynAccel = 2 * intIncPerClock
    zSynAclCnt = accelClocks
    
    totalSum = (accelClocks * incr1) + d
    totalInc = (accelClocks * (accelClocks - 1) * zSynAccel) / 2
    accelSteps = ((totalSum + totalInc) / (2 * dx))

    print ("accelClocks %d totalSum %d totalInc %d accelSteps %d" % 
           (accelClocks,totalSum,totalInc,accelSteps))

    f = open('accel.txt','w')
    sum = d
    inc = 2 * intIncPerClock
    incAccum = 0
    print ("incr1 %d incr2 %d inc %d" % (incr1,incr2,intIncPerClock))
    stdout.flush()
    while (clocks < (accelClocks * 1.2)):
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            deltaC = clocks - lastC
            f.write(("x %6d y %5d deltaC %5d sum %12d incAccum %12d " +
                     "incr1 %8d incr2 %11d\n") % \
                    (x,y,deltaC,sum,incAccum,
                     incr1 + incAccum,incr2 + incAccum))
            y += 1
            sum += incr2
            curT = clocks / freqGenMax
            deltaT = curT - lastT
            if pData:
                if (lastT != 0):
                    time.append(curT);
                    data.append(1.0 / deltaT)
            lastT = curT
            lastC = clocks
        sum += incAccum
        if (clocks < accelClocks):
            incAccum += inc
        clocks += 1
    f.close()

    print ("y %d incr1 %d incr2 %d sum %d incAccum %d" %
           (y,incr1 + incAccum,incr2 + incAccum,sum,incAccum))

    print "\n"

    setXReg('XLDDCTL',0,dbgprint)    # disable debug mode
    setXReg('XLDTCTL',0,dbgprint)    # clear taper
    setXReg('XLDZCTL',ZRESET,dbgprint) # reset z
    setXReg('XLDZCTL',0,dbgprint)    # clear z mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDXCTL',XRESET,dbgprint) # reset x
    setXReg('XLDXCTL',0,dbgprint)

    # setXReg('XLDDREG',xRegs['XRDZSUM'],dbgprint) # load display register

    setXReg('XLDZD',d,dbgprint)		# load d value
    setXReg('XLDZINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDZINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDZACCEL',zSynAccel,dbgprint)   # load z accel
    setXReg('XLDZACLCNT',zSynAclCnt,dbgprint) # load z accel count

    setXReg('XLDTFREQ',freqDivider,dbgprint)  # load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 
    setXReg('XLDDCTL',DBG_INIT,dbgprint)      # initialize debug
    setXReg('XLDDCTL',DBG_MOVE,dbgprint)      # clear init and set move

    setXReg('XLDZLOC',20,dbgprint)       # set z location
    setXReg('XLDZDIST',dist,dbgprint)    # load z distance
    setXReg('XLDZCTL',ZRESET | ZSET_LOC,dbgprint) # reset and set z location

    setXReg('XLDZCTL',(ZDIR_POS # clear reset set direction positive
                   ),dbgprint)

    setXReg('XLDZCTL',(ZSTART      # start with
                       | ZDIR_POS  # direction positive
                   ),dbgprint)

    setXReg('XLDDCTL',(DBG_ENA     # enable debugging
                       | DBG_COUNT # run for number in count
                       | DBG_MOVE
                   ),dbgprint)

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    xPos = dspXReg('XRDZXPOS',"xpos",dbgprint)
    dspXReg('XRDZYPOS',"ypos",dbgprint)
    zsum = dspXReg('XRDZSUM',"sum",dbgprint)
    zAclSum = dspXReg('XRDZACLSUM',"aclsum",dbgprint)

    dspXReg('XRDZDIST',"dist",dbgprint)
    dspXReg('XRDZASTP',"a steps",dbgprint)
    dspXReg('XRDZLOC',"loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)

    x = 0
    y = 0
    clocks = 0
    sum = d
    accelAccum = 0
    distCtr = dist
    l0 = dist
    while (clocks < xPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2
            distCtr -= 1
            if (distCtr == 0):
                break
        sum += accelAccum
        if (y >= l0):
            if (accelAccum > 0):
                accelAccum -= zSynAccel
        else:
            if (clocks <= accelClocks):
                accelAccum += zSynAccel
        l0 = distCtr

    print ("\nx %d y %d sum %d delta %d accelAccum %d delta %d" %
           (x,y,sum,sum - zsum,accelAccum,accelAccum - zAclSum))

    if pData:
        plot(time,data,'b',aa="true")
        grid(True)
        show()

# z synchronized move with acceleration

def test4(runClocks=0,tpi=0,dist=20,dbgprint=True,pData=True):
    print runClocks,tpi
    if (tpi == 0):
        return
    if (tpi < 1):
        tpi = 1.0 / tpi
    if (runClocks == 0):
        runClocks = 1
    f = open('accel.txt','w')

    if pData:
        from pylab import plot,grid,show
        from array import array
        time = array('f')
        data = array('f')
        time.append(0)
        data.append(0)

    stepsRev = 1600             # steps per revolution
    lsPitch = .1                # leadscrew pitch
    spindleRPM = 300            # spindle speed
    encoder = 20320             # encoder counts
    threadPerIn = tpi           # threads per inch
    minFeed = 2.0               # minimum speed
    accelRate = 1               # acceleration inch per sec^2
    scale = 8

    print "tpi %5.2f pitch %5.3f" % (tpi,1.0 / tpi)

    zFeedRate = spindleRPM / threadPerIn # z feed rate inch per min
    print "zFeedRate %6.2f ipm" % (zFeedRate)

    spindleRPS = spindleRPM / 60.0 # spindle rev per second

    encPerSec = spindleRPS * encoder # encoder counts per second
    print "encPerSec %5.0f" % (encPerSec)

    stepsPerInch = stepsRev / lsPitch # steps per inch
    encPerInch = encoder * threadPerIn # encoder pulse per inch
    print "stepsPerInch %d encoderPerIn %d" % (stepsPerInch,encPerInch)

    stepsPerThread = stepsPerInch / threadPerIn # steps per thread
    stepsPerSecond = zFeedRate * stepsPerInch / 60.0 # steps per second
    print ("stepsPerThread %5.0f stepsPerSecond %5.0f" %
           (stepsPerThread,stepsPerSecond))

    dx = int(encPerInch) << scale
    dy = int(stepsPerInch) << scale
    print ("dx %d dy %d scale %d" % (dx,dy,1 << scale))

    accelTime = (zFeedRate - minFeed) / (60.0 * accelRate)
    accelClocks = int(encPerSec * accelTime)
    bits = int(floor(log(accelClocks,2))) + 1
    print ("accelTime %8.6f accelClocks %4.0f bits %d" %
           (accelTime,accelClocks,bits))

    iniDy = dy /  (zFeedRate / minFeed)
    dyDelta = dy - iniDy
    incPerClock = dyDelta / accelClocks
    intIncPerClock = int(incPerClock)
    iniDy = dy - intIncPerClock * accelClocks
    print ("iniDy %d dy %d dyDelta %d incPerClock %6.2f" %
           (iniDy,dy,dyDelta,incPerClock))

    incr1 = 2 * dy
    incr2 = incr1 - 2 * dx
    sum = incr1 - dx

    bits = int(floor(log(abs(incr2),2))) + 1
    print ("incr1 %d incr2 %d bits %d" %
           (incr1,incr2,bits))
    
    stdout.flush()

    # clocks = 0
    # lastT = 0
    # x = 0
    # y = 0
    # incr1 = 2 * iniDy
    # incr2 = incr1 - 2 * dx
    # sum = incr1 - dx
    # inc = 2 * intIncPerClock
    # print ("incr1 %d incr2 %d inc %d" % (incr1,incr2,intIncPerClock))
    # stdout.flush()
    # while (clocks < (accelClocks * 1.2)):
    #     clocks += 1
    #     x += 1
    #     if (sum < 0):
    #         sum += incr1
    #     else:
    #         y += 1
    #         sum += incr2
    #         curT = clocks / encPerSec
    #         deltaT = curT - lastT
    #         if pData:
    #             if (lastT != 0):
    #                 time.append(curT);
    #                 data.append(1.0 / deltaT)
    #         lastT = curT
    #         f.write("x %6d y %5d sum %11d incr1 %8d incr2 %11d\n" %
    #                 (x,y,sum,incr1,incr2))
    #     if (clocks <= accelClocks):
    #         incr1 += inc
    #         incr2 += inc
    # print "y %d incr1 %d incr2 %d sum %d" % (y,incr1,incr2,sum)
    # stdout.flush()

    clocks = 0
    lastT = 0
    x = 0
    y = 0
    incr1 = 2 * iniDy
    incr2 = incr1 - 2 * dx
    d = incr1 - dx
    sum = d

    zSynAccel = 2 * intIncPerClock
    zSynAclCnt = accelClocks

    totalSum = (accelClocks * incr1) + d
    totalInc = (accelClocks * (accelClocks - 1) * zSynAccel) / 2
    accelSteps = ((totalSum + totalInc) / (2 * dx)) + 1

    print ("accelClocks %d totalSum %d totalInc %d %d" % 
           (accelClocks,totalSum,totalInc,accelSteps))

    incAccum = 0;
    print ("incr1 %d incr2 %d zSynAccel %d" % (incr1,incr2,zSynAccel))
    stdout.flush()
    while (clocks < (accelClocks * 1.2)):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2
            curT = clocks / encPerSec
            deltaT = curT - lastT
            if pData:
                if (lastT != 0):
                    time.append(curT);
                    data.append(1.0 / deltaT)
            lastT = curT
        sum += incAccum
        if (clocks <= accelClocks):
            incAccum += zSynAccel
        f.write("x %6d y %5d sum %12d incAccum %12d incr1 %8d incr2 %11d\n" %
                (x,y,sum,incAccum,incr1 + incAccum,incr2 + incAccum))
    print ("y %d incr1 %d incr2 %d sum %d" %
           (y,incr1 + incAccum,incr2 + incAccum,sum))
    print ("y %d incr1 %d incr2 %d incAccum %d" %
           (y,incr1,incr2,incAccum))
    f.close()

    incr1 = 2 * iniDy
    incr2 = incr1 - 2 * dx
    d = incr1 - dx

    encPhase = 10

    setXReg('XLDDCTL',0,dbgprint)    # disable debug mode
    setXReg('XLDZCTL',ZRESET,dbgprint) # reset z
    setXReg('XLDZCTL',0,dbgprint)    # clear z mode
    setXReg('XLDDCTL',0,dbgprint)
    setXReg('XLDZCTL',0,dbgprint)

    setXReg('XLDTFREQ',10000,dbgprint)	# load test frequency
    setXReg('XLDTCOUNT',runClocks-1,dbgprint) # load test count 

    setXReg('XLDPHASE',encPhase - 1,dbgprint) # load phase count

    setXReg('XLDZD',d,dbgprint)		# load d value
    setXReg('XLDZINCR1',incr1,dbgprint)	# load incr1 value
    setXReg('XLDZINCR2',incr2,dbgprint)	# load incr2 value

    setXReg('XLDZACCEL',zSynAccel,dbgprint)   # load z accel
    setXReg('XLDZACLCNT',zSynAclCnt,dbgprint) # load z accel count

    setXReg('XLDDCTL',DBG_INIT,dbgprint) # initialize z modules
    setXReg('XLDDCTL',0,dbgprint)        # clear

    setXReg('XLDZLOC',20,dbgprint)       # set location
    setXReg('XLDZCTL',ZSET_LOC,dbgprint) # set z location
    setXReg('XLDZCTL',0,dbgprint)        # clear

    setXReg('XLDZDIST',dist,dbgprint) # load z distance
    setXReg('XLDZCTL',ZRESET,dbgprint)  # reset z to load distance
    setXReg('XLDZCTL',0,dbgprint)     # clear reset

    setXReg('XLDZCTL',(ZSRC_SYN    # sync source
                       | ZDIR_POS  # direction positive
                       | ZWAIT_SYN # wait for sync pulse
                   ),dbgprint)

    setXReg('XLDZCTL',(ZSTART      # start
                       | ZSRC_SYN  # sync source
                       | ZDIR_POS  # direction positive
                       | ZWAIT_SYN # wait for sync pulse
                   ),dbgprint)

    setXReg('XLDDCTL',(DBG_ENA     # enable debugging
                       | DBG_COUNT # run for number in count
                   ),dbgprint)

    sleep(.5);
    if dbgprint:
        print "\nresults %d clocks \n" % (runClocks)

    dspXReg('XRDFREQ',"freq",dbgprint)
    dspXReg('XRDPSYN',"phase syn",dbgprint)
    dspXReg('XRDTPHS',"tot phase",dbgprint)

    xPos = dspXReg('XRDZXPOS',"xpos",dbgprint)
    dspXReg('XRDZYPOS',"ypos",dbgprint)
    zsum = dspXReg('XRDZSUM',"sum",dbgprint)
    zAclSum = dspXReg('XRDZACLSUM',"aclsum",dbgprint)

    dspXReg('XRDZDIST',"dist",dbgprint)
    dspXReg('XRDZASTP',"a steps",dbgprint)
    dspXReg('XRDZLOC',"loc",dbgprint)
    dspXReg('XRDSTATE',"state",dbgprint)

    x = 0
    y = 0
    clocks = 0
    sum = d
    accelAccum = 0
    distCtr = dist
    l0 = dist
    while (clocks < xPos):
        clocks += 1
        x += 1
        if (sum < 0):
            sum += incr1
        else:
            y += 1
            sum += incr2
            distCtr -= 1
            if (distCtr == 0):
                break
        sum += accelAccum
        if (y >= l0):
            if (accelAccum > 0):
                accelAccum -= zSynAccel
        else:
            if (clocks <= accelClocks):
                accelAccum += zSynAccel
        l0 = distCtr

    print ("\nx %d y %d sum %d delta %d accelAccum %d delta %d" %
           (x,y,sum,sum - zsum,accelAccum,accelAccum - zAclSum))

    if pData:
        plot(time,data,'b',aa="true")
        grid(True)
        show()

def test5(dist=100,dbgprint=True,prt=False):
    if (dist == 0):
        dist = 100

    cFreq = 50000000            # clock frequency
    mult = 64                   # freq gen multiplier
    stepsRev = 1600             # steps per revolution
    pitch = .1                  # leadscrew pitch
    scale = 8                   # scale factor

    minFeed = 10                # min feed ipm
    maxFeed = 40                # max feed ipm
    jogV = 20                   # jog velocity
    accelRate = 5               # acceleration rate in per sec^2

    stepsInch = stepsRev / pitch      # steps per inch
    stepsMinMax = maxFeed * stepsInch # max steps per min
    stepsSecMax = stepsMinMax / 60.0  # max steps per second
    freqGenMax = int(stepsSecMax) * mult # frequency generator maximum
    if prt:
        print "stepsSecMax %6.0f freqGenMax %7.0f" % (stepsSecMax,freqGenMax)

    stepsMinMin = minFeed * stepsInch # max steps per min
    stepsSecMin = stepsMinMin / 60.0  # max steps per second
    freqGenMin = stepsSecMin * mult   # frequency generator maximum
    if prt:
        print "stepsSecMin %6.0f freqGenMin %7.0f" % (stepsSecMin,freqGenMin)

    stepsMinJog = int(jogV * stepsInch)
    stepsSecJog = stepsMinJog / 60
    freqGenJog = stepsSecJog * mult
    if prt:
        print "stepsSecJog %d freqGenJog %d\n" % (stepsSecJog,freqGenJog)

    freqDivider = int(floor(cFreq / freqGenMax - 1)) # calc divider
    if prt:
        print "freqDivider %3.0f" % freqDivider

    accelTime = (maxFeed - minFeed) / (60.0 * accelRate) # acceleration time
    accelClocks = int(accelTime * freqGenMax)
    if prt:
        print "accelTime %8.6f clocks %d" % (accelTime,accelClocks)

    for scale in range(0,10):
        dyMin = int(stepsSecMin) << scale
        dyMax = int(stepsSecMax) << scale
        dx = int(freqGenMax) << scale
        dyDelta = dyMax - dyMin
        if prt:
            print ("\ndx %d dyMin %d dyMax %d dyDelta %d" %
                   (dx,dyMin,dyMax,dyDelta))

        incPerClock = dyDelta / float(accelClocks)
        intIncPerClock = int(incPerClock)
        dyDeltaC = intIncPerClock * accelClocks
        dyIni = dyMax - dyDeltaC
        err = int(dyDelta - dyDeltaC) >> scale
        bits = int(floor(log(2*dx,2))) + 1
        if prt:
            print (("dyIni %d dyMax %d dyDelta %d incPerClock %4.2f " +
                    "err %d bits %d") %
                   (dyIni,dyMax,dyDeltaC,incPerClock,err,bits))
        if (err == 0):
            break

    accel = 2 * intIncPerClock
    
    dyJog = stepsSecJog << scale;
    dyDelta = (dyJog - dyIni);
    jogAccelClocks = dyDelta / accel;
    dyJog = jogAccelClocks * accel;

    incr1 = 2 * dyIni
    incr2 = incr1 - 2 * dx
    d = incr1 - dx
    
    totalSum = (accelClocks * incr1) + d
    totalInc = (accelClocks * (accelClocks - 1) * accel) / 2
    accelSteps = ((totalSum + totalInc) / (2 * dx))

    if prt:
        print ("accelClocks %d totalSum %d totalInc %d accelSteps %d" % 
               (accelClocks,totalSum,totalInc,accelSteps))

    while True:
        rsp = command('READDBG')
        if len(rsp) <= 4:
            break;
    command('CMDSTOP')
    command('XSTOP')
    setParm('PRMXLOCIN',0)
    command('XSETLOC')
    setParm('PRMXFREQ',freqDivider)
    setParm('PRMXDX',dx)
    setParm('PRMXDYINI',dyIni)
    setParm('PRMXDYJOG',dyJog)
    setParm('PRMXDYMAX',dyMax)
    setParm('PRMXACCEL',accel)
    setParm('PRMXACLJOG',jogAccelClocks)
    setParm('PRMXACLMAX',accelClocks)
    setParm('PRMXDISTIN',dist)
    command('LOADXPRM')
    command('XMOVE')
    while True:
        rsp = command('READDBG')
        if len(rsp) > 4:
            print rsp
            stdout.flush()
            if rsp.find("x st 00000000") > 0:
                break;
    dspXReg('XRDXLOC',"x loc",dbgprint)

class Move():
    def __init__(self):
        self.cFreq = 50000000   # clock frequency
        self.mult = 64          # freq gen multiplier
        self.stepsRev = 1600    # steps per revolution
        self.pitch = .1         # leadscrew pitch
        self.scale = 8          # scale factor

        self.minFeed = 10       # min feed ipm
        self.maxFeed = 40       # max feed ipm
        self.jogV = 20          # jog velocity
        self.accelRate = 5      # acceleration rate in per sec^2

        self.freqDivider = 0

    def setup(self,pitch):
        stepsInch = stepsRev / pitch           # steps per inch
        stepsMinMax = this.maxFeed * stepsInch # max steps per min
        stepsSecMax = stepsMinMax / 60.0       # max steps per second
        freqGenMax = int(stepsSecMax) * this.mult # frequency generator maximum
        if self.prt:
            print ("stepsSecMax %6.0f freqGenMax %7.0f" %
                   (stepsSecMax,freqGenMax))

        stepsMinMin = this.minFeed * stepsInch # max steps per min
        stepsSecMin = stepsMinMin / 60.0       # max steps per second
        freqGenMin = stepsSecMin * this.mult # frequency generator maximum
        if self.prt:
            print ("stepsSecMin %6.0f freqGenMin %7.0f" %
                   (stepsSecMin,freqGenMin))

        stepsMinJog = int(this.jogV * stepsInch)
        stepsSecJog = stepsMinJog / 60
        freqGenJog = stepsSecJog * mult
        if self.prt:
            print "stepsSecJog %d freqGenJog %d\n" % (stepsSecJog,freqGenJog)

        this.freqDivider = int(floor(this.cFreq /
                                     freqGenMax - 1)) # calc divider
        if self.prt:
            print "freqDivider %3.0f" % freqDivider

        this.accelTime = ((this.maxFeed - this.minFeed) /
                          (60.0 * accelRate)) # acceleration time
        this.accelClocks = int(accelTime * freqGenMax)
        if self.prt:
            print "accelTime %8.6f clocks %d" % (accelTime,accelClocks)

        for this.scale in range(0,10):
            dyMin = int(stepsSecMin) << this.scale
            dyMax = int(stepsSecMax) << this.scale
            this.dx = int(freqGenMax) << this.scale
            dyDelta = dyMax - dyMin
            if self.prt:
                print ("\ndx %d dyMin %d dyMax %d dyDelta %d" %
                       (this.dx,dyMin,dyMax,dyDelta))

            incPerClock = dyDelta / float(accelClocks)
            intIncPerClock = int(incPerClock)
            dyDeltaC = intIncPerClock * accelClocks
            this.dyIni = dyMax - dyDeltaC
            err = int(dyDelta - dyDeltaC) >> scale
            bits = int(floor(log(2*dx,2))) + 1
            if self.prt:
                print (("dyIni %d dyMax %d dyDelta %d incPerClock %4.2f " +
                        "err %d bits %d") %
                       (this.dyIni,dyMax,dyDeltaC,incPerClock,err,bits))
                if (err == 0):
                    break

            this.accel = 2 * intIncPerClock

            this.dyJog = stepsSecJog << scale;
            dyDelta = (dyJog - dyIni);
            jogAccelClocks = dyDelta / accel;
            dyJog = jogAccelClocks * accel;

            incr1 = 2 * this.dyIni
            incr2 = incr1 - 2 * this.dx
            d = incr1 - this.dx

            totalSum = (accelClocks * incr1) + d
            totalInc = (accelClocks * (accelClocks - 1) * this.accel) / 2
            this.accelSteps = ((totalSum + totalInc) / (2 * dx))

            if self.prt:
                print ("accelClocks %d totalSum %d totalInc %d accelSteps %d" % 
                       (accelClocks,totalSum,totalInc,this.accelSteps))

def test6(dist=100,dbgprint=True,prt=False):
    if (dist == 0):
        dist = 100

    cFreq = 50000000            # clock frequency
    mult = 64                   # freq gen multiplier
    stepsRev = 1600             # steps per revolution
    pitch = .1                  # leadscrew pitch
    scale = 8                   # scale factor

    minFeed = 10                # min feed ipm
    maxFeed = 40                # max feed ipm
    jogV = 20                   # jog velocity
    accelRate = 5               # acceleration rate in per sec^2

    stepsInch = stepsRev / pitch      # steps per inch
    stepsMinMax = maxFeed * stepsInch # max steps per min
    stepsSecMax = stepsMinMax / 60.0  # max steps per second
    freqGenMax = int(stepsSecMax) * mult # frequency generator maximum
    if prt:
        print "stepsSecMax %6.0f freqGenMax %7.0f" % (stepsSecMax,freqGenMax)

    stepsMinMin = minFeed * stepsInch # max steps per min
    stepsSecMin = stepsMinMin / 60.0  # max steps per second
    freqGenMin = stepsSecMin * mult   # frequency generator maximum
    if prt:
        print "stepsSecMin %6.0f freqGenMin %7.0f" % (stepsSecMin,freqGenMin)

    stepsMinJog = int(jogV * stepsInch)
    stepsSecJog = stepsMinJog / 60
    freqGenJog = stepsSecJog * mult
    if prt:
        print "stepsSecJog %d freqGenJog %d\n" % (stepsSecJog,freqGenJog)

    freqDivider = int(floor(cFreq / freqGenMax - 1)) # calc divider
    if prt:
        print "freqDivider %3.0f" % freqDivider

    accelTime = (maxFeed - minFeed) / (60.0 * accelRate) # acceleration time
    accelClocks = int(accelTime * freqGenMax)
    if prt:
        print "accelTime %8.6f clocks %d" % (accelTime,accelClocks)

    for scale in range(0,10):
        dyMin = int(stepsSecMin) << scale
        dyMax = int(stepsSecMax) << scale
        dx = int(freqGenMax) << scale
        dyDelta = dyMax - dyMin
        if prt:
            print ("\ndx %d dyMin %d dyMax %d dyDelta %d" %
                   (dx,dyMin,dyMax,dyDelta))

        incPerClock = dyDelta / float(accelClocks)
        intIncPerClock = int(incPerClock)
        dyDeltaC = intIncPerClock * accelClocks
        dyIni = dyMax - dyDeltaC
        err = int(dyDelta - dyDeltaC) >> scale
        bits = int(floor(log(2*dx,2))) + 1
        if prt:
            print (("dyIni %d dyMax %d dyDelta %d incPerClock %4.2f " +
                    "err %d bits %d") %
                   (dyIni,dyMax,dyDeltaC,incPerClock,err,bits))
            if (err == 0):
                break

    accel = 2 * intIncPerClock

    dyJog = stepsSecJog << scale;
    dyDelta = (dyJog - dyIni);
    jogAccelClocks = dyDelta / accel;
    dyJog = jogAccelClocks * accel;

    incr1 = 2 * dyIni
    incr2 = incr1 - 2 * dx
    d = incr1 - dx

    totalSum = (accelClocks * incr1) + d
    totalInc = (accelClocks * (accelClocks - 1) * accel) / 2
    accelSteps = ((totalSum + totalInc) / (2 * dx))

    if prt:
        print ("accelClocks %d totalSum %d totalInc %d accelSteps %d" % 
               (accelClocks,totalSum,totalInc,accelSteps))

    setXReg('XLDTCTL',0,dbgprint)    # clear taper
    command('CMDSTOP')
    while True:
        rsp = command('READDBG')
        if len(rsp) <= 4:
            break;
        print rsp
    print "send commands"
    command('ZSTOP')
    setParm('PRMZLOCIN',0)
    command('ZSETLOC')
    setParm('PRMZFREQ',freqDivider)
    setParm('PRMZDX',dx)
    setParm('PRMZDYINI',dyIni)
    setParm('PRMZDYJOG',dyJog)
    setParm('PRMZDYMAX',dyMax)
    setParm('PRMZACCEL',accel)
    setParm('PRMZACLJOG',jogAccelClocks)
    setParm('PRMZACLMAX',accelClocks)
    setParm('PRMZDISTIN',dist)
    command('LOADZPRM')
    command('ZMOVE')
    while True:
        rsp = command('READDBG')
        if len(rsp) > 4:
            print rsp
            stdout.flush()
            if rsp.find("z st 00000000") > 0:
                break;
    dspXReg('XRDZLOC',"x loc",dbgprint)
                

arg1 = 0
arg2 = 0
if len(sys.argv) > 1:
    try:
        arg1 = int(sys.argv[1])
    except ValueError:
        arg1 = sys.argv[1]
if len(sys.argv) > 2:
    try:
        arg2 = int(sys.argv[2])
    except ValueError:
        arg2 = sys.argv[2]
ser = None
try:
    ser = serial.Serial('com8',57600,timeout=1)
except IOError:
    print "unable to open port"
    stdout.flush()
 #print ser.name
if (arg1 == 'd'):
    if arg2 in xRegs:
        setXReg('XLDDREG',xRegs[arg2],False) # load display register
    else:
        print "invalid register " + arg2
else:
    # test1(runClocks=arg1,dist=arg2,dbgprint=True)
    # test2(runClocks=arg1,dist=arg2,dbgprint=True)
    # test2a(runClocks=arg1,dist=arg2,dbgprint=True)
    # test2b(runClocks=arg1,dist=arg2,dbgprint=True)
    # test3(runClocks=arg1,dist=arg2)
    # test4(runClocks=arg1,tpi=arg2,pData=False)
    # test5(dist=arg1)
    test6(dist=arg1)
if not (ser is None):
    ser.close()
