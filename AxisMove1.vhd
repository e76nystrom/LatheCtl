--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:55:27 01/25/2015 
-- Design Name: 
-- Module Name:    AxisMove1 - Behavioral 
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

entity AxisMove1 is
 generic (accel_bits : positive);
 port ( clk : in std_logic;
        init : in std_logic;
        ena : in std_logic;
        decel: in std_logic;
        done : in std_logic;
        step : in std_logic;
        din : in std_logic;
        dshift : in std_logic;
        minv_sel : in std_logic;
        maxv_sel : in std_logic;
        accel_sel : in std_logic;
        freq_sel : in std_logic;
        velocity : inout unsigned(accel_bits-1 downto 0);
        nxt : inout unsigned(accel_bits-1 downto 0);
        stepOut : inout std_logic;
        accelFlag : out std_logic;
        info : out unsigned(3 downto 0)
        );
end AxisMove1;

architecture Behavioral of AxisMove1 is

 component Shift is
  generic (n : positive);
  port ( clk : in std_logic;
         din : in std_logic;
         shift : in std_logic;
         data : inout  unsigned (n-1 downto 0));
 end component;

 component DataSel2 is
  generic (n : positive);
  port ( sel : in std_logic;
         data0 : in  unsigned (n-1 downto 0);
         data1 : in  unsigned (n-1 downto 0);
         data_out : out  unsigned (n-1 downto 0));
 end component;

 component Adder is
  generic (n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         load : in std_logic;
         func : in std_logic;
         a : in  unsigned (n-1 downto 0);
         sum : inout  unsigned (n-1 downto 0));
 end component;

 component Compare is
  generic (n : positive);
  port ( a : in  unsigned (n-1 downto 0);
         b : in  unsigned (n-1 downto 0);
         cmp_ge : in std_logic;
         cmp : out std_logic);
 end component;

 signal minvel : unsigned(accel_bits-1 downto 0);
 signal maxvel : unsigned(accel_bits-1 downto 0);
 signal accl   : unsigned(accel_bits-1 downto 0);
 signal freq   : unsigned(accel_bits-1 downto 0);

 signal minv_shift : std_logic;
 signal maxv_shift : std_logic;
 signal accl_shift : std_logic;
 signal freq_shift : std_logic;

 signal minmax_sel : std_logic;
 signal min_max : unsigned(accel_bits-1 downto 0);

 signal iniaccel_sel : std_logic;
 signal ini_accel : unsigned(accel_bits-1 downto 0);

 signal vel_ena : std_logic;
 signal vel_load : std_logic;
 signal vel_add : std_logic;

 signal velfreq_sel : std_logic;
 signal vel_freq : unsigned(accel_bits-1 downto 0);

 signal nxt_ena : std_logic;
 signal nxt_load : std_logic;
 signal nxt_add : std_logic;
 
 signal vel_ge_minmax : std_logic;
 signal vel_cmp_minmax : std_logic;
 
--  acceleration state machine states and variables
 
 type fsm is (initial,firstStep,waitStep,stepStart,chk_max,
              chk_min,upd_nxt,upd_done,chk_step,end_step);
 signal state : fsm := initial;         --acceleration state variable

 type accelMode is (f_run,f_accel,f_decel,f_done);
 signal accel_mode : accelMode := f_accel;

 function convert(a : accelMode) return unsigned is
 begin
  case a is
   when f_accel => return("0001");
   when f_run   => return("0010");
   when f_decel => return("0100");
   when f_done  => return("1000");
   when others  => null;
  end case;
  return("0000");
 end;

