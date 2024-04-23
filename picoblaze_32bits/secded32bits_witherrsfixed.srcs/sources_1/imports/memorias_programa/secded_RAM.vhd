-- **********************************************************************
-- 
-- Owner:	Xilinx Inc.
-- File:  	secded.vhd
--
-- Purpose: 	Single error correction and double error detection
--		for memory read/write data.  Parity bits stored in memory 
--		with data bits use the Hamming Code error detection technique.  
--		When reading data from the memory device, single errors are
--		detected and corrected, while double errors are only detected.
--
-- Date:	6-10-02
--
-- **********************************************************************
-- modified sept 2015: jgarrigos. 
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity SECDEDRAM is
port (	
	clk			: in std_logic;
	we			: in std_logic;
	din			: in std_logic_vector (31 downto 0); 
	address		: in std_logic_vector(31 downto 0);
	switch_err  : in std_logic;
	dout		: out std_logic_vector(31 downto 0);
	error_int	: out std_logic_vector(1 downto 0)
	);                  
end entity SECDEDRAM;


architecture BEHAVIOR of SECDEDRAM is
	signal ham : std_logic_vector (5 downto 0); 		-- Generated Hamming Parity bits  
	signal op : std_logic;						-- overall parity bit 
	signal code_2_mem 	: std_logic_vector (38 downto 0);		-- 39-bit data to store in memory 
	
	type ram_type is array (0 to 15) of std_logic_vector (38 downto 0);  -- 2D Array Declaration for RAM signal
	signal ram_mem : ram_type --;
			--P4D7D6D5D4P3D3D2D1P2D0P1P0
				:= ("000000000000000000000000000000000000000","000000000000000000000000000000000000000","000000000000000000000000000000000000000","000000000000000000000000000000000000000", -- no error => error_int=00 
				    "000000000000000000000000000000000000000","000000000000000000000000000000000000000","000000000000000000000000000000000000000","000000000000000000000000000000000000000", -- no error => error_int=00 
				    "000000000000000000000000000000000000000","000000000000000000000000000000000000000", -- no error => error_int=00 
					"000000000000000000000000000000000000000", -- no error => error_int=00 
					"000000000000000000000000000000000000000", -- D0 error (flipped to 1) => error_int=01
					"000000000000000000000000000000010000000", -- P3 error (flipped to 1) => error_int=01
					--"000000000000000000000000000000000000000", -- D5 error (flipped to 1) => error_int=01
					"000000000000000000000000000001100000000", -- D5D4 double error (flipped to 1)=> error_int=10
					"001100110000000000000001000000000000000",  -- P4 error (flipped to 1) => error_int=01 // P5 error (flipped to 0) => error_int=01
                    "100000000000000000000000000000000000000"
					);
	
	signal rd_mem_code 	: std_logic_vector (38 downto 0) ; 	--13-bit data read from memory
	signal rd_data	    : std_logic_vector (31 downto 0);	-- Internal data read from memory
	signal rd_ham 	: std_logic_vector (5 downto 0);	-- Parity read from memory
	signal rd_op    : std_logic; -- op read from memory
	
	signal test_ham 	: std_logic_vector (5 downto 0); 	-- Parity bits  
	signal test_op     : std_logic; -- test op 
	signal syndrome 		: std_logic_vector (5 downto 0);	-- Hamming code syndrome word
	signal op_syndrome  : std_logic; -- op syndrome 
	signal dec_syndrome		: std_logic_vector (31 downto 0); 
	signal corrected_data   : std_logic_vector (31 downto 0);
	--added new signals
	signal data_parity, ham_parity : std_logic;
	signal data_parity_test, ham_parity_test : std_logic; 
	
