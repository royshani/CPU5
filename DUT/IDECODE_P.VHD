---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
----------------- ENTITY ----------------
ENTITY Idecode IS
	generic(
		DATA_BUS_WIDTH : integer := 32
	);
	  PORT(	clk_i,rst_i						: IN 	STD_LOGIC;
	  		instruction_i				 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);	
			dtcm_data_rd_i 					: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- NEED TO FIGURE OUT
			alu_result_i					: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- NEED TO FIGURE OUT
			RegWrite_ctrl_i 				: IN 	STD_LOGIC; -- NEED TO FIGURE OUT (got from execute)
			MemtoReg_ctrl_i 				: IN 	STD_LOGIC;

			read_data_1						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_register_address_0 		: OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			write_register_address_1 		: OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			write_register_address      	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			
			PC_plus_4_shifted				: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			ForwardA_ID, ForwardB_ID		: IN 	STD_LOGIC;
			BranchBeq, BranchBne, Jump, JAL	: IN 	STD_LOGIC; -- NEW Added JAL
			Stall_ID					: IN    STD_LOGIC;
			write_data					: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- NEW changed name from write_data to write_data_wb
			Branch_read_data_FW			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 				: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PCSrc		 				: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			JumpAddr					: OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PCBranch_addr 				: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
END Idecode;
------------ ARCHITECTURE ----------------
ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL register_array					: register_file;
	SIGNAL read_register_1_address			: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address			: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value		: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL read_data_1_sig, read_data_2_sig	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_comp_input_1, read_data_comp_input_2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Opcode							: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL Sign_extend_sig 					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_data_mux_out			    : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- Added NEW 14:15
BEGIN
	Opcode					    <= instruction_i(31 DOWNTO 26 );
	read_register_1_address 	<= instruction_i( 25 DOWNTO 21 );
   	read_register_2_address 	<= instruction_i( 20 DOWNTO 16 );
   	write_register_address_1	<= instruction_i( 15 DOWNTO 11 );
   	write_register_address_0 	<= instruction_i( 20 DOWNTO 16 );
   	Instruction_immediate_value <= instruction_i( 15 DOWNTO 0 );
	
	-------------- Read Register 1 Operation ---------------------------
	read_data_comp_input_1  <=  read_data_1_sig WHEN ForwardA_ID = '0' ELSE Branch_read_data_FW;
	read_data_1_sig			<= register_array(CONV_INTEGER(read_register_1_address));
	read_data_1 			<= read_data_1_sig;
	-------------- Read Register 2 Operation ---------------------------		 
	read_data_comp_input_2 <= read_data_2_sig WHEN ForwardB_ID = '0' ELSE Branch_read_data_FW;
	read_data_2_sig <= register_array(CONV_INTEGER(read_register_2_address));
	read_data_2 	<= read_data_2_sig;
	-------------- PCSrc from Read Register Comp -----------------------
	PCSrc(1) 		<= Jump;
	PCSrc(0) 		<= BranchBeq WHEN ((read_data_comp_input_1 = read_data_comp_input_2) AND Stall_ID = '0') ELSE 
					   BranchBne WHEN ((read_data_comp_input_1 /= read_data_comp_input_2) AND Stall_ID = '0') ELSE '0';  -- Branch Comperator (For bne chen inequality)
	
	-------------  Calc PC Address when branching --------------------
	PCBranch_addr <= PC_plus_4_shifted +  Sign_extend_sig(7 DOWNTO 0);
	JumpAddr	  <= Sign_extend_sig(7 DOWNTO 0) WHEN Opcode(1 DOWNTO 0) = "10" OR Opcode(1 DOWNTO 0) = "11" ELSE
					 read_data_1_sig(7 DOWNTO 0); -- jr
	-------------- Sign Extend 16-bits to 32-bits ----------------------
    Sign_extend_sig <= 	X"0000" & Instruction_immediate_value WHEN Instruction_immediate_value(15) = '0' ELSE
						X"FFFF" & Instruction_immediate_value;
	Sign_extend 	<=	Sign_extend_sig;
	
	-------------  JAL Write Data Mux ---------------------- Added NEW 14:15
	--write_data_mux_out 	<= "000000000000000000000000" & PC_plus_4_shifted WHEN Jal = '1' ELSE write_data_wb;		
	----------- Register File Process ---------------				
	PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clk_i = '0';  -- Changed Clock to work on falling edge
		IF rst_i = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF RegWrite_ctrl_i = '1' AND write_register_address /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address)) <= write_data;  -- NEW 14:15 Changed name from write_data to write_data_wb
		END IF;
	END PROCESS;
END behavior;


