onerror {resume}
add list -hex -width 26 /mips_tb/write_data_tb_o
add list /mips_tb/STCNT_tb_o
add list /mips_tb/rst_tb_i
add list /mips_tb/RegWrite_ctrl_tb_o
add list -hex /mips_tb/read_data2_tb_o
add list -hex /mips_tb/read_data1_tb_o
add list -hex -width 32 /mips_tb/pc_tb_o
add list -hex /mips_tb/mclk_cnt_tb_o
add list -hex -width 16 /mips_tb/instruction_top_tb_o
add list -hex /mips_tb/inst_cnt_tb_o
add list -hex -width 16 /mips_tb/FHCNT_tb_o
add list -hex /mips_tb/alu_result_tb_o
add list -hex -width 26 /mips_tb/write_data_tb_o
add list /mips_tb/STCNT_tb_o
add list /mips_tb/rst_tb_i
add list /mips_tb/RegWrite_ctrl_tb_o
add list -hex /mips_tb/read_data2_tb_o
add list -hex /mips_tb/read_data1_tb_o
add list -hex -width 32 /mips_tb/pc_tb_o
add list -hex /mips_tb/mclk_cnt_tb_o
add list -hex -width 16 /mips_tb/instruction_top_tb_o
add list -hex /mips_tb/inst_cnt_tb_o
add list -hex -width 16 /mips_tb/FHCNT_tb_o
add list -hex /mips_tb/alu_result_tb_o
add list /mips_tb/CORE/Run
add list /mips_tb/CORE/BPADD_ena
add list /mips_tb/CORE/PCSrc_ID
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
