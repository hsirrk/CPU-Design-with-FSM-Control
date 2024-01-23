`define n 16

`timescale 1ps / 1ps

module cpu_gate_tb ();
	reg clk, reset, s, load, err;
	reg [15:0] in;
	wire [15:0] out;
	wire N, V, Z, w;



	cpu DUT(.clk(clk), .reset(reset), .s(s), .load(load), .in(in), .out(out), .N(N), .V(V), .Z(Z), .w(w) );

	task out_checker;
		input [15:0] expected_OUT;
	
	begin
		if (out !== expected_OUT ) begin
			$display("ERROR ** Datapath Output is %b, expected %b", out, expected_OUT );
			err = 1'b1;
		end
	end
	
	endtask
	
	task w_checker;
		input expected_w;
	
	begin
		if (w !== expected_w ) begin
			$display("ERROR ** w Output is %b, expected %b", w, expected_w );
			err = 1'b1;
		end
	end
	
	endtask
	
	task status_checker;
		input expected_V;
		input expected_N;
		input expected_Z;
	
	begin
		if (V !== expected_V ) begin
			$display("ERROR ** V Output is %b, expected %b", V, expected_V );
			err = 1'b1;
		end
		
		if (N !== expected_N ) begin
			$display("ERROR ** N Output is %b, expected %b", N, expected_N );
			err = 1'b1;
		end
		
		if (Z !== expected_Z ) begin
			$display("ERROR ** Z Output is %b, expected %b", Z, expected_Z );
			err = 1'b1;
		end
	end
	
	endtask

	initial begin //Sets the clock to be at a 5 time unit interval
		clk = 1'b0; 
		#5;
			repeat(140) begin
				clk = 1'b1; #5;
				clk = 1'b0; #5;
			end
	end

	
	initial begin
