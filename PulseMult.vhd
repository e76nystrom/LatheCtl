--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:11:58 04/20/2015 
-- Design Name: 
-- Module Name:    PulseMult - Behavioral 
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

entity PulseMult is
 generic (n : positive);
 Port ( clk : in  std_logic;
        ch : in std_logic;
        clkOut : out std_logic);
end PulseMult;

architecture Behavioral of PulseMult is

 component ClockEnable is
  Port ( clk : in  std_logic;
         ena : in  std_logic;
         clkena : out std_logic);
 end component;

 component UpCounter is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         clr : in std_logic;
         counter : inout  unsigned (n-1 downto 0));
 end component;

 component DownCounter is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         load : in std_logic;
         preset : in unsigned (n-1 downto 0);
         counter : inout  unsigned (n-1 downto 0);
         zero : out std_logic);
 end component;

 constant mult_bits : integer := 3;
 constant ctr_val : unsigned(mult_bits-1 downto 0) :=
  (mult_bits-1 downto 0 => '1');
 constant ctr_bits : integer := n-mult_bits;

 signal clkEna : std_logic;
 signal inCounter : unsigned(n-1 downto 0) := (n-1 downto 0 => '0');
 signal outCounter : unsigned(n-1 downto 0);
 signal pulseVal : unsigned(ctr_bits-1 downto 0);
 signal pulseTimer : unsigned(ctr_bits-1 downto 0);
 signal remTimer : unsigned(mult_bits-1 downto 0);
 signal pulseCounter : unsigned(mult_bits-1 downto 0);

begin

 clk_ena: ClockEnable
  port map (
   clk => clk,
   ena => ch,
   clkena =>clkEna);
 
 --in_counter: UpCounter
 -- generic map(n)
 -- port map(
 --  clk => clk,
 --  ena => cntEna,
 --  clr => clrIn,
 --  counter => inCounter
 --  );

 --pulse_counter: DownCounter
 -- generic map(ctr_bits)
 -- port map(
 --  clk => clk,
 --  ena => '1',
 --  load => clkEna,
 --  preset => pulseVal,
 --  counter => pulseTimer,
 --  zero => zero
 --  );

  pulseVal <= outCounter(n-1 downto mult_bits) when (remTimer /= 0) else
              outCounter(n-1 downto mult_bits) - 1;

 clk_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   if (clkEna = '1') then
    inCounter <= (n-1 downto 0 => '0');
    outCounter <= inCounter;
   else
    inCounter <= inCounter + 1;
   end if;
  end if;
 end process;

 pulse_proc: process(clk)
 begin
  if (rising_edge(clk)) then
   if (clkEna = '1') then
    pulseTimer <= pulseVal;
    remtimer <= outCounter(mult_bits-1 downto 0);
    pulseCounter <= ctr_val;
    clkOut <= '1';
   else
    if (pulseTimer = 0) then
     pulseTimer <= pulseVal;
     if (pulseCounter /= 0) then
      clkOut <= '1';
      pulseCounter <= pulseCounter - 1;
     end if;
     if (remTimer /= 0) then
      remTimer <= remTimer -1;
     end if;
    else
     clkOut <= '0';
     pulseTimer <= pulseTimer - 1;
    end if;
   end if;
  end if;
 end process;

end Behavioral;