begin

	-- *******************************************************************
	-- Process: GEN_HAMMING
	-- Purpose: Create Hamming code parity bits: P0, P1, P2, P3, P4, P5
	-- *******************************************************************	
	GEN_HAMMING: process (din)
   	begin
      	-- Create bit parity for single error detection
      	-- Follows hamming code generation rules 
		ham(0) <= din(0) xor din(1) xor din(3) xor din(4) xor din(6) xor din(8) xor din(10) xor din(11) xor din(13) xor din(15) xor din(17) xor din(19) xor din(21) xor din(23) xor din(25) xor din(26) xor din(28) xor din(30);
		ham(1) <= din(0) xor din(2) xor din(3) xor din(5) xor din(6) xor din(9) xor din(10) xor din(12) xor din(13) xor din(16) xor din(17) xor din(20) xor din(21) xor din(24) xor din(25) xor din(27) xor din(28) xor din(31);
		ham(2) <= din(1) xor din(2) xor din(3) xor din(7) xor din(8) xor din(9) xor din(10) xor din(14) xor din(15) xor din(16) xor din(17) xor din(22) xor din(23) xor din(24) xor din(25) xor din(29) xor din(30) xor din(31);
		ham(3) <= din(4) xor din(5) xor din(6) xor din(7) xor din(8) xor din(9) xor din(10) xor din(18) xor din(19) xor din(20) xor din(21) xor din(22) xor din(23) xor din(24) xor din(25);
		ham(4) <= din(11) xor din(12) xor din(13) xor din(14) xor din(15) xor din(16) xor din(17) xor din(18) xor din(19) xor din(20) xor din(21) xor din(22) xor din(23) xor din(24) xor din(25);
		ham(5) <= din(26) xor din(27) xor din(28) xor din(29) xor din(30) xor din(31);
		
   	end process GEN_HAMMING;
   	
   	
   	-- *******************************************************************
	-- Process: GEN_HAMMING_P4
	-- Purpose: Create Hamming code parity bit PB (overall parity)
	-- *******************************************************************	
	GEN_HAMMING_OP: process (ham, din)
   	begin
   		-- Parity of all data and parity bits (overall parity) 
		-- (used for double error detection)
		op <= din(0) xor din(1) xor din(2) xor din(3) xor  din(4) xor din(5) xor din(6) xor din(7)
			  xor din(8) xor din(9) xor din(10) xor din(11) xor  din(12) xor din(13) xor din(14) xor din(15)
			  xor din(16) xor din(17) xor din(18) xor din(19) xor  din(20) xor din(21) xor din(22) xor din(23)
			  xor din(24) xor din(25) xor din(26) xor din(27) xor  din(28) xor din(29) xor din(30) xor din(31)
			  xor ham(0) xor ham(1) xor ham(2) xor ham(3) xor ham(4) xor ham(5);
		-------------------------------------------------------------------------------------------------------
--------↑
		--
-----	↓
--		data_parity <= din(0) xor din(1);
--		for i in 2 to 31 loop
--			data_parity <= data_parity xor din(i);
--		end loop;
		
--		ham_parity <= ham(0) xor ham(1) xor ham(2) xor ham(3) xor ham(4) xor ham(5);
		
