--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:48:10 05/04/2016
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/LatheCtl/SPITest1.vhd
-- Project Name:  LatheCtl
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPI
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SPITest1 IS
END SPITest1;
 
ARCHITECTURE behavior OF SPITest1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI
    PORT(
         clk : IN  std_logic;
         dclk : IN  std_logic;
         dsel : IN  std_logic;
         din : IN  std_logic;
         op : INOUT  std_logic_vector(7 downto 0);
         copy : OUT  std_logic;
         shift : OUT  std_logic;
         load : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal dclk : std_logic := '0';
   signal dsel : std_logic := '0';
   signal din : std_logic := '0';

	--BiDirs
   signal op : std_logic_vector(7 downto 0);

 	--Outputs
   signal copy : std_logic;
   signal shift : std_logic;
   signal load : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant dclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI PORT MAP (
          clk => clk,
          dclk => dclk,
          dsel => dsel,
          din => din,
          op => op,
          copy => copy,
          shift => shift,
          load => load
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   dclk_process :process
   begin
		dclk <= '0';
		wait for dclk_period/2;
		dclk <= '1';
		wait for dclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
