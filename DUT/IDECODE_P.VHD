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
	  		instruction_i				 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- both	
			dtcm_data_rd_i 					: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- NEED TO FIGURE OUT
			alu_result_i					: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- NEED TO FIGURE OUT
			RegWrite_ctrl_i 				: IN 	STD_LOGIC; --assigned to PCSRC
			MemtoReg_ctrl_i 				: IN 	STD_LOGIC; --assigned to PCSRC
			PC_plus_4_shifted				: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);	-- G	
			ForwardA_ID, ForwardB_ID		: IN 	STD_LOGIC; -- G signals from Forward
			BranchBeq, BranchBne, Jump, JAL	: IN 	STD_LOGIC; -- G signals for jump clasiffication
			Stall_ID						: IN    STD_LOGIC; -- G for stall
			write_data_i					: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- NEW changed name from write_data to write_data_wb
			Branch_read_data_FW				: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_register_address      	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );

			read_data1_o						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); --both
			read_data2_o						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); --both
			write_register_address_0 		: OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			rd_register_w 				: OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- SIGNAL AT H
			sign_extend_o 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); --both
			PCSrc		 					: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0); -- G
			JumpAddr						: OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 ); 
			PCBranch_addr 					: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0)
			);
END Idecode;
------------ ARCHITECTURE ----------------
ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL RF_q						: register_file; -- both
	SIGNAL rs_register_w			: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); --both
	SIGNAL rt_register_w			: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); --both
	SIGNAL imm_value_w				: STD_LOGIC_VECTOR( 15 DOWNTO 0 ); --both
	SIGNAL read_data_1_sig, read_data_2_sig	: STD_LOGIC_VECTOR(31 DOWNTO 0); -- G
	SIGNAL read_data_comp_input_1, read_data_comp_input_2	: STD_LOGIC_VECTOR(31 DOWNTO 0); -- G meant for branch prediction
	SIGNAL Opcode							: STD_LOGIC_VECTOR(5 DOWNTO 0); -- G
	SIGNAL Sign_extend_sig 					: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- G
	SIGNAL write_reg_data_w			    : STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
BEGIN
	Opcode			<= instruction_i(31 DOWNTO 26 );
	rs_register_w 	<= instruction_i( 25 DOWNTO 21 ); -- both
   	rt_register_w 	<= instruction_i( 20 DOWNTO 16 ); -- both
   	rd_register_w	<= instruction_i( 15 DOWNTO 11 ); -- both
   	write_register_address_0 	<= instruction_i( 20 DOWNTO 16 );
   	imm_value_w <= instruction_i( 15 DOWNTO 0 );
	
	-------------- Read Register 1 Operation - Rtype ---------------------------
	read_data_comp_input_1  <=  read_data_1_sig WHEN ForwardA_ID = '0' ELSE Branch_read_data_FW;
	read_data_1_sig			<= RF_q(CONV_INTEGER(rs_register_w)); -- consider in 1 line
	read_data1_o 			<= read_data_1_sig;
	-------------- Read Register 2 Operation - Rtype ---------------------------		 
	read_data_comp_input_2 <= read_data_2_sig WHEN ForwardB_ID = '0' ELSE Branch_read_data_FW;
	read_data_2_sig <= RF_q(CONV_INTEGER(read_register_2_address)); -- consider in 1 line
	read_data2_o 	<= read_data_2_sig;
	-------------- PCSrc from Read Register Comp -----------------------
	PCSrc(1) 		<= Jump;
	-- this branch prediction happens before execute in order to decide branching in earlier stage in the cost of extra hardware
	PCSrc(0) 		<= BranchBeq WHEN ((read_data_comp_input_1 = read_data_comp_input_2) AND Stall_ID = '0') ELSE 
					   BranchBne WHEN ((read_data_comp_input_1 /= read_data_comp_input_2) AND Stall_ID = '0') ELSE '0';  -- Branch Comperator (For bne chen inequality)
	
	-------------  Calc PC Address when branching --------------------
	PCBranch_addr <= PC_plus_4_shifted +  Sign_extend_sig(7 DOWNTO 0);
	JumpAddr	  <= Sign_extend_sig(7 DOWNTO 0) WHEN Opcode(1 DOWNTO 0) = "10" OR Opcode(1 DOWNTO 0) = "11" ELSE
					 read_data_1_sig(7 DOWNTO 0); -- jr
	-------------- Sign Extend 16-bits to 32-bits ----------------------
    Sign_extend_sig <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;
	sign_extend_o 	<=	Sign_extend_sig;
	
	-------------  JAL Write Data Mux ---------------------- Added NEW 14:15
	write_reg_data_w 	<= "000000000000000000000000" & PC_plus_4_shifted WHEN Jal = '1' ELSE write_data_i;	--JAL needs to be figures out	
	----------- Register File Process ---------------				
	END PROCESS;
	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			FOR i IN 0 TO 31 LOOP
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,DATA_BUS_WIDTH);
			END LOOP;
		elsif (clk_i'event and clk_i='1') then
			if (RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;
END behavior;


