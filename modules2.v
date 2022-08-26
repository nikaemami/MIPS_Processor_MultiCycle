
`define S0 3'd0
`define S1 3'd1
`define S2 3'd2
`define S3 3'd3
`define S4 3'd4

module ALU(A, B, ALU_control, ALU_out, zero, negative, carry, overflow);
	input [31:0]A, B;
	input [2:0] ALU_control;
	output [31:0] ALU_out;
	output zero, negative, carry, overflow;
	reg zero, negative, carry, overflow;
	reg [31:0] ALU_out;
	reg addop, subop;
	reg [31:0] C;
	always@(A, B, ALU_control) begin
		case(ALU_control)
			`S0:ALU_out = A+B;
			`S1:ALU_out = A-B;
			`S2:ALU_out = A&B;
			`S3:ALU_out = 32'd0 - B;
			`S4:ALU_out = B;
		endcase
	end
	assign carry = 1'b0;
	always@(ALU_control) begin
	{addop , subop}=2'b0;
		case(ALU_control)
			`S0:addop = 1'b1;
			`S1:subop = 1'b1;
		endcase
	end
	assign C = 32'd0 - B;
	assign overflow = addop ? ( (A[31]&B[31]&(~ALU_out[31]))|(~A[31]&(~B[31])&ALU_out[31]) ) : ( subop ?  ((A[31]&(C[31])&(~ALU_out[31]))|(~A[31]&(~C[31])&ALU_out[31])) : 1'b0 );
	assign negative = ALU_out[31];
	assign zero = (ALU_out==32'b0) ?1'b1:1'b0;
endmodule

module mux2to1_4(A, B, Sel, Out);
	input [3:0] A, B;
	input Sel;
	output [3:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:4'bx;
endmodule

module mux2to1_32(A, B, Sel, Out);
	input [31:0] A, B;
	input Sel;
	output [31:0] Out;
	assign Out = (~Sel)?A:
		 (Sel)?B:32'bx;
endmodule

module Sign_Extend_26(Input, Output);
	input [25:0]Input;
	output [31:0]Output;
	assign Output = (Input[25])?{6'd63, Input}:{6'b0, Input};
endmodule

module Sign_Extend_12(Input, Output);
	input [11:0] Input;
	output [31:0] Output;
	assign Output = (Input[11])?{12'b1, Input}:{12'b0, Input};
endmodule

module Register_File(clk, rst, Read_Reg1, Read_Reg2, Write_Reg, Write_Data, RegWrite, Read1, Read2);
	input [3:0] Read_Reg1, Read_Reg2, Write_Reg;
	input [31:0] Write_Data;
	input RegWrite, clk, rst;
	output [31:0] Read1, Read2;
	reg [0:15][31:0] registers;
	integer n;
	/*initial begin
		for(n=0; n<32; n = n+1)begin
				registers[n] <= 32'b0;
		end
	end*/
	always@(posedge clk, posedge rst)begin
		if(rst)
			for(n=0; n<16; n = n+1)begin
				registers[n] <= 32'b0;
			end
		else if(RegWrite)begin
			registers[Write_Reg][31:0] <= Write_Data;
		end
	end
	assign Read1 = registers[Read_Reg1][31:0];
	assign Read2 = registers[Read_Reg2][31:0];
endmodule

module Register_1(clk, rst, Reg_Write, Input, Output);
	input Input, clk, rst, Reg_Write;
	output Output;
	reg Output;
	//initial begin Output <= 32'b0; end
	always@(posedge clk)begin
		if(rst) 
			Output <= 1'b0;
		else if (Reg_Write)
			Output <= Input;
		else Output <= Output;
	end
endmodule

module Register_ctrl(clk, rst, Reg_Write, Input, Output);
	input [31:0] Input;
	input clk, rst, Reg_Write;
	output [31:0] Output;
	reg [31:0] Output;
	//initial begin Output <= 32'b0; end
	always@(posedge clk)begin
		if(rst) 
			Output <= 32'b0;
		else if (Reg_Write)
			Output <= Input;
		else Output <= Output;
	end
endmodule

module Register(clk, rst, Input, Output);
	input [31:0] Input;
	input clk, rst;
	output [31:0] Output;
	reg [31:0] Output;
	//initial begin Output <= 32'b0; end
	always@(posedge clk)begin
		if(rst) 
			Output <= 32'b0;
		else Output <= Input;
	end
endmodule
