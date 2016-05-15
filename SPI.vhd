--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:30:59 01/25/2015 
-- Design Name: 
-- Module Name:    SPI - Behavioral 
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

entity SPI is
 generic (op_bits : positive := 8);
 port (
  clk : in std_logic;                    --system clock
  dclk : in std_logic;                   --spi clk
  dsel : in std_logic;                   --spi select
  din : in std_logic;                    --spi data in
  op : out unsigned(op_bits-1 downto 0); --op code
  copy : out std_logic;                  --copy data to be shifted out
  shift : out std_logic;                 --shift data
  load : out std_logic;                  --load data shifted in
  header : out std_logic;
  info : out std_logic_vector(2 downto 0) --state info
  );
end SPI;

architecture Behavioral of SPI is

 component ClockEnable is
  Port (
   clk : in  std_logic;
   ena : in  std_logic;
   clkena : out std_logic);
 end component;

type spi_fsm is (start, idle, active, chk_count, dec_count, dclk_wait, load_reg);
 signal state : spi_fsm := start;

 signal count : unsigned(2 downto 0) := "000";
 signal opReg : unsigned(op_bits-1 downto 0); --op code
 --signal header : std_logic;

 signal clkena : std_logic;

 function convert(a: spi_fsm) return std_logic_vector is
 begin
  case a is
   when start     => return("111");
   when idle      => return("100");
   when active    => return("000");
   when chk_count => return("001");
   when dec_count => return("101");
   when dclk_wait => return("010");
   when load_reg  => return("011");
   when others    => null;
  end case;
  return("000");
 end;

begin

 info <= convert(state);

 clk_ena: ClockEnable
  port map (
   clk => clk,
   ena => dclk,
   clkena =>clkena);
 
 din_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   case state is
    when start =>
     if (dsel = '1') then
      state <= idle;
     end if;

    when idle =>
     shift <= '0';
     load <= '0';
     copy <= '0';
     if (dsel = '0') then
      header <= '1';
      opReg <= "00000000";
      count <= "111";
      state <= active;
     end if;

    when active =>
     if (dsel = '1') then
      state <= load_reg;
     else
      if (clkena = '1') then
       if (header = '0') then
        shift <= '1';
        state <= dclk_wait;
       else
        opReg <= opReg(op_bits-2 downto 0) & din;
        state <= chk_count;
       end if;
      end if;
     end if;

    when chk_count =>
     if (count = 0) then
      op <= opReg;
      header <= '0';
      copy <= '1';
      state <= dclk_wait;
     else
      state <= dec_count;
     end if;

    when dec_count =>
     count <= count - 1;
     state <= active;
      
    when dclk_wait =>
     shift <= '0';
     copy <= '0';
     state <= active;
 
    when load_reg =>
     load <= '1';
     state <= idle;

   end case;
  end if;
 end process;

end Behavioral;
