--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:18:52 01/29/2015 
-- Design Name: 
-- Module Name:    FreqCounter - Behavioral 
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

entity FreqCounter is
 generic(freq_bits : positive);
 port ( clk : in std_logic;
        ch : in std_logic;
        tick : in std_logic;
        freqCtr_reg : out unsigned(freq_bits-1 downto 0)
        );
end FreqCounter;

architecture Behavioral of FreqCounter is

 signal counter :
  unsigned(freq_bits-1 downto 0) := (freq_bits-1 downto 0 => '0');

begin

 freq_ctr: process(clk)
 begin
  if (rising_edge(clk)) then           --if clock active
   if (tick = '1') then                --if ten ms tick
    freqCtr_reg <= counter;            --send count to output register
    counter <= (freq_bits-1 downto 0 => '0'); --reset counter
   else
    if (ch = '1') then                  --if phase input change
     counter <= counter + 1;            --update counter
    end if;
   end if;
  end if;
 end process;

end Behavioral;
