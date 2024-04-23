----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2023 12:16:56
-- Design Name: 
-- Module Name: toplevel_tb - Behavioral
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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel_tb is
end entity toplevel_tb;

architecture Behavioral of toplevel_tb is

component toplevel is

 Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           interrupt : in STD_LOGIC;
           rx : in STD_LOGIC;
           err_en : in STD_LOGIC;
           tx : out STD_LOGIC;
           LED : out STD_LOGIC;
           led_err : out STD_LOGIC_VECTOR (1 downto 0));
           
end component;

--INPUTS
signal reset : STD_LOGIC := '0';
signal clk : STD_LOGIC := '0';
signal interrupt : STD_LOGIC := '0';
signal rx : STD_LOGIC := '0';
signal err_en : STD_LOGIC := '1';

--OUTPUTS
signal tx : STD_LOGIC;
signal LED : STD_LOGIC;
signal led_err : STD_LOGIC_VECTOR (1 downto 0);

-- CONSTANTS
constant period : time := 10 ns;

begin

UUT: toplevel
	port map (	
				clk		 	=> clk,
				reset		=> reset,
				interrupt	=> interrupt, 
				rx		    => rx, 
				err_en		=> err_en,
				tx          => tx, 
				LED     	=> LED,
				led_err     => led_err );
				
	clk <= not clk after period/2;

tb:process
	begin
		wait for 1us;
		reset <= '1';
		wait for 1us;
		reset <= '0';
		wait;
	end process tb;

end Behavioral;
