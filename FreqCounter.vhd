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
        init : in std_logic;
        ch : in std_logic;
        tick : in std_logic;
        freqCtr_reg : out unsigned(freq_bits-1 downto 0);
        ready : inout std_logic
        );
end FreqCounter;

architecture Behavioral of FreqCounter is

 type fsm is (idle, upd_count, upd_output);
 signal state : fsm;

 signal counter :
  unsigned(freq_bits-1 downto 0) := (freq_bits-1 downto 0 => '0');
 signal start : std_logic;
 signal read : std_logic;

 signal incFlag : std_logic;
 signal initFlag : std_logic;
 signal tickFlag : std_logic;

begin

 freq_ctr: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (ch = '1') then
    incFlag <= '1';
   end if;
   if (init = '1') then
    initFlag <= '1';
   end if;
   if (tick = '1') then
    tickFlag <= '1';
   end if;

   case state is
    when idle =>
     if (incFlag = '1') then
      state <=  upd_count;
     elsif (tickFlag = '1') then
      state <= upd_output;
     end if;

    when upd_count =>
     counter <= counter + 1;
     incFlag <= '0';
     state <= idle;

    when upd_output =>
     freqCtr_reg <= counter;
     counter <= (freq_bits-1 downto 0 => '0'); --reset counter
     ready <= '1';
     tickFlag <= '0';
     state <= idle;

   end case;
  end if;
 end process;

end Behavioral;
