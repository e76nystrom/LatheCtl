--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:16:04 01/29/2015 
-- Design Name: 
-- Module Name:    PhaseCounter - Behavioral 
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

entity PhaseCounter is
 generic (phase_bits : positive := 16;
          tot_bits : positive := 32);
 port (
  clk : in std_logic;
  ch : in std_logic;
  sync : in std_logic;
  dir : in std_logic;
  init : in std_logic;
  run_sync : in std_logic;
  din : in std_logic;
  dshift : in std_logic;
  phase_sel : in std_logic;
  phasesyn : inout unsigned(phase_bits-1 downto 0);
  totphase : inout unsigned(tot_bits-1 downto 0);
  sync_out : out std_logic);
end PhaseCounter;

architecture Behavioral of PhaseCounter is

 component Shift is
  generic(n : positive);
  port (
   clk : in std_logic;
   shift : in std_logic;
   din : in std_logic;
   data : inout unsigned (n-1 downto 0));
 end component;

 type fsm is (idle, upd_sync, upd_phase, inc_phase, dec_phase,
              clr_phase, set_phase);
 signal state : fsm;

 signal last_syn : std_logic_vector(1 downto 0);

 signal phasectr : unsigned(phase_bits-1 downto 0); --current phase
 signal phaseval : unsigned(phase_bits-1 downto 0); --pulses in one rotation
 signal phase_shift : std_logic;

begin

 phase_shift <= phase_sel and dshift;

 phasereg: Shift
  generic map(phase_bits)
  port map (
   clk => clk,
   shift => phase_shift,
   din => din,
   data => phaseval);

 phase_ctr: process(clk)
 begin
  if (rising_edge(clk)) then
   if (init = '1') then                 --if load
    state <= idle;                      --set sart state
    phasectr <= (phase_bits-1 downto 0 => '0');
    totphase <= (tot_bits-1 downto 0 => '0');
   else
    if (ch = '1') then                  --if clock
     case state is
      when idle =>
       last_syn <= last_syn(0) & sync;
       if (run_sync ='1') then
        state <= upd_sync;
       else
        state <= upd_phase;
       end if;

      when upd_sync =>
       totphase <= totphase + 1;
       state <= upd_phase;

      when upd_phase =>
       if (dir = '1') then
        if (phasectr = phaseval) then
         state <= clr_phase;
        else
         state <= inc_phase;
        end if;
       else
        if (phasectr = 0) then
         state <= set_phase;
        else
         state <= dec_phase;
        end if;
       end if;

      when inc_phase =>
       phasectr <= phasectr + 1;

      when dec_phase =>
       phasectr <= phasectr - 1;

      when clr_phase =>
       phasectr <= (phase_bits-1 downto 0 => '0'); --reset to zero

      when set_phase =>
       phasectr <= phaseval;
     end case;
    end if;
   end if;
  end if;
 end process;
 --phase_ctr: process(clk)
 --begin
 -- if (rising_edge(clk)) then           --if clock active
 --  last_syn <= last_syn(0) & sync;
 --  if (init = '1') then                 --if time to load
 --   phasectr <= (phase_bits-1 downto 0 => '0');
 --   totphase <= (tot_bits-1 downto 0 => '0');
 --  else
 --   if (ch = '1') then                  --if clock active and change
 --    if (run_sync = '1') then           --if synchronized mode
 --     totphase <= totphase + 1;         --count total phase
 --    end if;

 --    if (dir = '1') then                --if encoder turning forward
 --     if (phasectr = phaseval) then     --if at maximum count
 --      phasectr <= (phase_bits-1 downto 0 => '0'); --reset to zero
 --      sync_out <= '1';                 --output sync pulse
 --     else                              --if not at maximum
 --      phasectr <= phasectr + 1;        --increment counter
 --      sync_out <= '0';                 --clear sync pulse
 --     end if;
 --    else                               --if encoder turning backwards
 --     if (phasectr = 0) then            --if at minimum
 --      phasectr <= phaseval;            --reset to maximum
 --      sync_out <= '1';                 --ouput sync pulse
 --     else                              --if not at minimum
 --      phasectr <= phasectr - 1;        --count down
 --      sync_out <= '0';                 --reset sync pulse
 --     end if;
 --    end if;
 --   end if;
 --  end if;
 -- end if;
 --end process;

 -- latch phase counter on external sync pulse

 syn_change: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active and change
   if ((last_syn(0) = '1') and (last_syn(1) = '0')) then --if rising edge
    phasesyn <= phasectr;               --save phase counter
   end if;
  end if;
 end process;

end Behavioral;
