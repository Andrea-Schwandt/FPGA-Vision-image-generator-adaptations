----------------------------------------------------------------------------------
-- Company: Hochschule Bonn-Rhein-Sieg
-- Engineer: Andrea Schwandt
-- 
-- Create Date: 23.05.2022 15:05:12
-- Design Name: 
-- Module Name: street_arty_z7 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- Originally from Marco Winzker, adapted to arty z7 by Andrea Schwandt
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned architecture
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity street_arty_z7 is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (1 downto 0);
           sw : in STD_LOGIC_VECTOR (1 downto 0);
           hdmi_tx_clk_n : out STD_LOGIC;
           hdmi_tx_clk_p : out STD_LOGIC;
           hdmi_tx_d_n : out STD_LOGIC_VECTOR (2 downto 0);
           hdmi_tx_d_p : out STD_LOGIC_VECTOR (2 downto 0)
 );
end street_arty_z7;

architecture shell of street_arty_z7 is

  signal clk_75  : std_logic := '0';
  signal reset   : std_logic;
  signal reset_a, reset_b, reset_c, reset_d, reset_e : std_logic;
  signal de, hs, vs : std_logic;
  signal r, g, b  : std_logic_vector(7 downto 0);


begin

reset <= BTN(1);

process
begin
  wait until rising_edge(CLK_75);
  if (reset = '1') then
    --clk_25 <= '0';
    reset_a <= '1';
    reset_b <= '1';
    reset_c <= '1';
    reset_d <= '1';
    reset_e <= '1';
  else
    --clk_25 <= not clk_25;
    reset_a <= '0';
    reset_b <= reset_a;
    reset_c <= reset_b;
    reset_d <= reset_c;
    reset_e <= reset_d;
  end if;
  
end process;

-- generic submodule
street: entity work.street_image
    port map (clk_25    => clk_75,
              reset     => reset_e,
              vs_out    => vs,
              hs_out    => hs,
              de_out    => de,
              r_out     => r,
              g_out     => g,
              b_out     => b);
			
hdmi_clk_gen : entity work.clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_75,
  -- Status and control signals                
   reset => reset,
   locked => open,
   -- Clock in ports
   clk_in1 => clk
 );


video: ENTITY work.rgb2dvi_0
  PORT map (
    TMDS_Clk_p => hdmi_tx_clk_p,--: OUT STD_LOGIC;
    TMDS_Clk_n => hdmi_tx_clk_n, --: OUT STD_LOGIC;
    TMDS_Data_p => hdmi_tx_d_p, --: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    TMDS_Data_n => hdmi_tx_d_n, --: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    aRst => reset_e, --: IN STD_LOGIC;
    vid_pData => r & b & g, --: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    vid_pVDE => de, --: IN STD_LOGIC;
    vid_pHSync => hs, --: IN STD_LOGIC;
    vid_pVSync => vs, --: IN STD_LOGIC;
    PixelClk => clk_75); --: IN STD_LOGIC

end shell;
