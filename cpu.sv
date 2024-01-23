`define Rm 2'b00 //gotta change these, binary? one-hot?
`define Rd 2'b01
`define Rn 2'b11

`define Instruct_MOV_1 5'b11010
`define Instruct_MOV_2 5'b11000
`define Instruct_ALU_ADD 5'b10100
`define Instruct_ALU_CMP 5'b10101
`define Instruct_ALU_AND 5'b10110
`define Instruct_ALU_MVN 5'b10111

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

`define REGLOAD 4'b0000
`define RM_LOAD_B 4'b0001
`define RM_LOAD_C 4'b0010
`define RM_WRITE 4'b0011
`define RN_LOAD_A 4'b0100
`define ALU_ADD 4'b0101
`define ALU_WRITE 4'b0110
`define ALU_SUB 4'b0111
`define Instruct_Reset 4'b1000

/*
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
*/

module instruction_Dec (in, in_FSM, out_ALUop, out_shift, out_readnum, out_writenum, out_sximm5, out_sximm8, out_FSM);
	parameter n = 2;
	input [15:0] in;
	input [n-1:0] in_FSM;
	output [1:0] out_ALUop, out_shift;
	output [2:0] out_readnum, out_writenum;
	output [15:0] out_sximm5, out_sximm8;
	output [4:0] out_FSM;
	
	reg [2:0] out_readnum, out_writenum;
	
	assign out_ALUop = in[12:11];
	assign out_shift = in[4:3];
	assign out_sximm5 = {{11{in[4]}} , in[4:0]};
	assign out_sximm8 = {{8{in[7]}} , in[7:0]};
	assign out_FSM = in[15:11]; //out_FSM[4:2] = in [15:13], out_FSM[1:0] = in[12:11]
	
	always_comb begin
		case(in_FSM)
			`Rm : begin
						out_writenum = in[2:0];
						out_readnum = in[2:0];
					end
			`Rd : begin
						out_writenum = in[7:5];
						out_readnum = in[7:5];
					end
			`Rn : begin
						out_writenum = in[10:8];
						out_readnum = in[10:8];
					end
					
			default : begin
							out_writenum = {3{1'bx}};
							out_readnum = {3{1'bx}};
						 end
		endcase
	end


endmodule: instruction_Dec

module stateMachine (clk, reset, S, opcode, op, nsel, datapath, W);
	input clk, reset, S;
	input [2:0] opcode;
	input [1:0] op;
	output W;
	output [1:0] nsel;
	output [8:0] datapath;

	reg W;
	reg [1:0] nsel;
	reg [8:0] datapath;
	reg [3:0] ps; //present state
	reg [3:0] state_action;
	//reg [4:0] OPCODE;
	
	//assign OPCODE = {opcode, op};
	
	always_ff @(posedge clk) begin
		W <= 1'b0;
			
		if (reset) begin
			ps <= `RS; //reset
			state_action <= `Instruct_Reset;
			if (~S)
				W <= 1'b1;
		end
		
		case(ps)
			//`RS_Wait : begin
			//					ps <= `RS;
			//					state_action <= `Instruct_Reset;
			//				end
			
			`RS : begin
						state_action <= `Instruct_Reset;
						
						if (~S)
							W <= 1'b1;
						//else
							//W <= 1'b0;
					
					if (S) begin
						case ({opcode, op}) 
							`Instruct_MOV_1 : begin 
														//ps <= `RS_Wait;
														ps <= `RS;
														state_action <= `REGLOAD;
													end
							`Instruct_MOV_2 : begin
														ps <= `RM_shift_load_b;
														state_action <= `RM_LOAD_B;
													end
							`Instruct_ALU_ADD : begin
														ps <= `RM_shift_load_b;
														state_action <= `RM_LOAD_B;
													end
							`Instruct_ALU_CMP : begin
														ps <= `RM_shift_load_b;
														state_action <= `RM_LOAD_B;
													end
							`Instruct_ALU_AND : begin //same as ADD, loadb, loada, loadc, write
														ps <= `RM_shift_load_b;
														state_action <= `RM_LOAD_B;
													end
							`Instruct_ALU_MVN : begin
														ps <= `RM_shift_load_b;
														state_action <= `RM_LOAD_B;
													end
						endcase
					end
					end
			`RM_shift_load_b : if (opcode == 3'b110) begin 
										ps <= `RM_shift_load_C;
										state_action <= `RM_LOAD_C;
									end
									
									else begin
										if(op == 2'b11) begin
											ps <= `ALU_add;
											state_action <= `ALU_ADD;
										end
										else begin
											ps <= `RN_load_A;
											state_action <= `RN_LOAD_A;
										end
									end
									

			`RM_shift_load_C : begin
										ps <= `RS;
										state_action <= `RM_WRITE;
									end
			`RN_load_A : begin
								case(op)
									2'b00 : begin
												ps <= `ALU_add;
												state_action <= `ALU_ADD;
											  end
									2'b01 : begin
												ps <= `RS;
												state_action <= `ALU_SUB;
											  end
									2'b10 : begin
												ps <= `ALU_add;
												state_action <= `ALU_ADD;
											  end
									default : begin
												ps <= `RS;
												state_action <= `Instruct_Reset;
											  end
								endcase
			  				  end
			`ALU_add : begin
								ps <= `RS;
								state_action <= `ALU_WRITE;
							end
				
		endcase
			
	
	end
	
	always_comb begin
		
		
		case(state_action)
			`Instruct_Reset : begin
										nsel = 2'b00;
										datapath[8:0] = 9'd0;
									end
			
			`REGLOAD : begin
										nsel = 2'b11; //nsel
										datapath[1:0] = 2'b01; //vsel
										datapath[8:2] = { {6{1'b0}}, 1'b1}; //[8] = loads, [7] = loadc, [6] = bsel, [5] = asel, [4] = loadb, [3] = loada, [2] = write
										
								  end
			//MOV Rd, Rm{, <sh_op>}
			`RM_LOAD_B : begin //need to find a way to seqeuentially move through these states
										nsel = 2'b00;
										datapath[1:0] = 2'b00;
										datapath[8:2] = 7'b0000100; //loadb = 1
										
								  end
			`RM_LOAD_C : begin
										nsel = 2'b00;
										datapath[1:0] = 2'b00;
										datapath[8:2] = 7'b0101000; //loadc, asel = 1
										
								  end
			`RM_WRITE :  begin
										nsel = 2'b01;
										datapath[1:0] = 2'b11;
										datapath[8:2] = 7'b0000001; //write = 1
										
										//ps <= `RS;
								  end //goes back to reset
			`RN_LOAD_A : begin
										nsel = 2'b11;
										datapath[1:0] = 2'b00;
										datapath[8:2] = 7'b0000010; //loada = 1
									
									end
			`ALU_ADD : begin
										nsel = 2'b11;
										datapath[1:0] = 2'b00;
										datapath[8:2] = 7'b0100000; //loadc = 1
										
									
									end
									
			`ALU_SUB : begin
										nsel = 2'b00;
										datapath[1:0] = 2'b00;
										datapath[8:2] = 7'b1000000; //loads = 1
										
										//ps <= `RS;
									end
			
			`ALU_WRITE : /*if (op == 2'b01) begin
										datapath[1:0] = 2'b11;
										datapath[3:1] = 2'b11;
										datapath[10:4] = 7'b0000001; //write = 1
										
										ps = `RS;
							end 
							else *///write for CMP, but not even writing anything to register, so don't need?
							begin
										nsel = 2'b01;
										datapath[1:0] = 2'b11;
										datapath[8:2] = 7'b0000001; //write = 1
										
										//ps <= `RS;
							end
		endcase
		
		
	end
	
endmodule: stateMachine

module cpu(clk,reset,s,load,in,out,N,V,Z,w);
	input clk, reset, s, load;
	input [15:0] in;
	output [15:0] out;
	output N, V, Z, w;
	
	wire [15:0] Instruct_Reg_out;
	wire [4:0] OPCode;
	wire [1:0] NSEL;
	wire [8:0] FSM_datapath; 
	wire [31:0] imm5_8;
	wire [9:0] DEC_datapath;
	
	veDFF Instrut_Reg (.en(load), .clk(clk), .in(in), .out(Instruct_Reg_out) );
	instruction_Dec Instrct_DEC (.in(Instruct_Reg_out), .in_FSM(NSEL), .out_ALUop(DEC_datapath[3:2]), .out_shift(DEC_datapath[1:0]), .out_readnum(DEC_datapath[9:7]), .out_writenum(DEC_datapath[6:4]), .out_sximm5(imm5_8[31:16]), .out_sximm8(imm5_8[15:0]), .out_FSM(OPCode));
	stateMachine FSM(.clk(clk), .reset(reset), .S(s), .opcode(OPCode[4:2]), .op(OPCode[1:0]), .nsel(NSEL), .datapath(FSM_datapath), .W(w) );
	datapath DP(.clk(clk), .readnum(DEC_datapath[9:7]), .vsel(FSM_datapath[1:0]), .loada(FSM_datapath[3]), .loadb(FSM_datapath[4]), .shift(DEC_datapath[1:0]), .asel(FSM_datapath[5]), .bsel(FSM_datapath[6]), .ALUop(DEC_datapath[3:2]), .loadc(FSM_datapath[7]), .loads(FSM_datapath[8]), 
			.writenum(DEC_datapath[6:4]), .write(FSM_datapath[2]), /*.datapath_in(),*/ .Z_out({V, N, Z}), .datapath_out(out), .sximm8(imm5_8[15:0]), .sximm5(imm5_8[31:16]) );
	
endmodule: cpu