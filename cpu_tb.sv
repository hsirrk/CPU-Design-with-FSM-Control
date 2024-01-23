`define n 16

`define RS 4'b0000
`define Register_load 4'b0001
`define RM_shift_load_b 4'b0010
`define RM_shift_load_C 4'b0011
`define RM_shift_write 4'b0100
`define RN_load_A 4'b0101
`define ALU_add 4'b0110
`define ALU_write 4'b0111
`define ALU_sub 4'b1000
`define RS_Wait 4'b1001

module cpu_tb ();
	reg clk, reset, s, load, err;
	reg [15:0] in;
	wire [15:0] out;
	wire N, V, Z, w;



	cpu DUT(.clk(clk), .reset(reset), .s(s), .load(load), .in(in), .out(out), .N(N), .V(V), .Z(Z), .w(w) );

	task state_checker;
		input [3:0] expected_STATE;
	
	begin
		if (cpu_tb.DUT.FSM.ps !== expected_STATE ) begin
			$display("ERROR ** Regfile Output is %b, expected %b", cpu_tb.DUT.FSM.ps, expected_STATE );
			err = 1'b1;
		end
	end
	
	endtask
	
	task status_checker;
		input expected_V;
		input expected_N;
		input expected_Z;
	
	begin
		if (cpu_tb.DUT.V !== expected_V ) begin
			$display("ERROR ** V Output is %b, expected %b", cpu_tb.DUT.V, expected_V );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.N !== expected_N ) begin
			$display("ERROR ** N Output is %b, expected %b", cpu_tb.DUT.N, expected_N );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.Z !== expected_Z ) begin
			$display("ERROR ** Z Output is %b, expected %b", cpu_tb.DUT.Z, expected_Z );
			err = 1'b1;
		end
	end
	
	endtask
	
	task REG_checker; 
		input [`n-1:0] expected_R0;
		input [`n-1:0] expected_R1;
		input [`n-1:0] expected_R2;
		input [`n-1:0] expected_R3;
		input [`n-1:0] expected_R4;
		input [`n-1:0] expected_R5;
		input [`n-1:0] expected_R6;
		input [`n-1:0] expected_R7;

	begin
		if (cpu_tb.DUT.DP.REGFILE.R0 !== expected_R0 ) begin
			$display("ERROR ** R0 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R0, expected_R0 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R1 !== expected_R1 ) begin
			$display("ERROR ** R1 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R1, expected_R1 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R2 !== expected_R2 ) begin
			$display("ERROR ** R2 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R2, expected_R2 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R3 !== expected_R3 ) begin
			$display("ERROR ** R3 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R3, expected_R3 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R4 !== expected_R4 ) begin
			$display("ERROR ** R4 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R4, expected_R4 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R5 !== expected_R5 ) begin
			$display("ERROR ** R5 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R5, expected_R5 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R6 !== expected_R6 ) begin
			$display("ERROR ** R6 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R6, expected_R6 );
			err = 1'b1;
		end
		
		if (cpu_tb.DUT.DP.REGFILE.R7 !== expected_R7 ) begin
			$display("ERROR ** R7 is %b, expected %b", cpu_tb.DUT.DP.REGFILE.R7, expected_R7 );
			err = 1'b1;
		end
		
	end
	
	endtask

	initial begin //Sets the clock to be at a 5 time unit interval
		clk = 1'b0; 
		#5;
			forever begin
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
		state_checker(`RS);
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
		s = 1'b0;
		#10; //two clk cycle, 1st cycle, FSM changes and input to datapath is changed, 2nd cycle - register file is updated
		state_checker(`RS);
		REG_checker(16'h42, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);
		
		
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
		state_checker(`RS);
		REG_checker(16'h42, 16'h13, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);
		
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
		state_checker(`RS);
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);

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
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadc, datapath loadb
		state_checker(`RM_shift_load_C);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h84, 16'bx, 16'bx, 16'bx, 16'bx);
		
		$display("checking MOV R4, R0, LSR#1");
		load = 1'b1;
		in = 16'b1100010010010000; //MOV R4, R0, LSR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadc, datapath loadb
		state_checker(`RM_shift_load_C);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h84, 16'h21, 16'bx, 16'bx, 16'bx);
		
		$display("checking MOV R5, R0");
		load = 1'b1;
		in = 16'b1100010010100000; //MOV R5, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadc, datapath loadb
		state_checker(`RM_shift_load_C);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h84, 16'h21, 16'h42, 16'bx, 16'bx);
		
		$display("checking MOV R6, R2, ASR#1");
		load = 1'b1;
		in = 16'b1100010011011010; //MOV R6, R0, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadc, datapath loadb
		state_checker(`RM_shift_load_C);
		#10; //FSM output instruction to write to REG, state reset, datapath loadc
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h84, 16'h21, 16'h42, 16'hFFC0, 16'bx);

//TESTING INSTURCTION ADD Rd, Rn, Rm{, <sh_op>}
		$display("checking ADD R3, R0, R1");
		load = 1'b1;
		in = 16'b1010000001100001; //ADD R3, R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h55, 16'h21, 16'h42, 16'hFFC0, 16'bx);

		$display("checking ADD R4, R0, R1, LSL#1");
		load = 1'b1;
		in = 16'b1010000010001001; //ADD R4, R0, R1, LSL#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h55, 16'h68, 16'h42, 16'hFFC0, 16'bx);
		
		$display("checking ADD R5, R1, R2, LSR#1");
		load = 1'b1;
		in = 16'b1010000110110010; //ADD R5, R1, R2, LSR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h55, 16'h68, 16'h7FD3, 16'hFFC0, 16'bx);
	
		$display("checking ADD R7, R1, R2, ASR#1");
		load = 1'b1;
		in = 16'b1010000111111010; //ADD R5, R1, R2, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h13, 16'hFF80, 16'h55, 16'h68, 16'h7FD3, 16'hFFC0, 16'hFFD3);
		
//TESTING INSTURCTION CMP Rn, Rm{, <sh_op>}
		$display("checking CMP R0, R1");
		load = 1'b1;
		in = 16'b1010100011100001; //CMP R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b0, 1'b0, 1'b0);
		
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
		state_checker(`RS);
		REG_checker(16'h42, 16'h42, 16'hFF80, 16'h55, 16'h68, 16'h7FD3, 16'hFFC0, 16'hFFD3);

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
		state_checker(`RS);
		REG_checker(16'h42, 16'h42, 16'hFF80, 16'h21, 16'h68, 16'h7FD3, 16'hFFC0, 16'hFFD3);

		$display("checking CMP R0, R1");
		load = 1'b1;
		in = 16'b1010100011100001; //CMP R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b0, 1'b0, 1'b1);
		
		$display("checking CMP R0, R3, LSL#1");
		load = 1'b1;
		in = 16'b1010100011101011; //CMP R0, R3
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b0, 1'b0, 1'b1);
		
		$display("checking CMP R3, R1, LSR#1");
		load = 1'b1;
		in = 16'b1010101111110001; //CMP R3, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b0, 1'b0, 1'b1);
		
		$display("checking CMP R3, R1");
		load = 1'b1;
		in = 16'b1010101111100001; //CMP R3, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b1, 1'b1, 1'b0);
		
		//Testing Overflow
		$display("checking CMP R2, R6");
		load = 1'b1;
		in = 16'b1010101011100110; //CMP R0, R6
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to subtract, state reset, datapath loada
		state_checker(`RS);
		#10; //datapath perform subtraction
		status_checker(1'b0, 1'b1, 1'b0);
		
//TESTING INSTURCTION AND Rd, Rn, Rm{, <sh_op>}
		$display("checking AND R5, R0, R1");
		load = 1'b1;
		in = 16'b1011000010100001; //ADD R5, R0, R1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h42, 16'hFF80, 16'h21, 16'h68, 16'h42, 16'hFFC0, 16'hFFD3);
		
		//Testing AND with positive and negative number
		$display("checking AND R7, R0, R2");
		load = 1'b1;
		in = 16'b1011000011100010; //ADD R7, R0, R2
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h42, 16'hFF80, 16'h21, 16'h68, 16'h42, 16'hFFC0, 16'h0);
		
		//Testing AND with positive but shifted to right by 1
		$display("checking AND R3, R0, R1, LSR#1");
		load = 1'b1;
		in = 16'b1011000001110001; //ADD R3, R0, R2
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to loadA, datapath loadb
		state_checker(`RN_load_A);
		#10; //FSM output instruction to add, datapath loada
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath perform addition
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'h42, 16'hFF80, 16'h0, 16'h68, 16'h42, 16'hFFC0, 16'h0);
		
//TESTING INSTURCTION MVN Rd, Rm{, <sh_op>}
		$display("checking MVN R1, R0");
		load = 1'b1;
		in = 16'b1011100000100000; //MVN R1, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to MVN, datapath loadb
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'h42, 16'hFFBD, 16'hFF80, 16'h0, 16'h68, 16'h42, 16'hFFC0, 16'h0);
		
		$display("checking MVN R0, R0");
		load = 1'b1;
		in = 16'b1011100000000000; //MVN R0, R0
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to MVN, datapath loadb
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'hFFBD, 16'hFFBD, 16'hFF80, 16'h0, 16'h68, 16'h42, 16'hFFC0, 16'h0);
		
		$display("checking MVN R3, R4, ASR#1");
		load = 1'b1;
		in = 16'b1011100001111100; //MVN R3, R4, ASR#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to MVN, datapath loadb
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'hFFBD, 16'hFFBD, 16'hFF80, 16'hFFCB, 16'h68, 16'h42, 16'hFFC0, 16'h0);
		
		$display("checking MVN R7, R2, LSL#1");
		load = 1'b1;
		in = 16'b1011100011101010; //MVN R7, R2, LSL#1
		#10;
		load = 1'b0;
		s = 1'b1;		
		#10; //FSM output instruction to loadb
		s = 1'b0;
		state_checker(`RM_shift_load_b);
		#10; //FSM output insturction to MVN, datapath loadb
		state_checker(`ALU_add);
		#10; //FSM output instruction to write to REG, state reset, datapath MVN
		state_checker(`RS);
		#10; //datapath write to REG
		REG_checker(16'hFFBD, 16'hFFBD, 16'hFF80, 16'hFFCB, 16'h68, 16'h42, 16'hFFC0, 16'h00FF);
		
		#10;
		
		if (~err) $display("PASSED");
		else $display ("FAILED");
		$stop;
	end

endmodule: cpu_tb