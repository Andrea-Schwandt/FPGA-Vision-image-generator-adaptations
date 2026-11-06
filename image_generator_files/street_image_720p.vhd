-- street_image.vhd
--
-- generate an VGA-image of a street scene
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 02.05.2019
-- adapted to 720p by Alejandro Nuñez, 26.11.2025

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity street_image is
  port (clk_25   : in  std_logic;
        reset    : in  std_logic;
        vs_out   : out std_logic;
        hs_out   : out std_logic;
        de_out   : out std_logic;
        r_out    : out std_logic_vector(7 downto 0);
        g_out    : out std_logic_vector(7 downto 0);
        b_out    : out std_logic_vector(7 downto 0));
end street_image;

architecture behave of street_image is


-- timing of VGA signal 640 x 480
--   640 x 480 active pixel, 60 Hz, 25.175 MHz pixel frequency
--   vertical timing:   total lines 525, actives lines: 480, vertical front porch: 33; sync: 2, vertical back porch: 10
--   horizontal timing: total pixel 800, actives lines: 640, horizontal front porch: 48; sync: 96, horizontal back porch: 16


-- timing of VGA signal 1280 x 720  (720p)
--   720 x 1280 active pixel, 60 Hz, 74.25 MHz pixel frecuency
--   vertical timing: total lines 750, actives lines: 720, vertical front porch: 5; sync: 5, vertical back porch: 20
--   horizontal timing: total lines 1650, actives lines: 1280; Horizontal front porch: 110, sync: 40; Horizontal back proch: 220

-- rgb values
constant rgb_sky  : std_logic_vector(23 downto 0) := x"A0D0F0";
constant rgb_gras : std_logic_vector(23 downto 0) := x"20C040";
constant rgb_road : std_logic_vector(23 downto 0) := x"808080";
constant rgb_line : std_logic_vector(23 downto 0) := x"FFFF80";

signal h_count   : integer range 0 to  1649 := 0;
signal v_count   : integer range 0 to  749 := 0;
signal frame_num : integer range 0 to 1023 := 0;
signal new_frame : std_logic := '0';

signal center_pos : integer range 0 to 1649;

signal hs_1, vs_1, de_1 : std_logic;
signal hs_2, vs_2, de_2 : std_logic;

signal h_pos_1   : integer range -250 to 1649;
signal v_pos_1   : integer range -250 to 749;
signal h_gap_1                          : integer range    0 to 2047;
signal x_value_a, x_value_b, x_value_c  : integer range    0 to 2047;

signal rgb_2     : std_logic_vector(23 downto 0);


signal v_factor_a   : integer range 0 to 2047;
signal v_factor_b   : integer range 0 to 1023;
signal curve        : integer range -256 to 255;
signal this_curve   : integer range -256 to 255;


begin

-- process for primary counters with reset
process
begin
  wait until rising_edge(clk_25);

  if (reset = '1') then
    h_count     <= 0;
	v_count     <= 0;
	new_frame   <= '0';
    frame_num   <= 500;
  else
	
	new_frame  <= '0'; -- default
	if (h_count = 1649) then
	  h_count <= 0;
	  if ( v_count = 749 ) then
        v_count     <= 0;
        new_frame   <= '1';                
      else
        v_count <= v_count + 1;
      end if; -- v_count
    else  
      h_count <= h_count + 1;
    end if; -- h_count
        
    if (new_frame = '1') then
      if (frame_num = 1023) then
        frame_num <= 0;
      else
        frame_num <= frame_num + 1;
      end if;
    end if;
    
  end if; -- reset
end process;  
        
-- process with pipeline-stages for generation of image content and sync-signals
process
begin
  wait until rising_edge(clk_25);
  
  -- make a parabolic curve, so we calculate
  --    curve is the bend for this frame
  --    factor_a is the vertical position
  --    factor_b is the square of the vertical position

    if    (frame_num <= 400) then
      curve <= 0;
    elsif (frame_num > 400) and (frame_num <= 520) then
      curve <= - (frame_num-400);
    elsif    (frame_num > 620) and (frame_num <= 860) then
      curve <= - 120 + (frame_num-620);
    elsif    (frame_num > 903) then
      curve <= 120 - (frame_num-903);
    end if;
    
  if (v_pos_1 >= 160) and (v_pos_1 < 720) then
    v_factor_a <= 760 - v_pos_1; -- maximum value is 600
  else 
    v_factor_a <= 0;
  end if;
  v_factor_b <= (v_factor_a * v_factor_a)/512; -- maximum value is 703
  -- combine factor_b (depending on the line) and curve (depending on the frame)
  this_curve <= (curve * v_factor_b)/256;
  -- lane is shifted from center of the image (640 pixel plus offset 220)
  center_pos <= 860 + this_curve;
  
  ------------------------------------ pipeline stage 1
  if ( h_count < 40 ) then
    hs_1 <= '1';
  else
    hs_1 <= '0';
  end if;

  if ( v_count < 5 ) then
    vs_1 <= '1';
  else
    vs_1 <= '0';
  end if;

  if ( h_count >= 220 ) and
     ( h_count <  220 + 1280 ) and
     ( v_count >=  20 ) and
     ( v_count <  20 + 720 ) then
    de_1 <= '1';
  else
    de_1 <= '0';
  end if;
    
  h_pos_1 <= h_count - 220;
  v_pos_1 <= v_count -  20;
  
  -- calculate distance of this position from center of the lane
  if (h_count > center_pos) then
    h_gap_1 <= h_count - center_pos;
  else
    h_gap_1 <= center_pos - h_count;
  end if;  

  x_value_a <= v_count/2 + 0;
  x_value_b <= v_count/2 + 5;
  x_value_c <= v_count/2 + 12;
  
  ------------------------------------ pipeline stage 2
  hs_2      <= hs_1;
  vs_2      <= vs_1;
  de_2      <= de_1;
  
  if    (de_1 = '0') then
    rgb_2 <= x"000000";
  elsif (v_pos_1 < 240) then
    rgb_2 <= rgb_sky;
  elsif (h_gap_1 < x_value_a) then
    rgb_2 <= rgb_road;
  elsif (h_gap_1 < x_value_b) then
    rgb_2 <= rgb_line;
  elsif (h_gap_1 < x_value_c) then
    rgb_2 <= rgb_road;
  else
    rgb_2 <= rgb_gras;
  end if;  
  
  ------------------------------------ pipeline stage 3
  hs_out  <= hs_2;
  vs_out  <= vs_2;
  de_out  <= de_2;
  r_out   <= rgb_2(23 downto 16);
  g_out   <= rgb_2(15 downto  8);
  b_out   <= rgb_2( 7 downto  0);
  
end process;

end behave;
