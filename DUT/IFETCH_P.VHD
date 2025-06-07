---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
---------------- ENTITY ------------------
ENTITY Ifetch IS
	generic(
		WORD_GRANULARITY : boolean 	:= False;
		DATA_BUS_WIDTH : integer 	:= 32;
		PC_WIDTH : integer 			:= 10;
		NEXT_PC_WIDTH : integer 	:= 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
		ITCM_ADDR_WIDTH : integer 	:= 8;
		WORDS_NUM : integer 		:= 256;
		INST_CNT_WIDTH : integer 	:= 16
	);
	PORT(	clk_i, rst_i 						: IN 	STD_LOGIC;	
			add_result_i 						: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
			Branch_ctrl_i 						: IN 	STD_LOGIC;
        	zero_i 								: IN 	STD_LOGIC;
			instruction_o 						: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
        	pc_plus_4_o							: OUT	STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0 );
			inst_cnt_o					 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0); -- HANAN	
----------------------------  G Ports -----------------------------------
        	PCSrc 								   : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
      		pc_o 								   : OUT	STD_LOGIC_VECTOR( PC_WIDTH-1 DOWNTO 0 );
			JumpAddr							   : IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	 ena, Stall_IF, BPADD_ena : IN 	STD_LOGIC);
-------------------------------------------------------------------------			 
END Ifetch;
--------------- ARCHITECTURE --------------
ARCHITECTURE behaviour OF Ifetch IS
	SIGNAL pc_q				  	: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL pc_plus4_r 			: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
	SIGNAL next_pc_w  			: STD_LOGIC_VECTOR(NEXT_PC_WIDTH-1 DOWNTO 0);
------------------------------ Hanan SIGNALS-----------------------------

	SIGNAL itcm_addr_w 			: STD_LOGIC_VECTOR(ITCM_ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL rst_flag_q			: STD_LOGIC;
	SIGNAL inst_cnt_q 			: STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0);
	SIGNAL pc_prev_q			: STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);  
BEGIN
--------------- ROM for Instruction Memory ---------------
	inst_memory: altsyncram
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => DATA_BUS_WIDTH,
		widthad_a => ITCM_ADDR_WIDTH,
		numwords_a => WORDS_NUM,
		lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = ITCM",
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\yanai\Local\Documents\Yanai\University\LABS\CPU Architercture\Lab5\VHDL\CODE\program.hex", 
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clk_i,
		address_a  => itcm_addr_w, 
		q_a 	   => instruction_o 
	);
--------------------------------------------------------------	could this be the falling edge requirement?
		-- Mem_clock <= not clk_i;
--------- Instructions always start on word address - not byte -------
		pc_q(1 DOWNTO 0) <= "00";

--------- Copy output signals - allows read inside module -----------
		PC_out 			<= pc_q;
		PC_plus_4_out 	<= pc_plus4_r;

---------- Send address to inst. memory address register ---------

	-- send address to inst. memory address register
	G1: 
	if (WORD_GRANULARITY = True) generate 		-- i.e. each WORD has unike address
		itcm_addr_w <= next_pc_w;
	elsif (WORD_GRANULARITY = False) generate 	-- i.e. each BYTE has unike address
		itcm_addr_w <= next_pc_w & "00";
	end generate;
		
	-- Adder to increment PC by 4
	pc_plus4_r( 1 DOWNTO 0 )  		 <= "00";
    pc_plus4_r(PC_WIDTH-1 DOWNTO 2)  <= pc_q(PC_WIDTH-1 DOWNTO 2) + 1;

---------- Mux to select Branch Address or PC + 4 -----------       
	next_pc_w  <= (others => '0') 	WHEN rst_flag_q = '1' 	ELSE
				add_result_i 			WHEN PCSrc = "01" 		ELSE   -- branch
				JumpAddr			WHEN PCSrc = "10"		ELSE	-- jump
				pc_plus4_r(PC_WIDTH-1 DOWNTO 2);
			
---------- PC Proccess (CLK on rising edge) --------------			
	PROCESS  BEGIN
		WAIT UNTIL ( clock'EVENT ) AND ( clk_i = '1' );
		IF reset = '1' THEN
			   pc_q( 9 DOWNTO 2) <= "00000000" ; 
		ELSIF (ena = '1' AND Stall_IF = '0' AND BPADD_ena = '0') THEN
			   pc_q( 9 DOWNTO 2 ) <= next_pc_w;
		END IF;
	END PROCESS;
END behaviour;


