--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:20:28 01/29/2015 
-- Design Name: 
-- Module Name:    TickGen - Behavioral 
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
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TickGen is
 generic(div : positive := 1000000);
 port ( clk : in std_logic;
        tick: out std_logic);
end TickGen;

architecture Behavioral of TickGen is

 signal divider : integer range 0 to div-1 := 0;
begin

 TickGen: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (divider = 0) then                --if divider zero
    divider <= div - 1;                 --set to maximum
    tick <= '1';                        --set tick output
   else                                 --if divider non zero
    divider <= divider - 1;             --count divider down
    tick <= '0';                        --clear tick output
   end if;
  end if;
 end process TickGen;

end Behavioral;
