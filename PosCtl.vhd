----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:10:35 04/13/2015 
-- Design Name: 
-- Module Name:    PosCtl - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PosCtl is
 generic(pos_bits : positive := 32);
 Port ( clk : in std_logic;
        rst : in std_logic;
        ch : in std_logic;
        encDir : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        limSel : in std_logic;
        pos : inout unsigned(pos_bits-1 downto 0)
        );
end PosCtl;

architecture Behavioral of PosCtl is

 component Shift is
  generic (n : positive);
  port (
   clk : in std_logic;
   din : in std_logic;
   shift : in std_logic;
   data : inout unsigned(n-1 downto 0)
  );
 end component;

 component UpDownClrCtr
  generic (n : positive);
  port(
   clk : in std_logic;
   ena : in std_logic;
   inc : in std_logic;
   clr : in std_logic;       
   counter : unsigned(n-1 downto 0)
   );
 end component;

 component DataSel2 is
  generic (n : positive);
  port ( sel : in std_logic;
         data0 : in unsigned(n-1 downto 0);
         data1 : in unsigned(n-1 downto 0);
         data_out : out unsigned(n-1 downto 0));
 end component;

 component CompareEq is
  generic (n : positive);
  port (
   a : in unsigned(n-1 downto 0);
   b : in unsigned(n-1 downto 0);
   cmp : out std_logic
   );
 end component;

 signal limit : unsigned(pos_bits-1 downto 0); --z limit
 type pos_fsm is (idle,check_limit,check_zero);
 signal pos_state : pos_fsm;
 signal atlimit : std_logic;            --at limit
 signal atzero  : std_LOGIC;            --at zero
 signal limShift : std_logic;
 signal posClear : std_logic;
 signal posInc : std_logic;
 signal posCount : std_logic;
 signal selLimit : std_logic;
 signal limitVal : unsigned(pos_bits-1 downto 0);
 signal cmpResult : std_logic;

begin

 limShift <= limSel and dshift;

 limitReg: Shift
  generic map(pos_bits)
  port map (
   clk => clk,
   din => din,
   shift => limShift,
   data => limit);

 limSelect:  DataSel2
  generic map(pos_bits)
  port map (
   sel => posInc,
   data0 => (pos_bits-1 downto 0 => '0'),
   data1 => limit,
   data_out => limitVal);

 posCompare: CompareEq
  generic map(pos_bits)
  port map (
   a => limitVal,
   b => pos,
   cmp => cmpResult);

 posCounter: UpDownClrCtr
  generic map(pos_bits)
  port map (
   clk => clk,
   ena => posCount,
   inc => posInc,
   clr => posClear,
   counter => pos);

 loc_proc: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active and change
   if (rst = '1') then                  --if time to load
    posClear <= '1';                    --clear position
    atlimit <= '0';                     --clear limit flag
    atzero <= '0';                      --clear zero flag
    pos_state <= idle;                  --set to initial state
   else
    case pos_state is
     when idle =>                       --idle
      posClear <= '0';                  --make sure clear reset flag
      if (ch = '1') then                --if clock
       posCount <= '1';                 --set count flag
       if (encDir = '1') then           --if encoder turning forward
        posInc <= '1';                  --set to increment
        pos_state <= check_limit;       --check for at limit
       else                             --if encoder turning backwards
        posInc <= '0';                  --set to decrement
        pos_state <= check_zero;        --check for at zero
       end if;
      end if;
      
     when check_limit =>                --check at limit
      posCount <= '0';                  --clear count flag
      if (cmpResult = '1') then         --if at limit
       atlimit <= '1';                  --set at limit flag
      end if;
      pos_state <= idle;                --return to idle state

     when check_zero =>                 --check for at zero
      posCount <= '0';                  --clear count flag
      if (cmpResult = '1') then         --if at zero
       atzero <= '1';                   --set at zero flag
      end if;
      pos_state <= idle;               --return to idle state
      
     when others => null;
    end case;
   end if;
  end if;
 end process;

end Behavioral;

