--------------  Execute module (implements the data ALU and Branch Address Adder for the MIPS computer) ----------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-- USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
-- use IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.ALL;
USE work.aux_package.ALL;
USE work.const_package.all;

------------ Entity -----------------
ENTITY  Execute IS
    generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0); -- HANAN
			read_data2_i 	: IN 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0); -- HANAN
			sign_extend_i 	: IN 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0); -- HANAN
			funct_i         : IN 	std_logic_vector(FUNCT_WIDTH-1 downto 0); -- HANAN
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );-- HANAN
			ALUSrc_ctrl_i   : IN 	STD_LOGIC;-- HANAN
			zero_o 			: OUT	STD_LOGIC;-- HANAN
			alu_res_o 		: OUT	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);-- HANAN
			pc_plus4_i 		: IN 	std_logic_vector(PC_WIDTH-1 downto 0); -- HANAN
            addr_res_o      : OUT   STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- HANAN

            ----------------------------------------------------------------
            -- G PORTS
            ----------------------------------------------------------------

            opcode_i		: IN 	std_logic_vector(FUNCT_WIDTH-1 downto 0); -- FROM CONTROL
            RegDst			: IN    STD_LOGIC_VECTOR( 1 DOWNTO 0 );
            Wr_reg_addr     : OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr_0	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr_1	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_data_FW_WB	: IN 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			Wr_data_FW_MEM	: IN 	std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			ForwardA 		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);		
			ForwardB		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			WriteData_EX    : OUT   std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
            );
END Execute;
------------ Architecture -----------------
ARCHITECTURE behaviour OF Execute IS
SIGNAL a_input_w, b_input_w 	  : std_logic_vector(DATA_BUS_WIDTH-1 downto 0); -- HANAN
SIGNAL ALU_out_mux_w			  : std_logic_vector(DATA_BUS_WIDTH-1 downto 0); -- HANAN

SIGNAL Aforward_mux, Bforward_mux : std_logic_vector(DATA_BUS_WIDTH-1 downto 0);

--SIGNAL Branch_Add 				  
SIGNAL alu_ctl_w				  : STD_LOGIC_VECTOR( 3 DOWNTO 0 ); -- HANAN
SIGNAL branch_addr_r              : STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- HANAN
SIGNAL write_register_address 	  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
SIGNAL write_register_address_1	  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
SIGNAL write_register_address_0	  : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
BEGIN
--------------- ALU Inputs: A,B ----------------				
	------------ Forwarding Unit----------------
		-- Forward A
	WITH ForwardA SELECT 
			Aforward_mux <= read_data1_i   WHEN "00",
							Wr_data_FW_WB  WHEN "01",
							Wr_data_FW_MEM WHEN "10",
							X"00000000"	   WHEN OTHERS;
		-- Forward B
	WITH ForwardB SELECT 
			Bforward_mux <= read_data2_i   WHEN "00",
							Wr_data_FW_WB  WHEN "01",
							Wr_data_FW_MEM WHEN "10",
							X"00000000"	   WHEN OTHERS;
                            
---------------- NO IDEA WHAT HAPPENS HERE, CHECK LATER ------------------------							
	-- ALU A input mux after forwarding (mux for adding shift)
	a_input_w <= 	Bforward_mux WHEN (ALUOp_ctrl_i = "11") ELSE  -- When Performing Shift, A should get data from reg2
				Aforward_mux;
	-- ALU B input mux after forwarding
	b_input_w <= 	Bforward_mux WHEN ( ALUSrc_ctrl_i = '0' ) ELSE
				Sign_extend_i( 31 DOWNTO 0 );		
	WriteData_EX <= Bforward_mux;