//TESTING INSTURCTION MOV Rn, #<im8>
		//reset = 1, resetting the circuit
		err = 1'b0;
		s = 1'b0;
		load = 1'b0;
		$display("checking state = RS when reset = 1");
		reset = 1'b1;
		#10; //one clk cycle
		out_checker(16'd0);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		reset = 1'b0; //reset = 0
		
		#10; //to check if w output 1 when s = 0 and in reset state
		
		//s,load = 1, in changes
		//Testing MOV R0, #42
		$display("checking MOV R0, #42");
		load = 1'b1;
		in = 16'b1101000001000010; //MOV R0, #42
		#10; //one clk cycle for instruction register to output
		load = 1'b0;
		s = 1'b1; //start FSM
		#10;
		w_checker(1'b0); //state reset, but s = 1, so w = 0
		s = 1'b0;
		#10; //two clk cycle, 1st cycle, FSM changes and input to datapath is changed, 2nd cycle - register file is updated
		out_checker(16'd0);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		
		//s,load = 1, in changes
		//Testing MOV R1, #13
		$display("checking MOV R1, #13");
		load = 1'b1;
		in = 16'b1101000100010011; //MOV R1, #13
		#10;
		load = 1'b0;
		s = 1'b1;
		#10;
		s = 1'b0;
		#10;
		//only two clk cycle needed because instruction is same as previous, don't need another cycle for FSM to up datapath input - same
		out_checker(16'd0);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		//s,load = 1, in changes
		//Testing MOV R2, #13 - Signed extension
		$display("checking MOV R2, #80");
		load = 1'b1;
		in = 16'b1101001010000000; //MOV R2, #80
		#10;
		load = 1'b0;
		s = 1'b1;
		#10;
		s = 1'b0;
		#10;
		out_checker(16'd0);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);

//TESTING INSTURCTION MOV Rd, Rm{, <sh_op>}
		s = 1'b0;
		#20; //checking if w = 1 cause in reset state and waiting for s = 1
		
		//testing if instruction_register does not output when load = 0
		load = 1'b0;
		in = 16'b1100001001101000; //MOV R3, R0, LSL#1
		#10;
		
		//load new instruction into Instruction Register
		load = 1'b1;
		#10;
		load = 1'b0;
		s = 1'b1;
		#10; //FSM output instruction to loadb
		s = 1'b0;
		
		$display("checking MOV R3, R0, LSL#1");
		w_checker(1'b0);
		#10; //FSM output insturction to loadc, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h84);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		$display("checking MOV R4, R0, LSR#1");
		load = 1'b1;
		in = 16'b1100010010010000; //MOV R4, R0, LSR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadc, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h21);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		$display("checking MOV R5, R0");
		load = 1'b1;
		in = 16'b1100010010100000; //MOV R5, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadc, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h42);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);	
		
		$display("checking MOV R6, R2, ASR#1");
		load = 1'b1;
		in = 16'b1100010011011010; //MOV R6, R0, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadc, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'hFFC0);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);	
		
//TESTING INSTURCTION ADD Rd, Rn, Rm{, <sh_op>}
		$display("checking ADD R3, R0, R1");
		load = 1'b1;
		in = 16'b1010000001100001; //ADD R3, R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h55);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		$display("checking ADD R4, R0, R1, LSL#1");
		load = 1'b1;
		in = 16'b1010000010001001; //ADD R4, R0, R1, LSL#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h68);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		$display("checking ADD R5, R1, R2, LSR#1");
		load = 1'b1;
		in = 16'b1010000110110010; //ADD R5, R1, R2, LSR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h7FD3);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);
		
		$display("checking ADD R7, R1, R2, ASR#1");
		load = 1'b1;
		in = 16'b1010000111111010; //ADD R5, R1, R2, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);	
		
//TESTING INSTURCTION CMP Rn, Rm{, <sh_op>}
		$display("checking CMP R0, R1");
		load = 1'b1;
		in = 16'b1010100011100001; //CMP R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);		
		
		//s,load = 1, in changes
		//Testing MOV R1, #42
		$display("checking MOV R1, #42");
		load = 1'b1;
		in = 16'b1101000101000010; //MOV R1, #42
		#10; //one clk cycle for instruction register to output
		load = 1'b0;
		s = 1'b1; //start FSM
		#10;
		s = 1'b0;
		#10; //two clk cycle, 1st cycle, FSM changes and input to datapath is changed, 2nd cycle - register file is updated
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);

		//s,load = 1, in changes
		//Testing MOV R3, #84
		$display("checking MOV R3, #21");
		load = 1'b1;
		in = 16'b1101001100100001; //MOV R3, #21
		#10; //one clk cycle for instruction register to output
		load = 1'b0;
		s = 1'b1; //start FSM
		#10;
		s = 1'b0;
		#10; //two clk cycle, 1st cycle, FSM changes and input to datapath is changed, 2nd cycle - register file is updated
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b0);
		w_checker(1'b1);

		$display("checking CMP R0, R1");
		load = 1'b1;
		in = 16'b1010100011100001; //CMP R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b1);
		w_checker(1'b1);
		
		$display("checking CMP R0, R3, LSL#1");
		load = 1'b1;
		in = 16'b1010100011101011; //CMP R0, R3
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b1);
		w_checker(1'b1);
		
		$display("checking CMP R3, R1, LSR#1");
		load = 1'b1;
		in = 16'b1010101111110001; //CMP R3, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b0, 1'b1);
		w_checker(1'b1);
		
		$display("checking CMP R3, R1");
		load = 1'b1;
		in = 16'b1010101111100001; //CMP R3, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b1, 1'b1, 1'b0);
		w_checker(1'b1);	
		
		//Testing Overflow
		$display("checking CMP R2, R6");
		load = 1'b1;
		in = 16'b1010101011100110; //CMP R0, R6
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		w_checker(1'b0);
		#10; //datapath perform subtraction
		out_checker(16'hFFD3);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);	
		
//TESTING INSTURCTION AND Rd, Rn, Rm{, <sh_op>}
		$display("checking AND R5, R0, R1");
		load = 1'b1;
		in = 16'b1011000010100001; //ADD R5, R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h42);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);	
		
		//Testing AND with positive and negative number
		$display("checking AND R7, R0, R2");
		load = 1'b1;
		in = 16'b1011000011100010; //ADD R7, R0, R2
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h0);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);	
		
		//Testing AND with positive but shifted to right by 1
		$display("checking AND R3, R0, R1, LSR#1");
		load = 1'b1;
		in = 16'b1011000001110001; //ADD R3, R0, R2
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to loadA, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to add, datapath loada
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h0);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);
		
//TESTING INSTURCTION MVN Rd, Rm{, <sh_op>}
		$display("checking MVN R1, R0");
		load = 1'b1;
		in = 16'b1011100000100000; //MVN R1, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to MVN, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'hFFBD);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);
		
		$display("checking MVN R0, R0");
		load = 1'b1;
		in = 16'b1011100000000000; //MVN R0, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to MVN, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'hFFBD);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);
		
		$display("checking MVN R3, R4, ASR#1");
		load = 1'b1;
		in = 16'b1011100001111100; //MVN R3, R4, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to MVN, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'hFFCB);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);	
		
		$display("checking MVN R7, R2, LSL#1");
		load = 1'b1;
		in = 16'b1011100011101010; //MVN R7, R2, LSL#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		w_checker(1'b0);
		#10; //FSM output insturction to MVN, datapath loadb
		w_checker(1'b0);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		w_checker(1'b0);
		#10; //datapath write to REG
		out_checker(16'h00FF);
		status_checker(1'b0, 1'b1, 1'b0);
		w_checker(1'b1);	
		
		#10;
		
		if (~err) $display("PASSED");
		else $display ("FAILED");
		$stop;
	end

endmodule: cpu_gate_tb