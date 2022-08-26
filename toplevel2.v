module MIPS_Multi(clk, rst, Memory_out, MemWrite, MemRead, Adr, B_out, V_in, C_in, Z_in, N_in);
	input clk, rst;
	input [31:0] Memory_out;
	output MemWrite, MemRead, V_in, C_in, Z_in, N_in;
	output [31:0] Adr, B_out;
	wire MemWrite, MemRead, regwrite, PC_Write, IR_Write, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, condition;
	wire [31:0] Adr, B_out;
	wire [1:0]ALUop;
	wire [2:0] alu_function, ALU_control;
	assign alu_function = Memory_out[22:20];
	DataPath DP(clk, rst, ALU_control, Memory_out, regwrite, PC_Write, IR_Write, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, condition, Adr, B_out, V_in, C_in, Z_in, N_in);
	controller CL(clk, rst, condition, Memory_out, ALUop, PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead);
	ALU_controller ALUCL(ALUop, alu_function, ALU_control);
endmodule