--------------------------------------------------------------------------------
-------------- Generate ALU control bits -------------
-------- ALU Control Process -----------------
	PROCESS (ALUOp_ctrl_i, funct_i, opcode_i)
	BEGIN
 	CASE ALUOp_ctrl_i IS
		WHEN "10" =>    -- r-type
			CASE funct_i IS
				WHEN ADD_FUN    => alu_ctl_w <= "0010"; -- add
				WHEN MOV_FUN    => alu_ctl_w <= "0010"; -- mov
				WHEN SUB_FUN    => alu_ctl_w <= "0110"; -- sub
				WHEN MUL_FUN    => alu_ctl_w <= "0011"; -- mul
				WHEN AND_FUN    => alu_ctl_w <= "0000"; -- and
				WHEN OR_FUN     => alu_ctl_w <= "0001"; -- or
				WHEN XOR_FUN    => alu_ctl_w <= "0100"; -- xor
				WHEN SLT_FUN    => alu_ctl_w <= "0111"; -- slt
				WHEN OTHERS     => alu_ctl_w <= "1111"; -- else
			END CASE;				
		WHEN "00" =>    -- i-type
			CASE opcode_i IS
				WHEN LW_OPC     => alu_ctl_w <= "0010"; -- lw
				WHEN SW_OPC     => alu_ctl_w <= "0010"; -- sw
				WHEN ADDI_OPC   => alu_ctl_w <= "0010"; -- addi
				WHEN ANDI_OPC   => alu_ctl_w <= "0000"; -- andi
				WHEN ORI_OPC    => alu_ctl_w <= "0001"; -- ori
				WHEN XORI_OPC   => alu_ctl_w <= "0100"; -- xori
				WHEN LUI_OPC    => alu_ctl_w <= "1001"; -- lui
				WHEN SLTI_OPC   => alu_ctl_w <= "0111"; -- slti
		        WHEN OTHERS     => alu_ctl_w <= "1111"; -- else
			END CASE;			
		WHEN "01" 	            => alu_ctl_w <= "0110"; -- beq, bne		
 	 	WHEN "11"	=>  -- shift
			CASE funct_i IS
				WHEN SLL_FUN    => alu_ctl_w <= "0101"; -- sll
				WHEN SRL_FUN    => alu_ctl_w <= "1000"; -- srl
				WHEN OTHERS     => alu_ctl_w <= "1111"; -- else
			END CASE;
		
		WHEN OTHERS             => alu_ctl_w <= "1111"; -- else	
  	END CASE;
  END PROCESS;


----------------- Mux for Register Write Address ---------------------
	 Wr_reg_addr <= "11111"			WHEN RegDst = "10" ELSE -- jal
					Wr_reg_addr_1 	WHEN RegDst = "01" ELSE 
					Wr_reg_addr_0;
------------ Generate zero_o Flag ----------------------------
	zero_o <= '1' WHEN ( ALU_out_mux_w( DATA_BUS_WIDTH-1 DOWNTO 0 ) = X"00000000"  ) ELSE	
			'0';    
------------- Select ALU output  ----------------------------      
	alu_res_o <= 	X"0000000" & B"000"  & ALU_out_mux_w( 31 ) WHEN  alu_ctl_w = "0111" ELSE  -- For SLT
					ALU_out_mux_w( 31 DOWNTO 0 );
		
------------ Adder to compute Branch Address ----------------
--	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend_i( 7 DOWNTO 0 ) ;
--	Add_result 	<= Branch_Add( 7 DOWNTO 0 );

------------ ALU Proces -----------------------------

------------ ALU Proces -----------------------------
PROCESS ( alu_ctl_w, a_input_w, b_input_w )
	variable product : STD_LOGIC_VECTOR(63 downto 0); 
	BEGIN
	--------------- Select ALU operation ---------------------
 	CASE alu_ctl_w IS
		-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_out_mux_w 	<= a_input_w AND b_input_w; 
		-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_out_mux_w 	<= a_input_w OR b_input_w;
		-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_out_mux_w 	<= a_input_w + b_input_w; 
		-- ALU performs ALUresult = A_input * B_input
 	 	WHEN "0011" 	=>	product := a_input_w * b_input_w; -- result 64 bit
							ALU_out_mux_w <= product(31 DOWNTO 0); -- Take Lower Part
		-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "0100" 	=>	ALU_out_mux_w 	<= a_input_w XOR b_input_w;
		-- ALU performs ALUresult = A_input SLL B_input
 	 	WHEN "0101" 	=>	ALU_out_mux_w 	<=	std_logic_vector(shift_left(unsigned(a_input_w),to_integer(unsigned(b_input_w(10 downto 6)))));

		-- ALU performs ALUresult = A_input SRL B_input
 	 	WHEN "1000" 	=>	ALU_out_mux_w 	<=	std_logic_vector(shift_right(unsigned(a_input_w),to_integer(unsigned(b_input_w(10 downto 6))))); 

		-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_out_mux_w 	<= a_input_w - b_input_w; 
		-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_out_mux_w 	<= a_input_w - b_input_w;  
		-- ALU performs LUI
  	 	WHEN "1001" 	=>	ALU_out_mux_w 	<= b_input_w(15 DOWNTO 0) & "0000000000000000";
		-- OUTPUT ZERO
 	 	WHEN OTHERS	=>	ALU_out_mux_w 	<= X"00000000" ;
  	END CASE;
  END PROCESS;



  
END behaviour;

