--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:07:54 01/30/2015 
-- Design Name: 
-- Module Name:    XRun - Behavioral 
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

entity XRun is
 port ( clk : in std_logic;
        rst : in std_logic;             --reset
        start : in std_logic;           --start axis
        backlash : in std_logic;        --backlash move
        dist_zero : in std_logic;       --distance zero
        load_parm : out std_logic;      --load parameters
        upd_loc : out std_logic;        --update location
        running : out std_logic;        --running
        done_int : out std_logic;       --done interrupt
        info : out unsigned(3 downto 0) --state info
        );
end XRun;

architecture Behavioral of XRun is

-- x run state machine

 type run_fsm is (idle,load,run,done);  -- states
 signal run_state : run_fsm;            --x run state

 function convert(a: run_fsm) return unsigned is
 begin
  case a is
   when idle     => return("0001");
   when load     => return("0010");
   when run      => return("0011");
   when done     => return("0100");
   when others => null;
  end case;
  return("0000");
 end;

begin

 info <= convert(run_state);

 xrun: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (rst = '1') then                  --if time to reset
    --loc_load <= '1';                    --load location counter
    upd_loc <= '0';                     --clear update location flag
    done_int <= '0';                    --clear done interrupt
    running <= '0';                     --clear run flag
    run_state <= idle;                  --set to idle state
   else
    case run_state is                  --select on state
     when idle =>                      --idle state
      if (start = '1') then            --if time to start
       load_parm <= '1';               --set flag to load accel params
       run_state <= load;              --set state to load
      end if;

     when load =>                       --load state
      load_parm <= '0';                 --clear load flag
      running <= '1';                   --set flag to enable accel
      if (backlash = '0') then          --if not a backlash move
       upd_loc <= '1';                  --set to update location
      end if;
      run_state <= run;                 --set state to run
      
     when run =>                        --run state
      if ((dist_zero = '1') or (start = '0')) then --if distance counter zero
       run_state <= done;              --advance to done state
       done_int <= '1';                --set done interrupt
       upd_loc <= '0';                 --stop location updates
       running <= '0';                 --clear run flag
      end if;

     when done =>                       --done state
      if (start ='0') then              --if start flag cleared
       done_int <= '0';                 --clear done interrupt
       run_state <= idle;               --return to idle state
      end if;

     when others => null;
    end case;
   end if;
  end if;
 end process;

end Behavioral;
