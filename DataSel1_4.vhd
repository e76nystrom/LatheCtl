--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:09:43 01/30/2015 
-- Design Name: 
-- Module Name:    DataSel1_4 - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataSel1_4 is
 port ( sel : in std_logic_vector (1 downto 0);
        d0 : in std_logic;
        d1 : in std_logic;
        d2 : in std_logic;
        d3 : in std_logic;
        dout : out std_logic);
end DataSel1_4;

architecture Behavioral of DataSel1_4 is

begin

 dout <= d3 when (sel = "11") else
         d2 when (sel = "10") else
         d1 when (sel = "01") else
         d0 when (sel = "00") else
         '0';

end Behavioral;
