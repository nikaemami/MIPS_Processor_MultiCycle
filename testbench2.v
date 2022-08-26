`timescale 1ns/1ns

module Memory(clk, Adr, Write_Data, MemRead, MemWrite, Read_Data);
	input [31:0] Adr, Write_Data;
	input clk, MemRead, MemWrite;
	output [31:0] Read_Data;
	reg [31:0] Read_Data;
	reg [31:0] Memory[0:2008];
	initial begin
		$readmemb("Instruction.txt", Memory);
		$readmemb("Memory.txt", Memory, 32'd1000);
	end
	always@(posedge clk)begin
		if(MemWrite)begin
			Memory[Adr] <= Write_Data;
		end
	end
	assign Read_Data = MemRead?Memory[Adr]:Read_Data;
	
endmodule

module TB_MIPS();
	reg clk=0, rst=0;
	wire [31:0] B_out, Adr, Memory_out;
	wire MemRead, MemWrite, V_in, C_in, Z_in, N_in;
	Memory MEM(clk, Adr, B_out, MemRead, MemWrite, Memory_out);
	MIPS_Multi MI(clk, rst, Memory_out, MemWrite, MemRead, Adr, B_out, V_in, C_in, Z_in, N_in);
	always #20 clk<=~clk;
	initial begin
		rst=1;
		#21 rst=0;
		#18500 $stop;
	end
endmodule
