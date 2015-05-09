----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:15:31 04/07/2015 
-- Design Name: 
-- Module Name:    DbgData - Behavioral 
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DbgData is
 generic ( data_bits : integer := 16;
           op_bits : integer := 8);
 port ( clk : in std_logic;
        sample : in std_logic;
        dbg_in : in std_logic;
        dbg_op : in unsigned(op_bits-1 downto 0);
        dsel : in std_logic;
        copy_in : in std_logic;
        shift_in : in std_logic;
        op_in : in unsigned(op_bits-1 downto 0);
        din : in std_logic;
        copy : out std_logic;
        shift : out std_logic;
        op : out unsigned(op_bits-1 downto 0);
        dbg_dat: inout unsigned(data_bits-1 downto 0)
        );
end DbgData;

architecture Behavioral of DbgData is

 type dbg_fsm is (start, idle, spi_busy, copy_dat, shift_dat, load_dat);
 signal state : dbg_fsm := start;

 constant count_len : integer := integer(CEIL(LOG2(Real(data_bits)))); 
 signal count : unsigned(count_len downto 0) := (count_len downto 0 => '0');
 signal spi : std_logic;
 signal dbg_cpy : std_logic;
 signal dbg_shift : std_logic;
 signal last_sample : std_logic;
 signal tmp_dat :  unsigned(data_bits-1 downto 0) := (data_bits-1 downto 0 => '0');

begin

 copy <= copy_in when (spi = '1') else
         dbg_cpy;
 shift <= shift_in when (spi = '1') else
          dbg_shift;
 op <= op_in when (spi = '1') else
       dbg_op;

 dbg_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   case state is
    when start =>
     state <= idle;

    when idle =>
     spi <= '1';
     dbg_shift <= '0';
     if (dsel = '0') then
      state <= spi_busy;
     else
      if (sample ='1' and last_sample = '0') then
       state <= copy_dat;
       spi <= '0';
       dbg_cpy <= '1';
      end if;
     end if;

    when spi_busy =>
     if (dsel = '1') then
      state <= idle;
     end if;

    when copy_dat =>
     if (dsel = '0') then
      spi <= '1';
      state <= spi_busy;
     end if;
     dbg_cpy <= '0';
     dbg_shift <= '1';
     count <= to_unsigned(data_bits,count_len+1);
     tmp_dat <= (data_bits-1 downto 0 => '0');
     state <= shift_dat;

    when shift_dat =>
     if (dsel = '0') then
      spi <= '1';
      state <= spi_busy;
     end if;
     tmp_dat <= din & tmp_dat(data_bits-1 downto 1);
     count <= count - 1;
     if (count = "0") then
      state <= load_dat;
     end if;

    when load_dat =>
     dbg_dat <= tmp_dat;
     state <= idle;

   end case;
   last_sample <= sample;
  end if;
 end process;

end Behavioral;
