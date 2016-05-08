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

 type fsm is (idle, upd_ch, upd_tick);
 signal state : fsm;

 signal counter :
  unsigned(freq_bits-1 downto 0) := (freq_bits-1 downto 0 => '0');

 signal chFlag : std_logic := '0';
 signal initFlag : std_logic := '0';
 signal tickFlag : std_logic := '0';

begin

 freq_ctr: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   ready <= outReady;
   if (ch = '1') then
    chFlag <= '1';
   end if;
   if (init = '1') then
    initFlag <= '1';
   end if;
   if (tick = '1') then
    tickFlag <= '1';
   end if;

   case state is
    when idle =>
     if (chFlag = '1') then
      state <=  upd_ch;
     elsif (tickFlag = '1') then
      state <= upd_tick;
     end if;

    when upd_ch =>
     chFlag <= '0';
     counter <= counter + 1;
     if (tickFlag = '1') then
      state <= upd_tick;
     else
      state <= idle;
     end if;

    when upd_tick =>
     tickFlag <= '0';
     if (initFlag = '1') then
      initFlag <= '0';
      outReady <= '0';
     else
      if (outReady = '0') then
       outReady <= '1';
       freqCtr_reg <= counter;
      end if;
     end if;
     counter <= (freq_bits-1 downto 0 => '0'); --reset counter
     state <= idle;

   end case;
  end if;
 end process;

end Behavioral;
