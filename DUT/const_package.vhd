---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;


package const_package is
---------------------------------------------------------
--	IDECODE constants
---------------------------------------------------------
	constant R_TYPE_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	constant LW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100011";
	constant SW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "101011";
	constant BEQ_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	constant ANDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
	constant ORI_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "001101";
	constant ADDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";
	constant LOAD_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";	
	constant XORI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001110";
	constant LUI_OPC :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	constant SLTI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010";
	

	
--------------------------------------------------------	
-- Rtype FUNC	
--------------------------------------------------------	
	constant ADD_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
	constant MOV_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";	
	constant SUB_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100010";
	constant AND_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
	constant OR_FUN	 :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";	
	constant XOR_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100110";
	constant SLT_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "101010";
	constant SLL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	constant SRL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	constant NOP_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "111111";
	constant MUL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "011000";	
	




end const_package;