begin

 info <= convert(accel_mode);

 minv_shift <= minv_sel and dshift;

 minvreg: Shift
  generic map(accel_bits)
  port map (
   clk => clk,
   din => din,
   shift => minv_shift,
   data => minvel);

 maxv_shift <= maxv_sel and dshift;

 maxreg: Shift
  generic map(accel_bits)
  port map (
   clk => clk,
   din => din,
   shift => maxv_shift,
   data => maxvel);

 accl_shift <= accel_sel and dshift;

 acclreg: Shift
  generic map(accel_bits)
  port map (
   clk => clk,
   din => din,
   shift => accl_shift,
   data => accl);

 freq_shift <= freq_sel and dshift;

 freqreg: Shift
  generic map(accel_bits)
  port map (
   clk => clk,
   din => din,
   shift => freq_shift,
   data => freq);

 minmaxmux: DataSel2
  generic map(accel_bits)
  port map (
   sel => minmax_sel,
   data0 => minvel,
   data1 => maxvel,
   data_out => min_max);

 iniacclmux: DataSel2
  generic map(accel_bits)
  port map (
   sel => iniaccel_sel,
   data0 => min_max,
   data1 => accl,
   data_out => ini_accel);

 accladd: Adder
  generic map(accel_bits)
  port map (
   clk => clk,
   ena => vel_ena,
   load => vel_load,
   func => vel_add,
   a => ini_accel,
   sum => velocity);

 velfreqmux:  DataSel2
  generic map(accel_bits)
  port map (
   sel => velfreq_sel,
   data0 => velocity,
   data1 => freq,
   data_out => vel_freq);
 
 nxtadd: Adder
  generic map(accel_bits)
  port map (
   clk => clk,
   ena => nxt_ena,
   load => nxt_load,
   func => nxt_add,
   a => vel_freq,
   sum => nxt);

 velcmp: Compare
  generic map(accel_bits)
  port map (
   a => velocity,
   b => min_max,
   cmp_ge => vel_ge_minmax,
   cmp => vel_cmp_minmax);

 accel_proc: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --if time to initialize
    stepOut <= '0';                     --clear step output
    accel_mode <= f_accel;              --set mode to accelerate
    accelFlag <= '1';                   --set to count accel steps
    minmax_sel <= '0';                  --select min vel
    vel_ge_minmax <= '1';               --set to compare ge
    iniaccel_sel <= '0';                --initial value
    vel_add <= '1';                     --set for addition
    vel_load <= '1';                    --set to load velocity
    vel_ena <= '1';                     --enable accumulator
    velfreq_sel <= '1';
    nxt_load <= '1';
    nxt_ena <= '1';
    nxt_add <= '0';                     --set to subtract mode
   else                                 --if running
    case state is
     when initial =>                    --initial state
      if (ena = '1' and step = '1') then --if enabled and a step
       stepOut <= '1';                  --output first step pulse
       state <= firstStep;              --advance to end pulse
      end if;
      
     when firstStep =>                  --end first step pulse
      stepOut <= '0';                   --turn of step pulse
      state <= stepStart;               --advance to start of step

     when waitStep =>                   --wait for a step
      if (ena = '0') then               --if enabled cleared
       state <= initial;                --return to initial state
      else
       if (step = '1' and done ='0') then --if step and not at end
        state <= stepStart;             --start a step
       end if;
      end if;

     when stepStart =>                  --start a step
      velfreq_sel <= '0';
      vel_load <= '0';
      vel_ena <= '0';
      nxt_load <= '0';
      nxt_ena <= '0';
      case accel_mode is
       when f_run =>                    --run mode
        state <= upd_nxt;               --update next

       when f_done =>                   --done mode
        state <= upd_nxt;               --update next

       when f_accel =>                  --accel mode
        vel_add <= '1';                 --set to add velocity
        vel_ge_minmax <= '1';           --set to compare gt or eq
        minmax_sel <= '1';              --select to check max
        state <= chk_max;               --check for maximum

       when f_decel =>                  --decel mode
        vel_add <= '0';                 --set to subtract velocity
        vel_ge_minmax <= '0';           --set to compare lt or eq
        minmax_sel <= '0';              --select to check min
        state <= chk_min;               --check for minimum

       when others => null;
      end case;

     when chk_max =>                    --check for max velocity
      if (vel_cmp_minmax = '1') then    --if velocity at maximum
       iniaccel_sel <= '0';             --set to select min or max
       vel_load <= '1';                 --set to load
       accel_mode <= f_run;             --set to run mode
       accelFlag <= '0';                --stop counting accel steps
      else
       iniaccel_sel <= '1';             --set to select acceleration
      end if;
      vel_ena <= '1';                   --load or add to velocity
      state <= upd_nxt;                 --advance to update next

     when chk_min =>                    --check for min velocity
      if (vel_cmp_minmax = '1') then    --if velocity at minimum
       iniaccel_sel <= '0';             --set to select min or max
       vel_load <= '1';                 --set to load
       accel_mode <= f_done;            --set to done
      else
       iniaccel_sel <= '1';             --set to select acceleration
      end if;
      vel_ena <= '1';                   --load or sub from velocity
      state <= upd_nxt;                 --advance to update next

     when upd_nxt =>                    --update next
      vel_ena <= '0';                   --end velocity update
      nxt_ena <= '1';
      state <= upd_done;                --wait before checking next

     when upd_done =>                   --update done
      nxt_ena <= '0';                   --disable adder
      state <= chk_step;

     when chk_step =>                   --check for time to step
      if (nxt(accel_bits-1) = '1') then --if time to output a step
       velfreq_sel <= '1';              --select frequency
       nxt_add <= '1';                  --set to add freq
       nxt_ena <= '1';                  --enable operation
       stepOut <= '1';                  --output a step pulse
      end if;
      state <= end_step;                --end step if one started

     when end_step =>                   --end step pulse
      nxt_ena <= '0';                   --clear operation enable
      stepOut <= '0';                   --end step pulse
      if (decel = '1') then             --if time to decelerate
       accel_mode <= f_decel;           --set to decelerate move
      end if;
      if (step = '0') then              --if input step done
       state <= waitStep;               --return to initial state
      end if;

     when others => null;
    end case;
   end if;
  end if;
 end process;
