`define plus  2'b00
`define minus 2'b01
`define aand  2'b10
`define nnot  2'b11

module ALU(Ain,Bin,ALUop,out,Z);
	input [15:0] Ain, Bin;
	input [1:0] ALUop;
	output [15:0] out;
	output [2:0] Z; //3 bit status register
	reg [2:0] Z;
	reg [15:0] out;
	// fill out the rest
	
	always_comb begin
		case(ALUop)
			`plus : out = Ain + Bin;
			`minus : out = Ain - Bin;
			`aand : out = Ain & Bin;
			`nnot : out = ~Bin;
		
			default : out = {16{1'bx}};
		endcase
		
		if (out == 16'd0) //check Z, if zero
			Z[0] = 1'b1;
		else
			Z[0] = 1'b0;
			
		if (out[15] == 1'b1) //check N, if negative
			Z[1] = 1'b1;
		else
			Z[1] = 1'b0;
			
		case(ALUop) //check V, if overflow
			`plus : begin
							if (Ain[15] == Bin[15]) begin
								if (out[15] == Ain[15])
									Z[2] = 1'b0;
								else
									Z[2] = 1'b1;
							end
							else
								Z[2] = 1'b0;
						end
			`minus : begin
							if (Ain[15] == Bin[15]) begin
								if (out[15] == Ain[15])
									Z[2] = 1'b0;
								else
									Z[2] = 1'b1;
							end
							else
								Z[2] = 1'b0;
						end
			`aand : Z[2] = 1'b0;
			`nnot : Z[2] = 1'b0;		
		endcase
	end
	
endmodule: ALU
