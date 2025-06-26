---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.const_package.all;
------------ Entity -----------------
ENTITY control IS
   PORT( 	
		opcode_i 				: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		Funct					: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0); -- G added
		RegDst_ctrl_o 			: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0); -- G splited to 2 bits
		ALUSrc_ctrl_o 			: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 		: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 		: OUT 	STD_LOGIC;
		MemRead_ctrl_o 			: OUT 	STD_LOGIC;
		MemWrite_ctrl_o 		: OUT 	STD_LOGIC;
		Branch_ctrl_o 			: OUT 	STD_LOGIC;
		Jump_ctrl_o				: OUT 	STD_LOGIC;
		Jal_ctrl_o				: OUT 	STD_LOGIC;
		ALUOp_ctrl_o 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 ));
		--clock, reset			: IN 	STD_LOGIC );
END control;
------------ Architecture -----------------
ARCHITECTURE behavior OF control IS
	SIGNAL  rtype_w, lw_w, sw_w, beq_w, bne_w, addi_w, ori_w, xori_w, andi_w, shift_w, lui_w, slti_w, jali_w	: STD_LOGIC;
	-- Add Relvant Signals Later if needed
BEGIN           
------- Code to generate control signals using opcode bits -------------
	
	-- OPcode Decoder --
	rtype_w 	<=  '1' WHEN opcode_i = R_TYPE_OPC OR opcode_i = MUL_OPC ELSE '0'; 
	lw_w        <=  '1' WHEN opcode_i = LW_OPC ELSE '0';
 	sw_w        <=  '1' WHEN opcode_i = SW_OPC ELSE '0';
   	beq_w       <=  '1' WHEN opcode_i = BEQ_OPC ELSE '0';
	bne_w		<=	'1' WHEN opcode_i = BNE_OPC ELSE '0';
	addi_w		<=  '1' WHEN opcode_i = ADDI_OPC or opcode_i = ADDIU_OPC ELSE '0';
	andi_w 		<=  '1' WHEN opcode_i = ANDI_OPC ELSE '0';
	slti_w		<= 	'1' WHEN opcode_i = SLTI_OPC ELSE '0';
	ori_w			<=  '1' WHEN opcode_i = ORI_OPC ELSE '0';
	xori_w		<=  '1' WHEN opcode_i = XORI_OPC ELSE '0';
	lui_w			<=	'1' WHEN opcode_i = LUI_OPC ELSE '0'; -- chck if implemented
	jali_w	<=	'1' WHEN opcode_i = JAL_OPC ELSE '0';
	Jump_ctrl_o	<=	'1' WHEN opcode_i = JMP_OPC OR opcode_i = JAL_OPC OR (opcode_i = R_TYPE_OPC AND Funct = JR_OPC) ELSE '0';
	shift_w		<=  '1' WHEN opcode_i = R_TYPE_OPC AND (Funct = SLL_FUN OR Funct = SRL_FUN) ELSE '0';

	-- EXEC -- 
	RegDst_ctrl_o(1)	<= jali_w; -- jal
	RegDst_ctrl_o(0)  	<= rtype_w;
	ALUSrc_ctrl_o  	<= lw_w OR sw_w OR addi_w OR andi_w OR ori_w OR xori_w OR shift_w OR lui_w OR slti_w;
	ALUOp_ctrl_o(0) 	<= beq_w OR bne_w OR shift_w; 
	ALUOp_ctrl_o(1) 	<= rtype_w;

		-- MEM -- 
	MemRead_ctrl_o 	<= lw_w;
   	MemWrite_ctrl_o 	<= sw_w; 
 	Branch_ctrl_o   <= beq_w or bne_w;
	Jal_ctrl_o		<= jali_w;
	
	-- WB --
	MemtoReg_ctrl_o 	<= lw_w;
  	RegWrite_ctrl_o 	<= rtype_w OR lw_w OR addi_w OR andi_w OR ori_w OR xori_w OR lui_w OR slti_w OR jali_w;


END behavior;


