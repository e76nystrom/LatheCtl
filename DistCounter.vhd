--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:12:01 04/22/2015 
-- Design Name: 
-- Module Name:    DistCounter - Behavioral 
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

entity DistCounter is
 generic (dist_bits : positive);
 Port (
  clk : in  std_logic;
  accelFlag : in std_logic;             --acceleration step
  step : in std_logic;                  --all steps
  init : in std_logic;                  --reset
  din : in std_logic;
  dshift : in std_logic;
  dist_sel : in std_logic;
  distCtr : inout unsigned(dist_bits-1 downto 0);
  aclSteps : inout unsigned(dist_bits-1 downto 0);
  decel : inout std_logic;              --dist le acceleration steps
  dist_zero : out std_logic             --distance zero
  );
end DistCounter;

architecture Behavioral of DistCounter is

 component Compare is
  generic (n : positive);
  port (
   a : in  unsigned (n-1 downto 0);
   b : in  unsigned (n-1 downto 0);
   cmp_ge : in std_logic;
   cmp : out std_logic);
 end component;

 component UpCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   clr : in std_logic;
   counter : inout  unsigned (n-1 downto 0));
 end component;

 component RegCtr is
  generic(n : positive);
  port (
   clk : in std_logic;
   ld_ena : in std_logic;
   shift_in : in std_logic;
   ct_ena : in std_logic;
   load : in std_logic;
   data : inout  unsigned (n-1 downto 0);
   zero : inout std_logic);
 end component;

 signal accelStep : std_logic;

 signal distzero : std_logic;
 signal dist_shift : std_logic;

begin

 accelStep <= '1' when ((accelFlag = '1') and (step = '1') and (decel = '0'))
              else '0';

 stpctr: UpCounter
  generic map(dist_bits)
  port map (
   clk => clk,
   ena => accelStep,
   clr => init,
   counter => aclSteps);

 dist_shift <= dist_sel and dshift;

 distreg: RegCtr
  generic map(dist_bits)
  port map (
   clk => clk,
   ld_ena => dist_shift,
   shift_in => din,
   ct_ena => step,
   load => init,
   data => distCtr,
   zero => distzero);

 dist_zero <= distzero;

 distcmp: Compare
  generic map(dist_bits)
  port map (
   a => distCtr,
   b => aclSteps,
   cmp_ge => '0',
   cmp => decel);

end Behavioral;
