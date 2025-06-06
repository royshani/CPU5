---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;


ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 		: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			zero_o 			: OUT	STD_LOGIC;
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			addr_res_o 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
END Execute;


ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w 	: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_out_mux_w			: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL branch_addr_r 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL alu_ctl_w				: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	a_input_w <= 	read_data1_i;
	-- ALU input mux
	b_input_w <= 	read_data2_i WHEN (ALUSrc_ctrl_i = '0') ELSE
					sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);
--------------------------------------------------------------------------------------------------------
--  Generate ALU control bits
--------------------------------------------------------------------------------------------------------
	alu_ctl_w(0) <= (funct_i(0) OR funct_i(3)) AND ALUOp_ctrl_i(1);
	alu_ctl_w(1) <= (not ALUOp_ctrl_i(1)) or (not funct_i(2) and not ALUOp_ctrl_i(0));
	alu_ctl_w(2) <= (not ALUOp_ctrl_i(1) and ALUOp_ctrl_i(0)) or (funct_i(1));
--------------------------------------------------------------------------------------------------------
	
	-- Generate Zero Flag
	zero_o <= 	'1' WHEN (alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0) = X"00000000") ELSE
				'0';    
	
	-- Select ALU output        
	alu_res_o <= 	X"0000000" & B"000"  & alu_out_mux_w(31) WHEN  alu_ctl_w = "111" ELSE 
					alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0);
					
	-- Adder to compute Branch Address
	branch_addr_r	<= pc_plus4_i(PC_WIDTH-1 DOWNTO 2) + sign_extend_i(7 DOWNTO 0) ;
	addr_res_o 		<= branch_addr_r(7 DOWNTO 0);


PROCESS (alu_ctl_w, a_input_w, b_input_w)
	BEGIN		
 	CASE alu_ctl_w IS	-- Select ALU operation
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	alu_out_mux_w 	<= a_input_w AND b_input_w; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	alu_out_mux_w 	<= a_input_w OR b_input_w;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "010" 	=>	alu_out_mux_w 	<= a_input_w + b_input_w;
						-- ALU performs ?
 	 	WHEN "011" 	=>	alu_out_mux_w <= X"00000000";
						-- ALU performs ?
 	 	WHEN "100" 	=>	alu_out_mux_w 	<= X"00000000";
						-- ALU performs ?
 	 	WHEN "101" 	=>	alu_out_mux_w 	<= X"00000000";
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "110" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w;
						-- ALU performs SLT
  	 	WHEN "111" 	=>	alu_out_mux_w 	<= a_input_w - b_input_w ;
 	 	WHEN OTHERS	=>	alu_out_mux_w 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
  
END behavior;

