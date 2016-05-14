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
 port ( clk : in std_logic;             --system clock
        dclk : in std_logic;            --spi clk
        dsel : in std_logic;            --spi select
        din : in std_logic;             --spi data in
        op : out unsigned(op_bits-1 downto 0); --op code
        copy : out std_logic;           --copy data to be shifted out
        shift : out std_logic;          --shift data
        load : out std_logic            --load data shifted in
        );
end SPI;

architecture Behavioral of SPI is

 component ClockEnable is
  Port ( clk : in  std_logic;
         ena : in  std_logic;
         clkena : out std_logic);
 end component;

type spi_fsm is (start, idle, active, check_count, copy_reg);
--type spi_fsm is (start, idle, active, check_count, copy_reg, load_reg);
--type spi_fsm is (start, idle, active, check_count, copy_reg, dclk_wait);
 signal state : spi_fsm := start;

 signal count : unsigned(3 downto 0) := "0000";
 signal opReg : unsigned(op_bits-1 downto 0); --op code

 signal clkena : std_logic;

begin

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
      opReg <= "00000000";
      count <= x"8";
      state <= active;
     end if;

    when active =>
     if (dsel = '1') then
      load <= '1';
      state <= idle;
      --state <= load_reg;
     else
      shift <= '0';
      copy <= '0';
      if (clkena = '1') then
      --if (dclk = '1') then
       if (count /= x"0") then
        opReg <= opReg(op_bits-2 downto 0) & din;
        count <= count - 1;
        state <= check_count;
       else
        shift <= '1';
        --state <= dclk_wait;
       end if;
      end if;
     end if;

    when check_count =>
     if (count = 0) then
      op <= opReg;
      state <= copy_reg;
     else
      state <= active;
      --state <= dclk_wait;
     end if;

    when copy_reg =>
     copy <= '1';
     state <= active;
     --state <= dclk_wait;

    --when load_reg =>
    -- state <= idle;

    --when dclk_wait =>
    -- shift <= '0';
    -- copy <= '0';
    -- if (dsel = '1') then
    --  load <= '1';
    --  state <= idle;
    -- else
    --  if (dclk = '0') then
    --   state <= active;
    --  end if;
    -- end if;
 
   end case;
  end if;
 end process;

end Behavioral;
