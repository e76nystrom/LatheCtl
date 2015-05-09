--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:21:14 01/28/2015 
-- Design Name: 
-- Module Name:    ZRun - Behavioral 
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

entity ZRun is
  port ( clk : in std_logic;            --input clock
        init : in std_logic;            --reset
        start : in std_logic;           --start axis
        backlash : in std_logic;        --backlash move
        sync : in std_logic;            --sync pulse
        wait_syn : in std_logic;        --synchronized motion
        dist_zero : in std_logic;       --distance zero
        load_parm : out std_logic;      --load parameters
        upd_loc : out std_logic;        --update location
        running : out std_logic;        --running
        done_int : out std_logic;       --done interrupt
        info : out unsigned(3 downto 0) --state info
        );
end ZRun;

architecture Behavioral of ZRun is

 type run_fsm is (idle,load,synwait,run,done);
 signal run_state : run_fsm;         --z run state variable

 function convert(a: run_fsm) return unsigned is
 begin
  case a is
   when idle    => return("0001");
   when load    => return("0010");
   when synwait => return("0011");
   when run     => return("0100");
   when done    => return("0101");
   when others  => null;
  end case;
  return("0000");
 end;

begin

 info <= convert(run_state);

 z_run: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --if time to set new locaton
    run_state <= idle;                  --clear state
    done_int <= '0';                    --clear interrupt
    running <= '0';                     --clear run flag
    upd_loc <= '0';
   else                                 --if normal operation
    case run_state is                   --check state
     when idle =>                       --idle state
      if (start = '1') then             --if start requested
       run_state <= load;               --advance to load state
       load_parm <= '1';                --set flag to load accel and sync
      end if;

     when load =>                       --load state
      load_parm <= '0';                 --clear load flag
      if (wait_syn = '1') then          --if wating for sync
       run_state <= synwait;            --advance to wait for sync state
      else                              --if not synchronous move
       run_state <= run;                --advance to run state
       running <= '1';                  --set run flag
       if (backlash = '0') then         --if not a backlash move
        upd_loc <= '1';                 --enable location update
       end if;
      end if;

     when synwait =>                    --sync wait state
      if (start = '0') then             --if start flag cleared
       run_state <= idle;               --return to idle
      else                              --if start flag set
       if (sync = '1') then             --if time to sync
        run_state <= run;               --advance to run state
        running <= '1';                 --set run flag
        upd_loc <= '1';                 --enable location update
       end if;
      end if;
      
     when run =>                        --run state
      if ((dist_zero = '1') or (start = '0')) then --if distance counter zero
       run_state <= done;              --advance to done state
       done_int <= '1';                --set done interrupt
       upd_loc <= '0';                 --stop location updates
       running <= '0';                 --clear run flag
      end if;

     when done =>                       --done state
      if (start = '0') then             --wait for start flag to clear
       done_int <= '0';                 --clear done intterrupt
       run_state <= idle;               --to return to idle state
      end if;

     when others => null;               --all other states
    end case;
   end if;
  end if;
 end process;

end Behavioral;

