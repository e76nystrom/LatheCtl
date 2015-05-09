--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package Constants is

constant opb : integer := 8;

constant XLDZCTL      : unsigned(opb-1 downto 0) := x"00"; --z control register
constant XLDXCTL      : unsigned(opb-1 downto 0) := x"01"; --x control register
constant XLDTCTL      : unsigned(opb-1 downto 0) := x"02"; --load taper control
constant XLDPCTL      : unsigned(opb-1 downto 0) := x"03"; --position control
constant XLDCFG       : unsigned(opb-1 downto 0) := x"04"; --configuration
constant XLDDCTL      : unsigned(opb-1 downto 0) := x"05"; --load debug control
constant XLDDREG      : unsigned(opb-1 downto 0) := x"06"; --load display reg
constant XREADREG     : unsigned(opb-1 downto 0) := x"07"; --read register

constant XLDPHASE     : unsigned(opb-1 downto 0) := x"08"; --load phase max

constant XLDZFREQ     : unsigned(opb-1 downto 0) := x"09"; --load z frequency
constant XLDZD        : unsigned(opb-1 downto 0) := x"0a"; --load z initial d
constant XLDZINCR1    : unsigned(opb-1 downto 0) := x"0b"; --load z incr1
constant XLDZINCR2    : unsigned(opb-1 downto 0) := x"0c"; --load z incr2
constant XLDZSACCEL   : unsigned(opb-1 downto 0) := x"0d"; --load z syn accel
constant XLDZSACLCNT  : unsigned(opb-1 downto 0) := x"0e"; --load z syn acl cnt
constant XLDZDIST     : unsigned(opb-1 downto 0) := x"0f"; --load z distance
constant XLDZLOC      : unsigned(opb-1 downto 0) := x"10"; --load z location

constant XLDXFREQ     : unsigned(opb-1 downto 0) := x"11"; --load x frequency
constant XLDXD        : unsigned(opb-1 downto 0) := x"12"; --load x initial d
constant XLDXINCR1    : unsigned(opb-1 downto 0) := x"13"; --load x incr1
constant XLDXINCR2    : unsigned(opb-1 downto 0) := x"14"; --load x incr2
constant XLDXSACCEL   : unsigned(opb-1 downto 0) := x"15"; --load x syn accel
constant XLDXSACLCNT  : unsigned(opb-1 downto 0) := x"16"; --load x syn acl cnt
constant XLDXDIST     : unsigned(opb-1 downto 0) := x"17"; --load x distance
constant XLDXLOC      : unsigned(opb-1 downto 0) := x"18"; --load x location

constant XRDZSUM      : unsigned(opb-1 downto 0) := x"19"; --read z sync sum
constant XRDZXPOS     : unsigned(opb-1 downto 0) := x"1a"; --read z sync x pos
constant XRDZYPOS     : unsigned(opb-1 downto 0) := x"1b"; --read z sync y pos
constant XRDZACLSUM   : unsigned(opb-1 downto 0) := x"1c"; --read z acl sum
constant XRDZASTP     : unsigned(opb-1 downto 0) := x"1d"; --read z acl stps

constant XRDXSUM      : unsigned(opb-1 downto 0) := x"1e"; --read x sync sum
constant XRDXXPOS     : unsigned(opb-1 downto 0) := x"1f"; --read x sync x pos
constant XRDXYPOS     : unsigned(opb-1 downto 0) := x"20"; --read x sync y pos
constant XRDXACLSUM   : unsigned(opb-1 downto 0) := x"21"; --read x acl sum
constant XRDXASTP     : unsigned(opb-1 downto 0) := x"22"; --read z acl stps

constant XRDZDIST     : unsigned(opb-1 downto 0) := x"23"; --read z distance
constant XRDXDIST     : unsigned(opb-1 downto 0) := x"24"; --read x distance

constant XRDZLOC      : unsigned(opb-1 downto 0) := x"25"; --read z location
constant XRDXLOC      : unsigned(opb-1 downto 0) := x"26"; --read x location

constant XRDFREQ      : unsigned(opb-1 downto 0) := x"27"; --read encoder freq
constant XRDSTATE     : unsigned(opb-1 downto 0) := x"28"; --read state info

constant XRDPSYN      : unsigned(opb-1 downto 0) := x"29"; --read sync phase val
constant XRDTPHS      : unsigned(opb-1 downto 0) := x"2a"; --read tot phase val

constant XLDZLIM      : unsigned(opb-1 downto 0) := x"2b"; --load z limit
constant XRDZPOS      : unsigned(opb-1 downto 0) := x"2c"; --read z position

constant XLDTFREQ     : unsigned(opb-1 downto 0) := x"2d"; --load test freq
constant XLDTCOUNT    : unsigned(opb-1 downto 0) := x"2e"; --load test count

end Constants;

package body Constants is

end Constants;
