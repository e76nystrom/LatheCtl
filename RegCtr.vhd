--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:02:29 01/24/2015 
-- Design Name: 
-- Module Name:    Shift - Behavioral 
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

entity RegCtr is
 generic(n : positive);
 port ( clk : in std_logic;
        ld_ena : in std_logic;
        shift_in : in std_logic;
        ct_ena : in std_logic;
        load : in std_logic;
        data : inout  unsigned (n-1 downto 0);
        zero : inout std_logic);
end RegCtr;

architecture Behavioral of RegCtr is

 component Shift is
  generic (n : positive);
  port ( clk : in std_logic;
         din : in std_logic;
         shift : in std_logic;
         data : inout  unsigned (n-1 downto 0));
 end component;

 signal dist_reg : unsigned(n-1 downto 0);

begin

 distreg: Shift
  generic map(n)
  port map (
   clk => clk,
   din => shift_in,
   shift => ld_ena,
   data => dist_reg);

 regctr: process (clk)
 begin
  if (rising_edge(clk)) then
   if (data = 0) then
    zero <= '1';
   else
    zero <= '0';
   end if;
   if (load = '1') then
    data <= dist_reg;
    zero <= '0';
   elsif (ct_ena = '1') then
    if (zero = '0') then
     data <= data - 1;
    end if;
   end if;
  end if;
 end process regctr;

end Behavioral;