--		op <= data_parity xor ham_parity;
		
   	end process GEN_HAMMING_OP;
 
	-- *******************************************************************	
  	-- Process: ASSIGN_MEM_DATA
  	-- Purpose: Assign memory write data.  Combines 32-bit 
  	-- data from processor with 6-bit parity bits.
	-- *******************************************************************	
   	ASSIGN_MEM_DATA: process (ham, op, din)
   	begin
      	code_2_mem(0)  <= ham(0);
      	code_2_mem(1)  <= ham(1);
      	code_2_mem(2)  <= din(0);
      	code_2_mem(3)  <= ham(2);
	    code_2_mem(4)  <= din(1);
	    code_2_mem(5)  <= din(2);
	    code_2_mem(6)  <= din(3);
	    code_2_mem(7)  <= ham(3);
	    code_2_mem(8)  <= din(4);
	    code_2_mem(9)  <= din(5);
	    code_2_mem(10) <= din(6);
	    code_2_mem(11) <= din(7);
	    code_2_mem(12) <= din(8);
		code_2_mem(13) <= din(9);
      	code_2_mem(14) <= din(10);
      	code_2_mem(15) <= ham(4);
      	code_2_mem(16) <= din(11);
	    code_2_mem(17) <= din(12);
	    code_2_mem(18) <= din(13);
	    code_2_mem(19) <= din(14);
	    code_2_mem(20) <= din(15);
	    code_2_mem(21) <= din(16);
	    code_2_mem(22) <= din(17);
	    code_2_mem(23) <= din(18);
	    code_2_mem(24) <= din(19);
	    code_2_mem(25) <= din(20);
		code_2_mem(26) <= din(21);
      	code_2_mem(27) <= din(22);
      	code_2_mem(28) <= din(23);
      	code_2_mem(29) <= din(24);
	    code_2_mem(30) <= din(25);
	    code_2_mem(31) <= ham(5);
	    code_2_mem(32) <= din(26);
	    code_2_mem(33) <= din(27);
	    code_2_mem(34) <= din(28);
	    code_2_mem(35) <= din(29);
	    code_2_mem(36) <= din(30);
	    code_2_mem(37) <= din(31);
	    code_2_mem(38) <= op;
		
		--code_2_mem(12 downto 0) <= op & din(7) & din(6) & din(5) & din(4) & ham(3) & din(3) & din(2) & din(1)
		--			     & ham(2) & din(0) & ham(1) & ham(0);
   	end process ASSIGN_MEM_DATA;

