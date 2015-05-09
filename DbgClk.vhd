--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:31:15 04/05/2015 
-- Design Name: 
-- Module Name:    DbgClk - Behavioral 
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

entity DbgClk is
 generic(freq_bits : positive;
         count_bits : positive);
 port ( clk : in std_logic;
        dbg_ena : in std_logic;
        dbg_dir : in std_logic;
        dbg_count : in std_logic;
        a : in std_logic;
        b : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        load : in std_logic;
        freq_sel : in std_logic;
        count_sel : in std_logic;
        --dbg1 : out std_logic;
        --dbg2 : out std_logic;
        a_out : out std_logic;
        b_out : out std_logic;
        dbg_pulse : out std_logic);
end DbgClk;

architecture Behavioral of DbgClk is

 component FreqGen
  generic(freq_bits : positive);
  PORT(
   clk : in std_logic;
   ena : in std_logic;
   dshift : in std_logic;
   freq_sel : in std_logic;
   din : in std_logic;
   pulse_out : out std_logic
   );
 end component;

 component Shift is
  generic(n : positive);
  port ( clk : in std_logic;
         shift : in std_logic;
         din : in std_logic;
         data : inout unsigned(n-1 downto 0));
 end component;

 signal sq : std_logic_vector(1 downto 0) := "00";
 signal count : unsigned(count_bits-1 downto 0);
 signal counter : unsigned(count_bits-1 downto 0);
 signal freq_shift : std_logic;
 signal count_shift : std_logic;
 signal pulse_out : std_logic;
 signal pulse_ena : std_logic;
 signal freq_ena : std_logic;

begin

 freq_shift <= freq_sel and dshift;
 freq_ena <= '1' when (dbg_ena = '1') and (pulse_ena ='1') else '0';

 clock: FreqGen
  generic map(freq_bits)
  port map (
   clk => clk,
   ena => freq_ena,
   dshift => dshift,
   freq_sel => freq_shift,
   din => din,
   pulse_out => pulse_out
   );

 count_shift <= count_sel and dshift;

 countreg: Shift
  generic map(count_bits)
  port map (
   clk => clk,
   shift => count_shift,
   din => din,
   data => count);
 
 a_out <= sq(0) when (dbg_ena = '1') else a;
 b_out <= sq(1) when (dbg_ena = '1') else b;
 dbg_pulse <= pulse_out;

 count_seq: process(clk)
 begin
  if (rising_edge(clk)) then
   if (load = '1') then
    counter <= count;
    pulse_ena <= '1';
   else
    if (dbg_ena = '1') then
     if ((pulse_out = '1') and (dbg_count = '1')) then
      if (counter = 0) then
       pulse_ena <= '0';
      else
       counter <= counter - 1;
      end if;
     end if;
    end if;
   end if;
  end if;
 end process;

 gen_seq: process(clk)
 begin
  if (rising_edge(clk)) then
   if (dbg_ena = '0') then
    sq <= "00";
   else
    if ((pulse_out = '1') and ((pulse_ena = '1') or (dbg_count = '0'))) then
     if (dbg_dir = '1') then
      case (sq) is
       when "00" => sq <= "01";
       when "01" => sq <= "11";
       when "11" => sq <= "10";
       when "10" => sq <= "00";
       when others => sq <= "00";    
      end case;
     else
      case (sq) is
       when "00" => sq <= "10";
       when "10" => sq <= "11";
       when "11" => sq <= "01";
       when "01" => sq <= "00";
       when others => sq <= "00";    
      end case;
     end if;
    end if;
   end if;
  end if;
 end process;
end Behavioral;
