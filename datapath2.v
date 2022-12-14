module DataPath(clk, rst, ALU_control, Memory_out, regwrite, PC_Write, IR_Write, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, condition, Adr, B_out, V_in, C_in, Z_in, N_in);
	input [31:0]Memory_out;
	input [2:0]ALU_control;
	input clk, rst, PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel;
	output [31:0] B_out, Adr;
	output condition, V_in, C_in, Z_in, N_in;
	wire [3:0] read_data2, Write;
	wire [31:0] ALU_out, PC_out, IR_out ,MDR_out, mux_MDR_out, A_out, data1, data2, ALU_in, Write_Data, OpSel_out, Op2Sel_out, ALU_a, ALU_b, PcSet_out, SE1_out, SE2_out;
	wire V_out, C_out, Z_out, N_out, line1, line2, line3, line4;
	Register_ctrl PC(clk, rst, PC_Write, ALU_in, PC_out);
	Register_ctrl IR(clk, rst, IR_Write, Memory_out, IR_out);
	Register_1 V(clk, rst, ld_V, V_in, V_out);
	Register_1 N(clk, rst, ld_N, N_in, N_out);
	Register_1 Z(clk, rst, ld_Z, Z_in, Z_out);
	Register_1 C(clk, rst, ld_C, C_in, C_out);
	Register MDR(clk, rst, Memory_out, MDR_out);
	Register A(clk, rst, data1, A_out);
	Register B(clk, rst, data2, B_out);
	Register Aluout(clk, rst, ALU_in, ALU_out);
	mux2to1_32 IorD(PC_out, ALU_out, I_or_D, Adr);
	mux2to1_32 MUX_MDR(MDR_out, ALU_out, MDR_sel, mux_MDR_out);
	mux2to1_32 WrData(mux_MDR_out, PC_out, WD_sel, Write_Data);
	mux2to1_32 OpSel(A_out, PC_out, OP_sel, OpSel_out);
	mux2to1_32 Op2Sel(B_out, SE2_out, OP2_sel, Op2Sel_out);
	mux2to1_32 MuxSel(OpSel_out, ALU_out, MUX_sel, ALU_a);
	mux2to1_32 PcSet(32'b1, SE1_out, Pc_set, PcSet_out);
	mux2to1_32 DataSel(Op2Sel_out, PcSet_out, Data_sel, ALU_b);
	mux2to1_4 RrSel(IR_out[3:0], IR_out[15:12], rr_sel, read_data2);
	mux2to1_4 WrSel(IR_out[15:12], 4'd15, wr_sel, Write);
	Register_File RF(clk, rst, IR_out[19:16], read_data2, Write, Write_Data, regwrite, data1, data2);
	Sign_Extend_26 SE1(IR_out[25:0], SE1_out);
	Sign_Extend_12 SE2(IR_out[11:0], SE2_out);
	ALU ALU_(ALU_a, ALU_b, ALU_control, ALU_in, Z_in, N_in, C_in, V_in);
	assign line1 = Z_out&(~(IR_out[30] | IR_out[31]));
	assign line2 = ~Z_out&(V_out~^N_out)&(~(~IR_out[30] | IR_out[31]));
	assign line3 = ~(V_out~^N_out)&(~(~IR_out[31] | IR_out[30]));
	assign line4 = IR_out[30]&IR_out[31];
	assign condition = line1|line2|line3|line4;
endmodule

