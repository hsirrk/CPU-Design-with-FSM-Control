module vMUX (sel, in1, in0, out);
	parameter n = 16;
	input sel;
	input [n-1:0] in1, in0;
	output [n-1:0] out;

	assign out = sel ? in1 : in0;
	
endmodule

module vMUX4 (sel, in3, in2, in1, in0, out);
	parameter n = 16;
	input [1:0] sel;
	input [n-1:0] in3, in2, in1, in0;
	output [n-1:0] out;
	
	reg [n-1:0] out;
	
	always_comb begin
		case(sel)
			2'b00 : out = in3; //mdata
			2'b01 : out = in2; //sximm8
			2'b10 : out = in1; //PC
			2'b11 : out = in0; //C
		endcase
	end
	
endmodule


module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, 
			writenum, write, /*datapath_in,*/ Z_out, datapath_out, sximm8, sximm5);
	input clk, loada, loadb, asel, bsel, loadc, loads, write;
	input [2:0] readnum, writenum;
	input [1:0] shift, ALUop, vsel;
	//input [15:0] datapath_in; //not connected to anything, replaced with sximm8
	output [2:0] Z_out; //3 bit status register
	output [15:0] datapath_out; //equal C
	reg [2:0] Z_out;
	
	wire [15:0] DatSOMA_Out, DataOut, RegAout, RegBout, shifterOut, SOMA_Out, SOMB_Out, ALUout;
	wire [2:0] ALU_Z, D; //3 bit now
	
	//temp wire
	wire [15:0] mdata = 16'd0;
	wire [7:0] PC = 8'd0;
	input [15:0] sximm8, sximm5; //these might be input?
	wire [15:0] C; //same as datapath_out but internal
	
	vMUX4 Writeback_Multiplexer(.sel(vsel), .in3(mdata), .in2(sximm8), .in1({8'b0, PC}), .in0(C), .out(DatSOMA_Out) );
	regfile REGFILE(.data_in(DatSOMA_Out), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(DataOut) );
	veDFF PipeLine_RegA(.en(loada), .clk(clk), .in(DataOut), .out(RegAout) );
	veDFF PipeLine_RegB(.en(loadb), .clk(clk), .in(DataOut), .out(RegBout) );
	shifter Shifter_Unit(.in(RegBout), .shift(shift), .sout(shifterOut) );
	vMUX Source_Op_MUXA(.sel(asel), .in1(16'b0), .in0(RegAout), .out(SOMA_Out) );
	vMUX Source_Op_MUXB(.sel(bsel), .in1(sximm5), .in0(shifterOut), .out(SOMB_Out) );
	ALU ALU(.Ain(SOMA_Out), .Bin(SOMB_Out), .ALUop(ALUop), .out(ALUout), .Z(ALU_Z) );
	veDFF PipeLine_RegC(.en(loadc), .clk(clk), .in(ALUout), .out(C) ); //change datapath_out to C and let C = datapath_out?
	
	assign datapath_out = C;
	
	//The Status DFF
	assign D = loads ? ALU_Z : Z_out;
	always_ff @(posedge clk) begin
		Z_out <= D;
	end
	
endmodule