--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:30:00 04/05/2015 
-- Design Name: 
-- Module Name:    CtlReg - Behavioral 
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

entity CtlReg1 is
 generic(op_bits : positive := 8;
         opVal : unsigned;
         n : positive);
 port (
  clk : in std_logic;                   --clock
  din : in std_logic;                   --data in
  op : unsigned(op_bits-1 downto 0);    --current operation
  shift : in std_logic;                 --shift data
  load : in std_logic;                  --load to data register
  data : inout  unsigned (n-1 downto 0)); --data register
end CtlReg1;

architecture Behavioral of CtlReg1 is

 component OpLatch is
  generic(op_bits : positive := 8;
          opVal : unsigned);
  port (
   clk : in std_logic;
   op : in unsigned(op_bits-1 downto 0);
   opSel : out std_logic);
 end component;

signal sreg : unsigned (n-1 downto 0) := (n-1 downto 0 => '0');
signal ctl_op : std_logic;
signal ctl_shift : std_logic;
signal ctl_load : std_logic;

begin

 latch_proc : OpLatch
 generic map(op_bits, opVal)
  port map(
   clk => clk,
   op => op,
   opSel => ctl_op);

 ctl_shift <= '1' when ((ctl_op = '1') and (shift = '1')) else '0';
 ctl_load <= '1' when ((ctl_op = '1') and (load = '1')) else '0';

ctlreg1: process (clk)
 begin
  if (rising_edge(clk)) then
   if (ctl_load = '1') then          --if load set
    data <= sreg;                    --copy from shift reg to data reg
   else                              --if load not set
    if (ctl_shift = '1') then        --if shift set
     sreg <= sreg(n-2 downto 0) & din; --shift data in
    end if;
   end if;
  end if;
 end process ctlreg1;

end Behavioral;

