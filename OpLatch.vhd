----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:25:36 05/16/2016 
-- Design Name: 
-- Module Name:    OpLatch - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OpLatch is
 generic(opVal : positive);
 port (
  clk : in  STD_LOGIC;
  op : in  STD_LOGIC;
  opSel : out  STD_LOGIC);
end OpLatch;

architecture Behavioral of OpLatch is

begin

 pCtl_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   if (op = opVal) then
    opSel <= '1';
   else
    opSel <= '0';
   end if;
  end if;
 end process;

end Behavioral;

