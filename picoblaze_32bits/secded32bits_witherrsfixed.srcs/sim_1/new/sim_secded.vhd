----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.12.2022 17:45:04
-- Design Name: 
-- Module Name: sim_secded - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_secded is
end entity sim_secded;

architecture Behavioral of sim_secded is

component SECDEDRAM is
 Port ( clk : in STD_LOGIC;
          we : in STD_LOGIC;
          din : in STD_LOGIC_VECTOR (31 downto 0);
          address : in STD_LOGIC_VECTOR (31 downto 0);
          switch_err : in STD_LOGIC;
          dout : out STD_LOGIC_VECTOR (31 downto 0);
          error_int : out STD_LOGIC_VECTOR (1 downto 0));
end component;
-- INPUTS
signal clk	: STD_LOGIC:='0';
signal we	: STD_LOGIC:='0';
signal switch_err : STD_LOGIC:='1';
signal din	: std_logic_vector (31 downto 0):=(others=>'0'); 
signal address	: std_logic_vector (31 downto 0):=(others=>'0'); 

-- OUTPUTS
signal dout : std_logic_vector (31 downto 0); 
signal error_int	: std_logic_vector (1 downto 0); 

-- CONSTANTS
constant period : time := 20 ns;

begin

UUT: SECDEDRAM
	port map (	
				clk		 	=> clk,
				we			=> we,
				din			=> din, 
				address		=> address, 
				dout		=> dout,
				switch_err  => switch_err, 
				error_int	=> error_int );
				
	clk <= not clk after period/2;

tb:process
	begin
		we <='0';
		din <= "00000000000000000000000000000001";
		wait for 2*period;
		for i in 0 to 15 loop
			address <= std_logic_vector(to_unsigned(i,4));
			wait for period;
		end loop;
		wait;	
	end process tb;

end Behavioral;
