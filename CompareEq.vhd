--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:17:00 04/13/2015 
-- Design Name: 
-- Module Name:    CompareEq - Behavioral 
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

entity CompareEq is
 generic (n : positive);
 port ( a : in unsigned (n-1 downto 0);
        b : in unsigned (n-1 downto 0);
        cmp : out std_logic);
end CompareEq;

architecture Behavioral of CompareEq is

begin

compare: process(a,b)
begin
 if (a = b) then
  cmp <= '1';
 else
  cmp <= '0';
 end if;
end process compare;

end Behavioral;
