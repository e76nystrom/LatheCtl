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
        dbg_sel : in std_logic;
        a : in std_logic;
        b : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        load : in std_logic;
        freq_sel : in std_logic;
        count_sel : in std_logic;
        a_out : out std_logic;
        b_out : out std_logic;
        dbg_pulse : out std_logic;
        dbg_done: out std_logic);
end DbgClk;

architecture Behavioral of DbgClk is

 component FreqGen
  generic(freq_bits : positive);
  port(
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
  port (
   clk : in std_logic;
   shift : in std_logic;
   din : in std_logic;
   data : inout unsigned(n-1 downto 0));
 end component;

 component DownCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   load : in std_logic;
   preset : in unsigned (n-1 downto 0);
   counter : inout  unsigned (n-1 downto 0);
   zero : out std_logic);
 end component;

 type fsm is (idle, upd_output);
 signal state : fsm;

 signal sq : std_logic_vector(1 downto 0) := "00";
 signal count : unsigned(count_bits-1 downto 0);
 signal counter : unsigned(count_bits-1 downto 0);
 signal freq_shift : std_logic;
 signal count_shift : std_logic;
 signal pulse_out : std_logic;
 signal freq_ena : std_logic;
 signal count_down : std_logic;
 signal count_zero : std_logic;

begin

 freq_shift <= freq_sel and dshift;

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
 
 dbgCtr: DownCounter
  generic map(count_bits)
  port map (
   clk => clk,
   ena => count_down,
   load => load,
   preset => count,
   counter => counter,
   zero => count_zero);

 a_out <= sq(0) when (dbg_sel = '1') else a;
 b_out <= sq(1) when (dbg_sel = '1') else b;

 dbg_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   if (load = '1') then                 --if load
    state <= idle;                      --set sart state
    freq_ena <= '1';                    --start frequency generator
    dbg_done <= '0';                    --clear done flag
   else
    if (dbg_ena = '1') then             --if enabled
     case state is
      when idle =>                      --idle state
       dbg_pulse <= '0';                --clear debug pulse
       if (pulse_out = '1') then        --if clock pulse present
        if (dbg_count = '0') then       --if not using count
         state <= upd_output;
        else                            --if using count
         if (count_zero = '0') then     --if counter non zero
          count_down <= '1';            --set to count down
          state <= upd_output;
         else
          freq_ena <= '0';              --stop frequency generator
          dbg_done <= '1';              --set done flag
         end if;
        end if;
       end if;

      when upd_output =>                --update output
       count_down <= '0';               --clear count down flag
       dbg_pulse <= '1';                --ouput debug pulse
       state <= idle;
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
     end case;
    end if;
   end if;
  end if;
 end process;
end Behavioral;