end Behavioral;

--z_accel_proc: process(ck_z)
--begin
-- if (rising_edge(ck_z)) then            --if clock active
--  if ((zrst = '1') or (zload_flag = '1')) then --if time to load
--   zvelocity <= zminvel;                --set velocity to minimum
--   znxt <= zfreq;                       --set next to frequecny value
--   zaccel_flag <= f_accel;              --set mode to accelerate
--   zastp <= '0';                        --clear step flag
--   zaccel_state <= initial;             --make sure in initial state
--   zaccel_steps <= x"0000";             --clear step counter
--  else                                  --if running
--   case zaccel_state is
--    when initial =>
--     if ((zrun_flag = '1') and (zclkena = '1')) then
--      case zaccel_flag is
--       when f_run =>
--        zaccel_state <= upd_next;
--       when f_done =>
--        zaccel_state <= upd_next;
--       when f_accel => 
--        zaccel_state <= upd_accel;
--       when f_decel => 
--        zaccel_state <= upd_decel;
--       when others => null;
--      end case;
--     end if;

--    when upd_accel =>
--     zvelocity <= zvelocity + zaccl;
--     zaccel_state <= chk_max;

--    when chk_max =>
--     if (zvelocity >= zmaxvel) then
--      zvelocity <= zmaxvel;
--      zaccel_flag <= f_run;
--      zaccel_steps <= zaccel_steps + 1;
--     end if;
--     zaccel_state <= upd_next;

--    when upd_decel =>
--     zvelocity <= zvelocity - zaccl;
--     zaccel_state <= chk_min;

--    when chk_min =>
--     if (zvelocity <= zminvel) then
--      zaccel_flag <= f_done;
--     end if;
--     zaccel_state <= upd_next;

--    when upd_next =>
--     znxt <= znxt - zvelocity;
--     zaccel_state <= chk_step;

--    when chk_step =>
--     if (znxt < 0) then
--      znxt <= znxt + zfreq;
--      zastp <= '1';
--      if (zaccel_flag = f_accel) then
--       zaccel_steps <= zaccel_steps + 1;
--      end if;
--     end if;
--     zaccel_state <= end_step;

--    when end_step =>
--     zastp <= '0';
--     if (zaccel_flag = f_done) then
--      zaccel_state <= chk_enable;
--     else
--      zaccel_state <= chk_decel;
--     end if;

--    when chk_decel =>
--     if (zdistctr <= zaccel_steps) then
--      zaccel_flag <= f_decel;
--     end if;
--     zaccel_state <= chk_enable;

--    when chk_enable =>
--     if (zclkena = '0') then
--      zaccel_state <= initial;
--     end if;

--    when others => null;
--   end case;
--  end if;
-- end if;
--end process;
