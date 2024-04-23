--
------------------------------------------------------------------------------------
--
-- Definition of an 8-bit dual port RAM with 2 ** M locations (M-bit address)
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity register_bank is
	 generic(M: natural);
    Port ( we 		: in std_logic;
           d_bus	: in std_logic_vector(31 downto 0);
           wclk 	: in std_logic;
           a      : in std_logic_vector(M-1 downto 0);
           dpra   : in std_logic_vector(M-1 downto 0);
           spo_bus : out std_logic_vector(31 downto 0);
           dpo_bus : out std_logic_vector(31 downto 0));
end register_bank;

architecture Behavioral of register_bank is

type ram_type is array (0 to (2**M)-1) of std_logic_vector (31 downto 0);
signal RB : ram_type;

begin

	RegisterBank:
	process (wclk)
	begin
		if (wclk'event and wclk = '1') then
			if we = '1' then
				RB(to_integer(unsigned(a))) <= d_bus; -- poner a(1 downto 0) para poder simular 
			end if;
		end if;
	end
	process RegisterBank;

	dpo_bus <= RB(to_integer(unsigned(dpra))); -- poner dpra(1 downto 0) para poder simular
	spo_bus <= RB(to_integer(unsigned(a))); -- poner a(1 downto 0) para poder simular
 
end Behavioral;
