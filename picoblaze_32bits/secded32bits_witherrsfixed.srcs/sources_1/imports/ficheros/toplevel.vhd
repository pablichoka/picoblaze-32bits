library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity toplevel is
        Port (     
--             port_id : out std_logic_vector(7 downto 0);	--solo para depurar
--           write_strobe : out std_logic;	 						--solo para depurar
--            read_strobe : out std_logic;							--solo para depurar
--               out_port : out std_logic_vector(7 downto 0);	--solo para depurar
--                in_port : out std_logic_vector(7 downto 0);	--solo para depurar
					   reset : in std_logic;
					     clk : in std_logic;
				  interrupt : in std_logic;
				         rx : in std_logic;
				         err_en: in std_logic;
				         tx : out std_logic;
				 		  LED : out std_logic; --led de reset
				 		  led_err: out std_logic_vector(1 downto 0));--led de comprobacion 
				 		  	 
end toplevel ;

 architecture behavioral of toplevel is
----------------------------------------------------------------
-- declaracion del picoblaze
----------------------------------------------------------------
  component picoblaze
    Port (      address : out std_logic_vector(10 downto 0);
            instruction : in std_logic_vector(42 downto 0); --ahora mis instrucciones ocupan 43 bits
                port_id : out std_logic_vector(31 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(31 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(31 downto 0);
              interrupt : in std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
    
---------------------------------------------------------------
--Definition of a secded core with RAM
---------------------------------------------------------------
component SECDEDRAM is
    port (clk			: in std_logic;
	      we			: in std_logic;
	      din			: in std_logic_vector (31 downto 0); 
	      address		: in std_logic_vector(31 downto 0);
	      dout		: out std_logic_vector(31 downto 0);
	      error_int	: out std_logic_vector(1 downto 0);
	      switch_err: in std_logic);                  
    end component;

-----------------------------------------------------------------
-- declaraci�n de la ROM de programa
-----------------------------------------------------------------
  component secded_test_32bits
    Port (      address : in std_logic_vector(10 downto 0);
            		 dout : out std_logic_vector(42 downto 0);
                    clk : in std_logic);
    end component;

-----------------------------------------------------------------
-- Signals usadas para conectar el picoblaze y la ROM de programa
-----------------------------------------------------------------
signal     address : std_logic_vector(10 downto 0);
signal instruction : std_logic_vector(42 downto 0);
		
-----------------------------------------------------------------
-- Signals para debugging 
-----------------------------------------------------------------
signal readstrobe: std_logic;
signal writestrobe: std_logic;
signal portid: std_logic_vector(31 downto 0);
signal inport: std_logic_vector(31 downto 0);
signal outport: std_logic_vector(31 downto 0);
signal picoint: std_logic;

signal rxbuff_out: std_logic_vector(31 downto 0);
signal secded_out: std_logic_vector(31 downto 0);
signal secded_err: std_logic_vector(1 downto 0);

begin

	LED <= reset; 	--para comprobar la programacion encendemos
						--	un led cada vez que reseteamos

--	read_strobe <= readstrobe;
--	write_strobe <= writestrobe;
--	port_id <= portid;
--	in_port <= inport;
--	out_port <= outport;
	picoint <= interrupt;
 	
  processor: picoblaze
    port map(      address => address,
               instruction => instruction,
                   port_id => portid,
              write_strobe => writestrobe,
                  out_port => outport,
               read_strobe => readstrobe,
                   in_port => inport,
                 interrupt => picoint,
                     reset => reset,
                       clk => clk);
                       
    secded_ram_core : SECDEDRAM
  port map(clk => clk,
           we => writestrobe,
           din => outport,
           address => portid,
           dout => secded_out,
           error_int => secded_err,
           switch_err => err_en);



  program: secded_test_32bits
    port map(     address => address,
               	   dout => instruction,
                      clk => clk);                                         

    showErr:process(reset, clk)
    begin
        if(reset = '1') then
            led_err <= "00";
        elsif(clk'event and clk= '1')then
               led_err <= secded_err;
        end if;
    end process;

	--registra el bit tx del puerto de salida, por si �ste cambia
	txbuff:process(reset, clk)
	begin
		if (reset='1') then
			tx <= '1';
		elsif rising_edge(clk) then
			if (writestrobe = '1' and portid=x"00001111") then
				tx <= outport(0);	
			end if;
		end if;
	end process;
	
	--a�ade 31 ceros a rx para meterlos al puerto de entrada cuando se lea
	rxbuff:process(reset, clk)
	begin
		if (reset='1') then
			rxbuff_out <= (others=>'1');
		elsif rising_edge(clk) then
			if (readstrobe = '1' and portid=x"00001111") then
				rxbuff_out <= "000000000000000000000000" & rx & "0000000";	--rx & 31 ceros
			end if;		 
		end if;
	end process;
	
	--Multiplexor inport
	mux:
	   inport <= rxbuff_out when (readstrobe = '1' and portid = x"00001111") else
	             secded_out when (readstrobe = '1' and (portid >= x"00000050" and portid < x"00000060")) else
	             x"0000000"&"00"&secded_err when (readstrobe = '1' and portid = x"00000070") else
	               x"00000000";
	
end behavioral;