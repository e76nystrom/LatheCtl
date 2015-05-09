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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DbgData is
 port ( clk : in std_logic;
        dsel : in std_logic;
        dbg_in : in std_logic;
        copy_in : in std_logic;
        shift_in : in std_logic;
        dbg_op : in std_logic;
        op_in : in std_logic;
        copy : out std_logic;
        shift : out std_logic;
        op : out std_logic;
        dbg_dat: out unsigned(15 downto 0)
        );
end DbgData;

architecture Behavioral of DbgData is

begin


end Behavioral;

