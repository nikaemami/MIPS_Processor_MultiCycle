`timescale 1ns/1ns

`define S0 5'd0
`define S1 5'd1
`define S2 5'd2
`define S3 5'd3
`define S4 5'd4
`define S5 5'd5
`define S6 5'd6
`define S7 5'd7
`define S8 5'd8
`define S9 5'd9
`define S10 5'd10
`define S11 5'd11
`define S12 5'd12
`define S13 5'd13
`define S14 5'd14
`define S15 5'd15
`define S16 5'd16

`define ADD 3'd0
`define SUB 3'd1
`define RSB 3'd2
`define AND 3'd3
`define NOT 3'd4
`define TST 3'd5
`define CMP 3'd6
`define MOV 3'd7

`define DPI 2'd2
`define DTI 2'd0
`define BI 2'd1

module ALU_controller(ALUop, alu_function, ALU_control);
	input [1:0] ALUop;
	input [2:0] alu_function;
	output [2:0] ALU_control;
	reg [2:0] ALU_control;
	always @(ALUop, alu_function)begin
		if(ALUop == `DPI)
			case(alu_function)
				`ADD:ALU_control = 3'd0;
				`SUB:ALU_control = 3'd1;
				`RSB:ALU_control = 3'd1;
				`AND:ALU_control = 3'd2;
				`NOT:ALU_control = 3'd3;
				`TST:ALU_control = 3'd2;
				`CMP:ALU_control = 3'd1;
				`MOV:ALU_control = 3'd4;
			endcase
		else if(ALUop == `DTI)
			ALU_control = 3'd0;
		else if(ALUop == `BI)
			ALU_control = 3'd1;
	end
endmodule

module controller(clk, rst, condition, Memory_out, ALUop, PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead);
	input clk, rst, condition;
	input [31:0] Memory_out;
	output PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead;
	output [1:0]ALUop;
	reg [1:0]ALUop;
	reg PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead;
	reg [4:0] ps,ns;
	wire L1, L2, I, DPI, DTI, BI, ADD, SUB;
	assign L1 = Memory_out[20];
	assign L2 = Memory_out[26];
	assign I = Memory_out[23];
	assign DPI = (Memory_out[29:24] == 6'b0)?1'b1:1'b0;
	assign DTI = (Memory_out[29:21] == 9'b010000000)?1'b1:1'b0;
	assign BI = (Memory_out[29:27] == 3'b101)?1'b1:1'b0;
	//initial begin ps<=`S0;end
	always @(posedge clk)begin
		if(rst)
			ps <= `S0;
		else
			ps <= ns;
	end
	always @(ps)begin
		ns=`S0;
		case(ps)
			`S0:ns =`S1;
			//`S1:ns = condition?(DTI?(L1?`S2:`S4):(DPI?(I?`S11:`S10):(BI?`S7:`S0))):`S0;
			`S1:if (condition == 1'b1)begin 
				if(DTI == 1'b1)begin 
					if(L1 == 1'b1) ns=`S2;
					else ns=`S4;
				end
				else if(DPI == 1'b1)begin
					if(I == 1'b1) ns=`S11;
					else ns=`S10;
				end
				else if(BI==1'b1) ns=`S7;
			end
			else begin
				ns=`S15;end 
			`S2:ns = `S3;
			`S3:ns = `S15;
			`S4:ns = `S5;
			`S5:ns = `S6;
			`S6:ns = `S15;
			`S7:ns = L2?`S9:`S8;
			`S8:ns =`S15;
			`S9:ns = `S15;
			`S10:ns = (Memory_out[22:20] == `ADD | Memory_out[22:20] == `SUB | Memory_out[22:20] == `RSB | Memory_out[22:20] == `CMP)?`S12:`S14;
			`S11:ns = (Memory_out[22:20] == `ADD | Memory_out[22:20] == `SUB | Memory_out[22:20] == `RSB | Memory_out[22:20] == `CMP)?`S12:`S14;
			`S12:ns = (Memory_out[22:20] != `CMP)?`S13:`S15;
			`S13:ns = `S15;
			`S14:ns = (Memory_out[22:20] != `TST)?`S13:`S15;
			`S15:ns = `S16;
			`S16:ns = `S0;
			default:ns = `S0;
		endcase
	end
	always @(ps)begin
		//{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=21'd0;
		case(ps)
			`S0: begin {MemRead, IR_Write}=2'b11;{PC_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite}=17'd0;end
			`S1:{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=21'd0;
			`S2: begin {OP2_sel, rr_sel}=2'b11;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, MUX_sel, Pc_set, Data_sel, wr_sel, MemWrite, MemRead, ALUop}=19'd0;end
			`S3: begin {I_or_D, MemWrite} = 2'b11;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, wr_sel, MemRead, ALUop}=18'd0;end
			`S4: begin {OP2_sel} = 1'b1;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=20'd0;end
			`S5: begin {I_or_D, MemRead} = 2'b11;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, ALUop}=19'd0;end
			`S6: begin regwrite = 1'b1;{PC_Write, IR_Write, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=20'd0;end
			`S7: begin {Data_sel, Pc_set, OP_sel} = 3'b111;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP2_sel, MUX_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=18'd0;end
			`S8: begin {PC_Write}=1'b1;{IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP2_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=16'd0;end
			`S9: begin {Pc_set, MUX_sel, PC_Write, wr_sel, regwrite, WD_sel} = 6'b111111;{IR_Write, ld_V, ld_N, ld_Z, ld_C, I_or_D, MDR_sel, OP_sel, OP2_sel, Data_sel, rr_sel, MemWrite, MemRead, ALUop}=15'd0;end
			`S10: begin {ALUop} = 2'b10;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead}=19'd0;end
			`S11: begin {OP2_sel, ALUop} = 3'b110;{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead}=18'd0;end
			`S12: begin {regwrite, MDR_sel, ld_V, ld_N, ld_Z, ld_C}=6'b111111;{PC_Write, IR_Write, I_or_D, WD_sel, OP_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead}=12'd0;end
			`S13:{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=21'd0;
			`S14: begin {regwrite, MDR_sel, ld_Z, ld_N}=4'b1111;{PC_Write, IR_Write, ld_V, ld_C, I_or_D, WD_sel, OP2_sel, OP_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=17'd0;end
		        `S15:{PC_Write, IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP_sel, OP2_sel, MUX_sel, Pc_set, Data_sel, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=21'd0;
			`S16: begin {PC_Write, Data_sel, OP_sel}=3'b111;{IR_Write, regwrite, ld_V, ld_N, ld_Z, ld_C, I_or_D, WD_sel, MDR_sel, OP2_sel, MUX_sel, Pc_set, rr_sel, wr_sel, MemWrite, MemRead, ALUop}=18'd0;end
		endcase
	end
endmodule