RD_WR_RAM:process (clk)
begin
   if (clk'event and clk = '1') then
      if(address >= x"00000050" and address < x"00000060")then
         if (we = '1') then
            ram_mem(to_integer(unsigned(address(3 downto 0) ))) <= code_2_mem;
         end if;
         rd_mem_code <= ram_mem(to_integer(unsigned(address(3 downto 0) )));
      end if;
   end if;
end process;

	-- *******************************************************************
  	-- Process: READ_MEM_DATA
  	-- Assign internal data and parity bits from memory device
  	-- *******************************************************************
   	READ_MEM_DATA: process (rd_mem_code)
   	begin
		-- Separate data from memory (39-bit wide) 
		-- to internal data (32-bit) and parity (7-bit: 6 hamming + 1 global par)
		rd_data(0)  <= rd_mem_code(2);
		rd_data(1)  <= rd_mem_code(4);
		rd_data(2)  <= rd_mem_code(5);
		rd_data(3)  <= rd_mem_code(6);
		rd_data(4)  <= rd_mem_code(8);
		rd_data(5)  <= rd_mem_code(9);
		rd_data(6)  <= rd_mem_code(10);
		rd_data(7)  <= rd_mem_code(11);
		rd_data(8)  <= rd_mem_code(12);
		rd_data(9)  <= rd_mem_code(13);
		rd_data(10)  <= rd_mem_code(14);
		rd_data(11)  <= rd_mem_code(16);
		rd_data(12)  <= rd_mem_code(17);
		rd_data(13)  <= rd_mem_code(18);
		rd_data(14)  <= rd_mem_code(19);
		rd_data(15)  <= rd_mem_code(20);
		rd_data(16)  <= rd_mem_code(21);
		rd_data(17)  <= rd_mem_code(22);
		rd_data(18)  <= rd_mem_code(23);
		rd_data(19)  <= rd_mem_code(24);
		rd_data(20)  <= rd_mem_code(25);
		rd_data(21)  <= rd_mem_code(26);
		rd_data(22)  <= rd_mem_code(27);
		rd_data(23)  <= rd_mem_code(28);
		rd_data(24)  <= rd_mem_code(29);
		rd_data(25)  <= rd_mem_code(30);
		rd_data(26)  <= rd_mem_code(32);
		rd_data(27)  <= rd_mem_code(33);
		rd_data(28)  <= rd_mem_code(34);
		rd_data(29)  <= rd_mem_code(35);
		rd_data(30)  <= rd_mem_code(36);
		rd_data(31)  <= rd_mem_code(37);
		
		rd_ham(0) <= rd_mem_code(0);
		rd_ham(1) <= rd_mem_code(1);
		rd_ham(2) <= rd_mem_code(3);
		rd_ham(3) <= rd_mem_code(7);
		rd_ham(4) <= rd_mem_code(15);
		rd_ham(5) <= rd_mem_code(31);
		rd_op     <= rd_mem_code(38);
		
  	end process READ_MEM_DATA;
  		
		-- *******************************************************************
	-- Process: GEN_HAMMING
	-- Purpose: Create Hamming code parity bits: P0, P1, P2, P3, P4, P5
	-- *******************************************************************	
	GEN_READ_HAMMING: process (rd_data)
   	begin
      	-- Create bit parity for single error detection
      	-- Follows hamming code generation rules
		test_ham(0) <= rd_data(0) xor rd_data(1) xor rd_data(3) xor rd_data(4) xor rd_data(6) xor rd_data(8) xor rd_data(10) xor rd_data(11) xor rd_data(13) xor rd_data(15) xor rd_data(17) xor rd_data(19) xor rd_data(21) xor rd_data(23) xor rd_data(25) xor rd_data(26) xor rd_data(28) xor rd_data(30);
		test_ham(1) <= rd_data(0) xor rd_data(2) xor rd_data(3) xor rd_data(5) xor rd_data(6) xor rd_data(9) xor rd_data(10) xor rd_data(12) xor rd_data(13) xor rd_data(16) xor rd_data(17) xor rd_data(20) xor rd_data(21) xor rd_data(24) xor rd_data(25) xor rd_data(27) xor rd_data(28) xor rd_data(31);
		test_ham(2) <= rd_data(1) xor rd_data(2) xor rd_data(3) xor rd_data(7) xor rd_data(8) xor rd_data(9) xor rd_data(10) xor rd_data(14) xor rd_data(15) xor rd_data(16) xor rd_data(17) xor rd_data(22) xor rd_data(23) xor rd_data(24) xor rd_data(25) xor rd_data(29) xor rd_data(30) xor rd_data(31);
		test_ham(3) <= rd_data(4) xor rd_data(5) xor rd_data(6) xor rd_data(7) xor rd_data(8) xor rd_data(9) xor rd_data(10) xor rd_data(18) xor rd_data(19) xor rd_data(20) xor rd_data(21) xor rd_data(22) xor rd_data(23) xor rd_data(24) xor rd_data(25);
		test_ham(4) <= rd_data(11) xor rd_data(12) xor rd_data(13) xor rd_data(14) xor rd_data(15) xor rd_data(16) xor rd_data(17) xor rd_data(18) xor rd_data(19) xor rd_data(20) xor rd_data(21) xor rd_data(22) xor rd_data(23) xor rd_data(24) xor rd_data(25);
		test_ham(5) <= rd_data(26) xor rd_data(27) xor rd_data(28) xor rd_data(29) xor rd_data(30) xor rd_data(31);
   	end process GEN_READ_HAMMING;
   	
   	
   	-- *******************************************************************
	-- Process: GEN_OVERALL_PARITY
	-- Purpose: Generate overall parity bit during memory read cycle.
	-- *******************************************************************	
	GEN_OVERALL_PARITY: process (rd_ham, rd_data)
   	begin
   		-- Parity of all data and parity bits (overall parity) 
		-- (used for double error detection)
		test_op <= rd_data(0) xor rd_data(1) xor rd_data(2) xor rd_data(3) xor  rd_data(4) xor rd_data(5) xor rd_data(6) xor rd_data(7)
			  xor rd_data(8) xor rd_data(9) xor rd_data(10) xor rd_data(11) xor  rd_data(12) xor rd_data(13) xor rd_data(14) xor rd_data(15)
			  xor rd_data(16) xor rd_data(17) xor rd_data(18) xor rd_data(19) xor  rd_data(20) xor rd_data(21) xor rd_data(22) xor rd_data(23)
			  xor rd_data(24) xor rd_data(25) xor rd_data(26) xor rd_data(27) xor  rd_data(28) xor rd_data(29) xor rd_data(30) xor rd_data(31)
			  xor rd_ham(0) xor rd_ham(1) xor rd_ham(2) xor rd_ham(3) xor rd_ham(4) xor rd_ham(5);
			  
		-------------------------------------------------------------------------------------------------------
--------↑
		--
-----	↓
--		data_parity_test <= rd_data(0) xor rd_data(1);
--		for i in 2 to 31 loop
--			data_parity_test <= data_parity_test xor rd_data(i);
--		end loop;
		
--		ham_parity_test <= rd_ham(0) xor rd_ham(1) xor rd_ham(2) xor rd_ham(3) xor rd_ham(4) xor rd_ham(5);
		
--		test_op <= data_parity_test xor ham_parity_test;
   	end process GEN_OVERALL_PARITY;
	
	
	-- *******************************************************************
	-- Process: GEN_SYNDROME
	-- Purpose: Generate syndrome (XOR of hamming code parity 
	-- 	    with actual parity bits stored in memory)
	-- *******************************************************************
	GEN_SYNDROME: process (rd_ham, test_ham)
   	begin 	   	
      	syndrome (5 downto 0) <= rd_ham (5 downto 0) xor test_ham (5 downto 0);			   
   	end process GEN_SYNDROME;
	
	GEN_OP_SYNDROME: process (rd_op, test_op)
   	begin 	   	
		op_syndrome <= rd_op xor test_op;
   	end process GEN_OP_SYNDROME;


	-- *******************************************************************
   	-- Process: DETECT_ERROR
   	-- Purpose: Detect error type by comparing value of syndrome and 
   	-- overall_parity (overall parity bit)
	-- *******************************************************************
   	DETECT_ERROR: process (syndrome, op_syndrome)
   	begin
        -- If syndrome = 0 and op_synd = 0 => NO ERROR
        if (syndrome = "000000" and op_syndrome = '0') then
                error_int <= "00";
        -- If syndrome /= 0 and op_synd = 1 => SINGLE ERROR (Correctable)
        -- includes errors in D0-7 (will be corrected) or in P0-3 (no need to correct)
        elsif (syndrome /= "000000" and op_syndrome = '1') then
                error_int <= "01";
        -- If syndrome /= 0 and op_synd = 0 => DOUBLE ERROR (Can not be corrected)
        elsif (syndrome /= "000000" and op_syndrome = '0') then
                error_int <= "10";
        -- If syndrome = 0 and op_synd = 1 => PB(op) ERROR (Correctable, but no need to do it)
        else
                error_int <= "11";
        end if;
   	end process DETECT_ERROR;
   	

	-- *******************************************************************
	-- Process: DECODE_SYNDROME
	-- Purpose: Decode syndrome when SINGLE ERROR occurs in data.  Syndrome
	-- holds data bit number in error.  Create dec_syndrome to hold a '1' in
	-- bit position that needs to be corrected.
	-- *******************************************************************
   	DECODE_SYNDROME: process (syndrome)
   	begin   		
		case syndrome is	
		
			-- optimun code:
			when "000011" => dec_syndrome <= "00000000000000000000000000000001"; --3rd bit => D0 ERROR
			when "000101" => dec_syndrome <= "00000000000000000000000000000010"; --5th bit => D1 ERROR
			when "000110" => dec_syndrome <= "00000000000000000000000000000100"; --6th bit => D2 ERROR
			when "000111" => dec_syndrome <= "00000000000000000000000000001000"; --7th bit => D3 ERROR
			when "001001" => dec_syndrome <= "00000000000000000000000000010000"; --9th bit => D4 ERROR
			when "001010" => dec_syndrome <= "00000000000000000000000000100000"; --10th bit => D5 ERROR
			when "001011" => dec_syndrome <= "00000000000000000000000001000000"; --11th bit => D6 ERROR
			when "001100" => dec_syndrome <= "00000000000000000000000010000000"; --12th bit => D7 ERROR
			when "001101" => dec_syndrome <= "00000000000000000000000100000000"; --13th bit => D8 ERROR
			when "001110" => dec_syndrome <= "00000000000000000000001000000000"; --14th bit => D9 ERROR
			when "001111" => dec_syndrome <= "00000000000000000000010000000000"; --15th bit => D10 ERROR
			when "010001" => dec_syndrome <= "00000000000000000000100000000000"; --17th bit => D11 ERROR
			when "010010" => dec_syndrome <= "00000000000000000001000000000000"; --18th bit => D12 ERROR
			when "010011" => dec_syndrome <= "00000000000000000010000000000000"; --19th bit => D13 ERROR
			when "010100" => dec_syndrome <= "00000000000000000100000000000000"; --20th bit => D14 ERROR
			when "010101" => dec_syndrome <= "00000000000000001000000000000000"; --21th bit => D15 ERROR
			when "010110" => dec_syndrome <= "00000000000000010000000000000000"; --22th bit => D16 ERROR
			when "010111" => dec_syndrome <= "00000000000000100000000000000000"; --23th bit => D17 ERROR
			when "011000" => dec_syndrome <= "00000000000001000000000000000000"; --24th bit => D18 ERROR
			when "011001" => dec_syndrome <= "00000000000010000000000000000000"; --25th bit => D19 ERROR
			when "011010" => dec_syndrome <= "00000000000100000000000000000000"; --26th bit => D20 ERROR
			when "011011" => dec_syndrome <= "00000000001000000000000000000000"; --27th bit => D21 ERROR
			when "011100" => dec_syndrome <= "00000000010000000000000000000000"; --28th bit => D22 ERROR
			when "011101" => dec_syndrome <= "00000000100000000000000000000000"; --29th bit => D23 ERROR
			when "011110" => dec_syndrome <= "00000001000000000000000000000000"; --30th bit => D24 ERROR
			when "011111" => dec_syndrome <= "00000010000000000000000000000000"; --31th bit => D25 ERROR
			when "100001" => dec_syndrome <= "00000100000000000000000000000000"; --33th bit => D26 ERROR
			when "100010" => dec_syndrome <= "00001000000000000000000000000000"; --34th bit => D27 ERROR
			when "100011" => dec_syndrome <= "00010000000000000000000000000000"; --35th bit => D28 ERROR
			when "100100" => dec_syndrome <= "00100000000000000000000000000000"; --36th bit => D29 ERROR
			when "100101" => dec_syndrome <= "01000000000000000000000000000000"; --37th bit => D30 ERROR
			when "100110" => dec_syndrome <= "10000000000000000000000000000000"; --38th bit => D31 ERROR
			when others => dec_syndrome <= "00000000000000000000000000000000"; -- others bits => P0-5 ERROR (1,2,4,8,16,32)
																			   --and not used codes (0,39-63)
			
			-- more explicit/legible code:
--			when "000000" => dec_syndrome <= "00000000000000000000000000000000"; --NO ERROR (or error in global parity P4)
--			when "000001" => dec_syndrome <= "00000000000000000000000000000000"; --1st bit => P0 ERROR
--			when "000010" => dec_syndrome <= "00000000000000000000000000000000"; --2nd bit => P1 ERROR
--			when "000011" => dec_syndrome <= "00000000000000000000000000000001"; --3rd bit => D0 ERROR
--			when "000100" => dec_syndrome <= "00000000000000000000000000000000"; --4th bit => P2 ERROR
--			when "000101" => dec_syndrome <= "00000000000000000000000000000010"; --5th bit => D1 ERROR
--			when "000110" => dec_syndrome <= "00000000000000000000000000000100"; --6th bit => D2 ERROR
--			when "000111" => dec_syndrome <= "00000000000000000000000000001000"; --7th bit => D3 ERROR
--			when "001000" => dec_syndrome <= "00000000000000000000000000000000"; --8th bit => P3 ERROR
--			when "001001" => dec_syndrome <= "00000000000000000000000000010000"; --9th bit => D4 ERROR
--			when "001010" => dec_syndrome <= "00000000000000000000000000100000"; --10th bit => D5 ERROR
--			when "001011" => dec_syndrome <= "00000000000000000000000001000000"; --11th bit => D6 ERROR
--			when "001100" => dec_syndrome <= "00000000000000000000000010000000"; --12th bit => D7 ERROR
--			when "001101" => dec_syndrome <= "00000000000000000000000100000000"; --13th bit => D8 ERROR
--			when "001110" => dec_syndrome <= "00000000000000000000001000000000"; --14th bit => D9 ERROR
--			when "001111" => dec_syndrome <= "00000000000000000000010000000000"; --15th bit => D10 ERROR
--			when "010000" => dec_syndrome <= "00000000000000000000000000000000"; --16th bit => P4 ERROR
--			when "010001" => dec_syndrome <= "00000000000000000000100000000000"; --17th bit => D11 ERROR
--			when "010010" => dec_syndrome <= "00000000000000000001000000000000"; --18th bit => D12 ERROR
--			when "010011" => dec_syndrome <= "00000000000000000010000000000000"; --19th bit => D13 ERROR
--			when "010100" => dec_syndrome <= "00000000000000000100000000000000"; --20th bit => D14 ERROR
--			when "010101" => dec_syndrome <= "00000000000000001000000000000000"; --21th bit => D15 ERROR
--			when "010110" => dec_syndrome <= "00000000000000010000000000000000"; --22th bit => D16 ERROR
--			when "010111" => dec_syndrome <= "00000000000000100000000000000000"; --23th bit => D17 ERROR
--			when "011000" => dec_syndrome <= "00000000000001000000000000000000"; --24th bit => D18 ERROR
--			when "011001" => dec_syndrome <= "00000000000010000000000000000000"; --25th bit => D19 ERROR
--			when "011010" => dec_syndrome <= "00000000000100000000000000000000"; --26th bit => D20 ERROR
--			when "011011" => dec_syndrome <= "00000000001000000000000000000000"; --27th bit => D21 ERROR
--			when "011100" => dec_syndrome <= "00000000010000000000000000000000"; --28th bit => D22 ERROR
--			when "011101" => dec_syndrome <= "00000000100000000000000000000000"; --29th bit => D23 ERROR
--			when "011110" => dec_syndrome <= "00000001000000000000000000000000"; --30th bit => D24 ERROR
--			when "011111" => dec_syndrome <= "00000010000000000000000000000000"; --31th bit => D25 ERROR
--			when "100000" => dec_syndrome <= "00000000000000000000000000000000"; --32th bit => P5 ERROR
--			when "100001" => dec_syndrome <= "00000100000000000000000000000000"; --33th bit => D26 ERROR
--			when "100010" => dec_syndrome <= "00001000000000000000000000000000"; --34th bit => D27 ERROR
--			when "100011" => dec_syndrome <= "00010000000000000000000000000000"; --35th bit => D28 ERROR
--			when "100100" => dec_syndrome <= "00100000000000000000000000000000"; --36th bit => D29 ERROR
--			when "100101" => dec_syndrome <= "01000000000000000000000000000000"; --37th bit => D30 ERROR
--			when "100110" => dec_syndrome <= "10000000000000000000000000000000"; --38th bit => D31 ERROR
--			when others => dec_syndrome <= "00000000000000000000000000000000"; --not used codes (13,14,15) 
		end case;      	
   	end process DECODE_SYNDROME;
   	

	-- *******************************************************************
	-- Process: COR_ERROR
	-- Purpose: Correct any errors in 8-bit data read from memory and
	--    	    assign to processor read bits.
	-- *******************************************************************
	COR_ERROR: process (rd_data, dec_syndrome,switch_err)
    begin
        if(switch_err = '1')then
   		-- XOR data from memory with dec_syndrome
      		corrected_data <= rd_data xor dec_syndrome;
      		--dout <= corrected_data;
      	else
      	    corrected_data <= rd_data;
      	end if;	
   	end process COR_ERROR;
   	
   	dout <= corrected_data;

end architecture BEHAVIOR; 
