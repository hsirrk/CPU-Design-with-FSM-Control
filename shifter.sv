`define shift0 2'b00
`define shift1 2'b01
`define shift2 2'b10
`define shift3 2'b11

module shifter(in,shift,sout);
	input [15:0] in;
	input [1:0] shift;
	output reg signed [15:0] sout;
	
	
	
	
	always_comb begin
		case(shift)
			`shift0 : sout = in;
			`shift1 : sout = in << 1;
			`shift2 : sout = in >> 1;
			`shift3 : sout = {in[15] , in[15:1]};
			
			default : sout = {16{1'bx}};
		endcase
		
	end
	
endmodule: shifter
