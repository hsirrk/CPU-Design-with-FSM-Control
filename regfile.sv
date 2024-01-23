`define S0 3'b000
`define S1 3'b001
`define S2 3'b010
`define S3 3'b011
`define S4 3'b100
`define S5 3'b101
`define S6 3'b110
`define S7 3'b111
`define OUT0 8'b00000001
`define OUT1 8'b00000010
`define OUT2 8'b00000100
`define OUT3 8'b00001000
`define OUT4 8'b00010000
`define OUT5 8'b00100000
`define OUT6 8'b01000000
`define OUT7 8'b10000000

module veDFF (en, clk, in, out);
	parameter n = 16;
	input en, clk;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;
	wire [n-1:0] D;
	
	assign D = en ? in : out;
	
	always_ff @(posedge clk) begin
		out <= D;
	end
endmodule: veDFF
	
module Decoder (in, out);
	parameter n = 3;
	parameter m = 8;
	
	input [n-1:0] in;
	output [m-1:0] out;
	
	wire [m-1:0] out = 1 << in;
	
endmodule: Decoder

module regfile(data_in,writenum,write,readnum,clk,data_out);
	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write, clk;
	output [15:0] data_out;
	reg [15:0] data_out;
// fill out the rest

	wire [7:0] Dec_Out1;
	wire [7:0] Dec_Out2;	
	wire [7:0] DFFLoad;
	wire [15:0] R0;
	wire [15:0] R1;
	wire [15:0] R2;
	wire [15:0] R3;
	wire [15:0] R4;
	wire [15:0] R5;
	wire [15:0] R6;
	wire [15:0] R7;

	Decoder D1(.in(writenum), .out(Dec_Out1));
	Decoder D2(.in(readnum), .out(Dec_Out2));

	veDFF RR0(.en(DFFLoad[0]), .clk(clk), .in(data_in), .out(R0) );
	veDFF RR1(.en(DFFLoad[1]), .clk(clk), .in(data_in), .out(R1) );
	veDFF RR2(.en(DFFLoad[2]), .clk(clk), .in(data_in), .out(R2) );
	veDFF RR3(.en(DFFLoad[3]), .clk(clk), .in(data_in), .out(R3) );
	veDFF RR4(.en(DFFLoad[4]), .clk(clk), .in(data_in), .out(R4) );
	veDFF RR5(.en(DFFLoad[5]), .clk(clk), .in(data_in), .out(R5) );
	veDFF RR6(.en(DFFLoad[6]), .clk(clk), .in(data_in), .out(R6) );
	veDFF RR7(.en(DFFLoad[7]), .clk(clk), .in(data_in), .out(R7) );
	
	assign DFFLoad = Dec_Out1 & {8{write}};

	always_comb begin
		case (Dec_Out2)
			`OUT0 : data_out = R0;
			`OUT1 : data_out = R1;
			`OUT2 : data_out = R2;
			`OUT3 : data_out = R3;
			`OUT4 : data_out = R4;
			`OUT5 : data_out = R5;
			`OUT6 : data_out = R6;
			`OUT7 : data_out = R7;
			
			default: data_out = {8{1'bx}};
		endcase
	end
endmodule: regfile
