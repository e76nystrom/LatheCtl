--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:33:37 01/25/2015 
-- Design Name: 
-- Module Name:    DownCounter - Behavioral 
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

entity DownCounter is
 generic(n : positive);
 port ( clk : in std_logic;
        ena : in std_logic;
        load : in std_logic;
        preset : in unsigned (n-1 downto 0);
        counter : inout  unsigned (n-1 downto 0);
        zero : out std_logic);
end DownCounter;

architecture Behavioral of DownCounter is

begin

 downcounter: process(clk)
 begin
  if (rising_edge(clk)) then
   if (load = '1') then
    counter <= preset;
    zero <= '0';
   elsif (ena = '1') then
    if (counter = 0) then
     zero <= '1';
    else
     counter <= counter - 1;
    end if;
   end if;
  end if;
 end process;

end Behavioral;

