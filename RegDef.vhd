library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package RegDef is

constant opb : positive := 8;


-- skip register zero

constant XNOOP        : unsigned(opb-1 downto 0) := x"00"; -- register 0

-- load control registers

constant XLDZCTL      : unsigned(opb-1 downto 0) := x"01"; -- z control register
constant XLDXCTL      : unsigned(opb-1 downto 0) := x"02"; -- x control register
constant XLDTCTL      : unsigned(opb-1 downto 0) := x"03"; -- load taper control
constant XLDPCTL      : unsigned(opb-1 downto 0) := x"04"; -- position control
constant XLDCFG       : unsigned(opb-1 downto 0) := x"05"; -- configuration
constant XLDDCTL      : unsigned(opb-1 downto 0) := x"06"; -- load debug control
constant XLDDREG      : unsigned(opb-1 downto 0) := x"07"; -- load display reg
constant XREADREG     : unsigned(opb-1 downto 0) := x"08"; -- read register

-- status register

constant XRDSR        : unsigned(opb-1 downto 0) := x"09"; -- read status register

-- phase counter

constant XLDPHASE     : unsigned(opb-1 downto 0) := x"0a"; -- load phase max

-- load z motion

constant XLDZFREQ     : unsigned(opb-1 downto 0) := x"0b"; -- load z frequency
constant XLDZD        : unsigned(opb-1 downto 0) := x"0c"; -- load z initial d
constant XLDZINCR1    : unsigned(opb-1 downto 0) := x"0d"; -- load z incr1
constant XLDZINCR2    : unsigned(opb-1 downto 0) := x"0e"; -- load z incr2
constant XLDZACCEL    : unsigned(opb-1 downto 0) := x"0f"; -- load z syn accel
constant XLDZACLCNT   : unsigned(opb-1 downto 0) := x"10"; -- load z syn acl cnt
constant XLDZDIST     : unsigned(opb-1 downto 0) := x"11"; -- load z distance
constant XLDZLOC      : unsigned(opb-1 downto 0) := x"12"; -- load z location

-- load x motion

constant XLDXFREQ     : unsigned(opb-1 downto 0) := x"13"; -- load x frequency
constant XLDXD        : unsigned(opb-1 downto 0) := x"14"; -- load x initial d
constant XLDXINCR1    : unsigned(opb-1 downto 0) := x"15"; -- load x incr1
constant XLDXINCR2    : unsigned(opb-1 downto 0) := x"16"; -- load x incr2
constant XLDXACCEL    : unsigned(opb-1 downto 0) := x"17"; -- load x syn accel
constant XLDXACLCNT   : unsigned(opb-1 downto 0) := x"18"; -- load x syn acl cnt
constant XLDXDIST     : unsigned(opb-1 downto 0) := x"19"; -- load x distance
constant XLDXLOC      : unsigned(opb-1 downto 0) := x"1a"; -- load x location

-- read z motion

constant XRDZSUM      : unsigned(opb-1 downto 0) := x"1b"; -- read z sync sum
constant XRDZXPOS     : unsigned(opb-1 downto 0) := x"1c"; -- read z sync x pos
constant XRDZYPOS     : unsigned(opb-1 downto 0) := x"1d"; -- read z sync y pos
constant XRDZACLSUM   : unsigned(opb-1 downto 0) := x"1e"; -- read z acl sum
constant XRDZASTP     : unsigned(opb-1 downto 0) := x"1f"; -- read z acl stps

-- read x motion

constant XRDXSUM      : unsigned(opb-1 downto 0) := x"20"; -- read x sync sum
constant XRDXXPOS     : unsigned(opb-1 downto 0) := x"21"; -- read x sync x pos
constant XRDXYPOS     : unsigned(opb-1 downto 0) := x"22"; -- read x sync y pos
constant XRDXACLSUM   : unsigned(opb-1 downto 0) := x"23"; -- read x acl sum
constant XRDXASTP     : unsigned(opb-1 downto 0) := x"24"; -- read z acl stps

-- read distance

constant XRDZDIST     : unsigned(opb-1 downto 0) := x"25"; -- read z distance
constant XRDXDIST     : unsigned(opb-1 downto 0) := x"26"; -- read x distance

-- read location

constant XRDZLOC      : unsigned(opb-1 downto 0) := x"27"; -- read z location
constant XRDXLOC      : unsigned(opb-1 downto 0) := x"28"; -- read x location

-- read frequency and state

constant XRDFREQ      : unsigned(opb-1 downto 0) := x"29"; -- read encoder freq
constant XCLRFREQ     : unsigned(opb-1 downto 0) := x"2a"; -- clear freq register
constant XRDSTATE     : unsigned(opb-1 downto 0) := x"2b"; -- read state info

-- read phase

constant XRDPSYN      : unsigned(opb-1 downto 0) := x"2c"; -- read sync phase val
constant XRDTPHS      : unsigned(opb-1 downto 0) := x"2d"; -- read tot phase val

-- phase limit info

constant XLDZLIM      : unsigned(opb-1 downto 0) := x"2e"; -- load z limit
constant XRDZPOS      : unsigned(opb-1 downto 0) := x"2f"; -- read z position

-- test info

constant XLDTFREQ     : unsigned(opb-1 downto 0) := x"30"; -- load test freq
constant XLDTCOUNT    : unsigned(opb-1 downto 0) := x"31"; -- load test count

-- read control regs

constant XRDZCTL      : unsigned(opb-1 downto 0) := x"32"; -- read control regiisters
constant XRDXCTL      : unsigned(opb-1 downto 0) := x"33"; -- read control regiisters

end RegDef;

package body RegDef is

end RegDef;
