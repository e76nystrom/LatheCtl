--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:29 01/24/2015 
-- Design Name: 
-- Module Name:    ShiftOut - Behavioral 
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

entity ShiftOut is
 generic(n : positive);
 port (
  clk : in std_logic;
  dshift : in std_logic;
  load : in std_logic;
  dout : out std_logic;
  data : in unsigned(n-1 downto 0));
end ShiftOut;

architecture Behavioral of ShiftOut is

 signal shift : unsigned(n-1 downto 0) := (n-1 downto 0 => '0');

begin

 dout <= shift(n-1);

 shiftout: process (clk)
 begin
  if (rising_edge(clk)) then
   if (load = '1') then
    shift <= data;
   else 
    if (dshift = '1') then
     --shift <= shift_right(shift,1);
     shift <= shift(n-2 downto 0) & shift(n-1);
    end if;
   end if;
  end if;
 end process shiftout;

end Behavioral;

