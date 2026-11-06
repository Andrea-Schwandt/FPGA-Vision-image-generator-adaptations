----------------------------------------------------------------------------------
-- Company: Hochschule Bonn-Rhein-Sieg
-- Engineer: Andrea Schwandt
-- 
-- Create Date: 23.05.2022 15:05:12
-- Design Name: 
-- Module Name: street_nexys_a7 - Behavioral
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
-- Originally from Marco Winzker, adapted to nexys a7 by Andrea Schwandt
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

entity street_nexys_a7 is
    Port ( CLK100MHZ : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC);
end street_nexys_a7;

architecture shell of street_nexys_a7 is

  signal clk_25  : std_logic := '0';
  signal reset   : std_logic;
  signal clk_divider : unsigned(1 downto 0):= "00";
  signal reset_a, reset_b, reset_c, reset_d, reset_e : std_logic;
  signal r, g, b  : std_logic_vector(7 downto 0);

begin

reset <= BTNC;

process
begin
  wait until rising_edge(CLK100MHZ);
  if (reset = '1') then
    clk_divider <= "00";
    clk_25 <= '0';
    reset_a <= '1';
    reset_b <= '1';
    reset_c <= '1';
    reset_d <= '1';
    reset_e <= '1';
  else
    clk_divider <= clk_divider + 1;
    clk_25 <= clk_divider(1);
    reset_a <= '0';
    reset_b <= reset_a;
    reset_c <= reset_b;
    reset_d <= reset_c;
    reset_e <= reset_d;
  end if;
  
end process;

-- generic submodule
street: entity work.street_image
    port map (clk_25    => clk_25,
              reset     => reset_e,
              vs_out    => vga_vs,
              hs_out    => vga_hs,
              de_out    => open,
              r_out     => r,
              g_out     => g,
              b_out     => b);

vga_r <= r(7 downto 4);
vga_g <= g(7 downto 4);
vga_b <= b(7 downto 4);

end shell;
