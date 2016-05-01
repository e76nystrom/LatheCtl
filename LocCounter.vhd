--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:00:30 04/11/2015 
-- Design Name: 
-- Module Name:    LocCounter - Behavioral 
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

entity LocCounter is
 generic(loc_bits : positive);
 Port ( clk : in  STD_LOGIC;
        step : in std_logic;         --input step pulse
        dir : in std_logic;          --direction
        upd_loc : in std_logic;      --location update enabled
        din : in std_logic;          --shift data in
        dshift : in std_logic;       --shift clock in
        load : in std_logic;         --load location
        loc_sel : in std_logic;      --location register selected
        loc : inout unsigned(loc_bits-1 downto 0) --current location
        );
end LocCounter;

architecture Behavioral of LocCounter is

 component Shift is
  generic(n : positive);
  port ( clk : in std_logic;
         din : in std_logic;
         shift : in std_logic;
         data : inout unsigned (n-1 downto 0));
 end component;

 component UpDownCounter is
  generic(n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         inc : in std_logic;
         load : in std_logic;
         ini_val : in unsigned(n-1 downto 0);
         counter : inout unsigned(n-1 downto 0));
 end component;

 signal upd_step : std_logic;
 signal loc_shift : std_logic;
 signal loc_in : unsigned(loc_bits-1 downto 0); --location input

begin

 loc_shift <= loc_sel and dshift;
 
 locinreg: Shift
  generic map(loc_bits)
  port map ( clk => clk,
             din => din,
             shift => loc_shift,
             data => loc_in);

 upd_step <= '1' when ((step = '1') and (upd_loc = '1')) else '0';
 
 locreg: UpDownCounter
  generic map(loc_bits)
  port map ( clk => clk,
             ena => upd_step,
             inc => dir,
             load => load,
             ini_val => loc_in,
             counter => loc);

end Behavioral;

