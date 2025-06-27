---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use work.cond_comilation_package.all;

package aux_package is
-------------------------------------------------------

	 -- MIPS Top-Level Component Declaration
    component MIPS is
        generic(
            WORD_GRANULARITY : boolean := G_WORD_GRANULARITY;
            MODELSIM         : integer := G_MODELSIM;
            DATA_BUS_WIDTH   : integer := 32;
            ITCM_ADDR_WIDTH  : integer := G_ADDRWIDTH;
            DTCM_ADDR_WIDTH  : integer := G_ADDRWIDTH;
            PC_WIDTH         : integer := 10;
            FUNCT_WIDTH      : integer := 6;
            DATA_WORDS_NUM   : integer := G_DATA_WORDS_NUM;
            CLK_CNT_WIDTH    : integer := 16;
            INST_CNT_WIDTH   : integer := 16;
            SIM              : boolean := false
        );
        port(
            rst_i, clk_i, ena              : in  std_logic;
            pc_o                           : out std_logic_vector(9 downto 0);
            alu_result_o                   : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
            read_data1_o                   : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
            read_data2_o                   : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
            write_data_o                   : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
            instruction_top_o              : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
            Branch_ctrl_o                  : out std_logic;
            Zero_o                         : out std_logic;
            MemWrite_ctrl_o                : out std_logic;
            RegWrite_ctrl_o                : out std_logic;
            mclk_cnt_o                     : out std_logic_vector(CLK_CNT_WIDTH-1 downto 0);
            inst_cnt_o                     : out std_logic_vector(INST_CNT_WIDTH-1 downto 0);
            STCNT_o                        : out std_logic_vector(7 downto 0);
            FHCNT_o                        : out std_logic_vector(7 downto 0);
            BPADDR_i                       : in  std_logic_vector(7 downto 0);
            ST_trigger                     : out std_logic
        );
    end component;

	component Ifetch is
		generic(
			WORD_GRANULARITY : boolean  := G_WORD_GRANULARITY;
			DATA_BUS_WIDTH   : integer  := 32;
			PC_WIDTH         : integer  := 10;
			NEXT_PC_WIDTH    : integer  := 8;
			ITCM_ADDR_WIDTH  : integer  := G_ADDRWIDTH;
			WORDS_NUM        : integer  := G_DATA_WORDS_NUM;
			INST_CNT_WIDTH   : integer  := 16
		);
		port(
			clk_i, rst_i       : in  std_logic;
			add_result_i       : in  std_logic_vector(7 downto 0);
			instruction_o      : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			pc_plus_4_o        : out std_logic_vector(PC_WIDTH-1 downto 0);
			inst_cnt_o         : out std_logic_vector(INST_CNT_WIDTH-1 downto 0);
			PCSrc              : in  std_logic_vector(1 downto 0);
			pc_o               : out std_logic_vector(PC_WIDTH-1 downto 0);
			JumpAddr           : in  std_logic_vector(7 downto 0);
			ena, Stall_IF,
			BPADD_ena          : in  std_logic
		);
	end component;

	component Idecode is
		generic(
			DATA_BUS_WIDTH : integer := 32
		);
		port (
			clk_i, rst_i                   : in  std_logic;
			instruction_i                  : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			dtcm_data_rd_i                 : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			alu_result_i                   : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			RegWrite_ctrl_i                : in  std_logic;
			MemtoReg_ctrl_i                : in  std_logic;
			PC_plus_4_shifted              : in  std_logic_vector(7 downto 0);
			ForwardA_ID, ForwardB_ID       : in  std_logic;
			BranchBeq, BranchBne, Jump, JAL: in  std_logic;
			Stall_ID                       : in  std_logic;
			write_data_i                   : in  std_logic_vector(31 downto 0);
			Branch_read_data_FW            : in  std_logic_vector(31 downto 0);
			write_register_address         : in  std_logic_vector(4 downto 0);

			read_data1_o                   : out std_logic_vector(31 downto 0);
			read_data2_o                   : out std_logic_vector(31 downto 0);
			rt_register_o                  : out std_logic_vector(4 downto 0);
			rd_register_o                  : out std_logic_vector(4 downto 0);
			sign_extend_o                  : out std_logic_vector(31 downto 0);
			PCSrc                          : out std_logic_vector(1 downto 0);
			JumpAddr                       : out std_logic_vector(7 downto 0);
			PCBranch_addr                  : out std_logic_vector(7 downto 0)
		);
	end component;


	component control is
		port(
			opcode_i           : in  std_logic_vector(5 downto 0);
			Funct              : in  std_logic_vector(5 downto 0);
			RegDst_ctrl_o      : out std_logic_vector(1 downto 0);
			ALUSrc_ctrl_o      : out std_logic;
			MemtoReg_ctrl_o    : out std_logic;
			RegWrite_ctrl_o    : out std_logic;
			MemRead_ctrl_o     : out std_logic;
			MemWrite_ctrl_o    : out std_logic;
			BranchBeq          : out std_logic;
			BranchBne          : out std_logic;
			Jump_ctrl_o        : out std_logic;
			Jal_ctrl_o         : out std_logic;
			ALUOp_ctrl_o       : out std_logic_vector(1 downto 0)
		);
	end component;


	component Execute is
		generic (
			DATA_BUS_WIDTH : integer := 32;
			FUNCT_WIDTH    : integer := 6;
			PC_WIDTH       : integer := 10
		);
		port (
			read_data1_i      : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			read_data2_i      : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			sign_extend_i     : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			funct_i           : in  std_logic_vector(FUNCT_WIDTH-1 downto 0);
			ALUOp_ctrl_i      : in  std_logic_vector(1 downto 0);
			ALUSrc_ctrl_i     : in  std_logic;
			zero_o            : out std_logic;
			alu_res_o         : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			pc_plus4_i        : in  std_logic_vector(PC_WIDTH-1 downto 0);
			addr_res_o        : out std_logic_vector(7 downto 0);

			-- G PORTS
			opcode_i          : in  std_logic_vector(FUNCT_WIDTH-1 downto 0);
			RegDst            : in  std_logic_vector(1 downto 0);
			Wr_reg_addr       : out std_logic_vector(4 downto 0);
			Wr_reg_addr_0     : in  std_logic_vector(4 downto 0);
			Wr_reg_addr_1     : in  std_logic_vector(4 downto 0);
			Wr_data_FW_WB     : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			Wr_data_FW_MEM    : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			ForwardA          : in  std_logic_vector(1 downto 0);
			ForwardB          : in  std_logic_vector(1 downto 0);
			WriteData_EX      : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
		);
	end component;

	component dmemory is
		generic (
			DATA_BUS_WIDTH  : integer := 32;
			DTCM_ADDR_WIDTH : integer := 8;
			WORDS_NUM       : integer := 256
		);
		port (
			clk_i           : in  std_logic;
			rst_i           : in  std_logic;
			dtcm_addr_i     : in  std_logic_vector(DTCM_ADDR_WIDTH-1 downto 0);
			dtcm_data_wr_i  : in  std_logic_vector(DATA_BUS_WIDTH-1 downto 0);
			MemRead_ctrl_i  : in  std_logic;
			MemWrite_ctrl_i : in  std_logic;
			dtcm_data_rd_o  : out std_logic_vector(DATA_BUS_WIDTH-1 downto 0)
		);
	end component;
	
	component HazardUnit is
		port (
			MemtoReg_EX      : in  std_logic;
			MemtoReg_MEM     : in  std_logic;
			WriteReg_EX      : in  std_logic_vector(4 downto 0);
			WriteReg_MEM     : in  std_logic_vector(4 downto 0);
			WriteReg_WB      : in  std_logic_vector(4 downto 0);
			RegRs_ID         : in  std_logic_vector(4 downto 0);
			RegRt_ID         : in  std_logic_vector(4 downto 0);
			RegRs_EX         : in  std_logic_vector(4 downto 0);
			RegRt_EX         : in  std_logic_vector(4 downto 0);
			EX_RegWr         : in  std_logic;
			MEM_RegWr        : in  std_logic;
			WB_RegWr         : in  std_logic;
			BranchBeq_ID     : in  std_logic;
			BranchBne_ID     : in  std_logic;
			Jump_ID          : in  std_logic;
			Stall_IF         : out std_logic;
			Stall_ID         : out std_logic;
			Flush_EX         : out std_logic;
			ForwardA         : out std_logic_vector(1 downto 0);
			ForwardB         : out std_logic_vector(1 downto 0);
			ForwardA_Branch  : out std_logic;
			ForwardB_Branch  : out std_logic
		);
	end component;

	---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	
-----------------------------------------------------------------------------------

end aux_package;

