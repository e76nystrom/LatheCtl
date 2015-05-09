----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:13 04/09/2015 
-- Design Name: 
-- Module Name:    LoadReg - Behavioral 
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

entity LoadReg is
 generic (op_bits : positive := 8;
          in_bits : positive := 32;
          out_bits : positive := 32);
 Port ( clk : in std_logic;
         op: in unsigned(op_bits-1 downto 0);
         regnum : unsigned(op_bits-1 downto 0);
        --sel : in std_logic;
        load : in  std_logic;
        data_in : in  unsigned (out_bits-1 downto 0);
        data_out : out unsigned (out_bits-1 downto 0));
end LoadReg;

architecture Behavioral of LoadReg is

begin

 load_reg : process (clk)
 begin
  if (rising_edge(clk)) then
   if ((op = regnum) and (load = '1')) then
    data_out <= data_in;
   end if;
  end if;

 end process load_reg;

end Behavioral;
