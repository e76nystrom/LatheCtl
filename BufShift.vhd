--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:29 01/24/2015 
-- Design Name: 
-- Module Name:    BufShift - Behavioral 
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

entity BufShift is
 generic(n : positive);
 port ( clk : in std_logic;
        ena : in std_logic;
        load : in std_logic;
        shift_in : in std_logic;
        data : inout unsigned (n-1 downto 0));
end BufShift;

architecture Behavioral of BufShift is

 signal buf : unsigned(n-1 downto 0);

begin

bufshift: process (clk)
 begin
  if (rising_edge(clk)) then
   if (ena = '1') then
    if (load = '1') then
     data <= buf;
    else
     buf <= buf(n-2 downto 0) & shift_in;
    end if;
   end if;
  end if;
 end process bufshift;

end Behavioral;

