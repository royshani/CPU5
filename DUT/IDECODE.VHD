---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Idecode module (implements the register file for the MIPS computer
LIBRARY IEEE; 		
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY Idecode IS
	generic(
		DATA_BUS_WIDTH : integer := 32
	);
	PORT(	clk_i,rst_i		: IN 	STD_LOGIC;
			instruction_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			dtcm_data_rd_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			alu_result_i	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i : IN 	STD_LOGIC;
			MemtoReg_ctrl_i : IN 	STD_LOGIC;
			RegDst_ctrl_i 	: IN 	STD_LOGIC;
			read_data1_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_o	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 	: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)		 
	);
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

	SIGNAL RF_q					: register_file;
	SIGNAL write_reg_addr_w 	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_reg_data_w		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL rs_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rt_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rd_register_w		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL imm_value_w			: STD_LOGIC_VECTOR( 15 DOWNTO 0 );

BEGIN
	rs_register_w 			<= instruction_i(25 DOWNTO 21);
   	rt_register_w 			<= instruction_i(20 DOWNTO 16);
   	rd_register_w			<= instruction_i(15 DOWNTO 11);
   	imm_value_w 			<= instruction_i(15 DOWNTO 0);
	
	-- Read Register 1 Operation
	read_data1_o <= RF_q(CONV_INTEGER(rs_register_w));
	
	-- Read Register 2 Operation		 
	read_data2_o <= RF_q(CONV_INTEGER(rt_register_w));
	
	-- Mux for Register Write Address
	write_reg_addr_w <= rd_register_w WHEN RegDst_ctrl_i = '1' ELSE 
						rt_register_w;
	
	-- Mux to bypass data memory for Rformat instructions
	write_reg_data_w <= alu_result_i(DATA_BUS_WIDTH-1 DOWNTO 0) WHEN (MemtoReg_ctrl_i = '0') ELSE 
						dtcm_data_rd_i;
	
	-- Sign Extend 16-bits to 32-bits
    sign_extend_o <= 	X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE
						X"FFFF" & imm_value_w;


	process(clk_i,rst_i)
	begin
		if (rst_i='1') then
			FOR i IN 0 TO 31 LOOP
				-- RF_q(i) <= CONV_STD_LOGIC_VECTOR(i,32);
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(0,32);
			END LOOP;
		elsif (clk_i'event and clk_i='1') then
			if (RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0) then
				RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
				-- index is integer type so we must use conv_integer for type casting
			end if;
		end if;
end process;

END behavior;





