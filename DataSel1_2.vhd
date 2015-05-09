--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:06:16 01/30/2015 
-- Design Name: 
-- Module Name:    DataSel1-2 - Behavioral 
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

entity DataSel1_2 is
    port ( sel : in std_logic;
           d0 : in std_logic;
           d1 : in std_logic;
           dout : out std_logic);
end DataSel1_2;

architecture Behavioral of DataSel1_2 is

begin

dout <= d1 when (sel = '1') else
        d0;

end Behavioral;

