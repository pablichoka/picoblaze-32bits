------------------------------------------------------------------------------------
--
-- Definition of an 8-bit flip process
-- Operation
--
-- The input operand is flipped
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_rs232 is
    Port (operand : in std_logic_vector(31 downto 0);
          Y : out std_logic_vector(31 downto 0);
          clk : in std_logic);
end shift_rs232;
--
architecture low_level_definition of shift_rs232 is
begin
--  bus_width_loop: for i in 0 to 7 generate
--  begin
     FF:
     process (clk)
      begin
  		if (clk'event and clk = '1') then
         Y <= operand(23 downto 0) & operand(31 downto 24);
		end if;
     end process FF;
--  end generate bus_width_loop;
--
end low_level_definition;
