--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:33 01/24/2015 
-- Design Name: 
-- Module Name:    DataSel - Behavioral 
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

entity DataSel is
 generic(n : positive);
    port ( sel : in std_logic_vector (1 downto 0);
           data0 : in  UNSIGNED (n-1 downto 0);
           data1 : in  UNSIGNED (n-1 downto 0);
           data2 : in  UNSIGNED (n-1 downto 0);
           data_out : out  UNSIGNED (n-1 downto 0));
end DataSel;

architecture Behavioral of DataSel is

begin

mux: process(sel,data0,data1,data2)
 begin
  case (sel) is
   when "00" => data_out <= data0;
   when "01" => data_out <= data1;
   when "10" => data_out <= data2;
   when others => data_out <= (n-1 downto 0 => '0');          
  end case;
 end process mux;

end Behavioral;

