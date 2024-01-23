`define n 16

module datapath_tb ();
	reg clk, loada, loadb, asel, bsel, loadc, loads, write, err;
	reg [2:0] readnum, writenum;
	reg [1:0] shift, ALUop, vsel;
	reg [15:0] sximm8, sximm5;
	wire [2:0] Z_out;
	wire [15:0] datapath_out;

	//The line below instantiate datapath as the device under test in this testbench
	datapath DUT(.clk(clk), 
					  .readnum(readnum), .vsel(vsel), .loada(loada), .loadb(loadb), 
					  .shift(shift), .asel(asel), .bsel(bsel), .ALUop(ALUop), 
					  .loadc(loadc), .loads(loads), .writenum(writenum), 
					  .write(write), .Z_out(Z_out), .datapath_out(datapath_out), .sximm8(sximm8), .sximm5(sximm5) );

	/*
	The task data_checker checks if specific outputs of modules is as expected. It outputs an 
	error message stating the actual value and the expected value if an error 
	occurs. It also sets error to 1 to be displayed on the waveform.
	*/
	task data_checker; 
		input [`n-1:0] expected_DataOut;
		input [`n-1:0] expected_sout;
		input [`n-1:0] expected_ALUout;
		input [2:0] expected_Z;
		input [`n-1:0] expected_datapath_out;

	begin
		if (datapath_tb.DUT.DataOut !== expected_DataOut ) begin
			$display("ERROR ** Regfile Output is %b, expected %b", datapath_tb.DUT.DataOut, expected_DataOut );
			err = 1'b1;
		end
		
		if (datapath_tb.DUT.shifterOut !== expected_sout ) begin
			$display("ERROR ** shifter Output is %b, expected %b", datapath_tb.DUT.shifterOut, expected_sout );
			err = 1'b1;
		end
		
		if (datapath_tb.DUT.ALUout !== expected_ALUout ) begin
			$display("ERROR ** ALU output is %b, expected %b", datapath_tb.DUT.ALUout, expected_ALUout );
			err = 1'b1;
		end
		
		if (datapath_tb.DUT.Z_out !== expected_Z ) begin
			$display("ERROR ** Z is %b, expected %b", datapath_tb.DUT.Z_out, expected_Z );
			err = 1'b1;
		end
		
		if (datapath_tb.DUT.datapath_out !== expected_datapath_out ) begin
			$display("ERROR ** Datapath_out is %b, expected %b", datapath_tb.DUT.datapath_out, expected_datapath_out );
			err = 1'b1;
		end
		
	end
	
	endtask
	
	task new_changes_checker;
		input [`n-1:0] expected_DataOut;
	
	begin
		if (datapath_tb.DUT.DataOut !== expected_DataOut ) begin
			$display("ERROR ** Regfile Output is %b, expected %b", datapath_tb.DUT.DataOut, expected_DataOut );
			err = 1'b1;
		end
	end
	
	endtask
	
	task loadb_a_checker;
		input [`n-1:0] expected_loadb;
		input [`n-1:0] expected_loada;

	begin
		if (datapath_tb.DUT.RegAout !== expected_loada ) begin
			$display("ERROR ** LoadA Output is %b, expected %b", datapath_tb.DUT.RegAout, expected_loada );
			err = 1'b1;
		end
		
		if (datapath_tb.DUT.RegBout !== expected_loadb ) begin
			$display("ERROR ** LoadB Output is %b, expected %b", datapath_tb.DUT.RegBout, expected_loadb );
			err = 1'b1;
		end
	end
	
	endtask
	
	initial begin //Sets the clock to be at a 5 time unit interval
		clk = 1'b0; 
		#5;
			repeat(45) begin
				clk = 1'b1; #5;
				clk = 1'b0; #5;
			end
	end
	
	initial begin
		//new changes test
		err = 1'b0;
		$display("checking mdata is 0 and is written to R0");
		write = 1'b1;
		writenum = 3'b000;
		readnum = 3'b000;
		sximm8 = 16'h42;
		sximm5 = 16'h13;
		vsel = 2'b00;
		#10;
		new_changes_checker(16'h0);
		
		$display("checking {8'b0, PC} - PC = 0 and is written to R1");
		writenum = 3'b001;
		readnum = 3'b001;
		vsel = 2'b10;
		#10;
		new_changes_checker(16'h0);
		
		$display("checking sximm8 = h42 and is written to R2");
		writenum = 3'b010;
		readnum = 3'b010;
		vsel = 2'b01;
		#10;
		new_changes_checker(16'h42);
		write = 1'b0; //set write = 0
		
		//Change in input: readnum = 0, loadb = 1
		//store R0 in register B
		$display("checking loadb = mdata (h0)");
		readnum = 3'b000;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'h0, 16'hx);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: readnum = 2, loada = 1
		//store R2 in register A
		$display("checking loada = sximm8 (h42)");
		readnum = 3'b010;
		loada = 1'b1;		
		#10;
		loadb_a_checker(16'b0, 16'h42);
		loada = 1'b0;
		
		//Change in input: asel = 0, bsel = 0, shift = 0, ALUop = 0, loadc = 1, loads = 1
		//Testing ADD Rn, R2, R0
		$display("checking ALUout = R2 + R0");
		asel = 1'b0;
		bsel = 1'b0;
		shift = 2'b00;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'h42, 16'h0, 16'h42, 3'b000, 16'h42);
		
		$display("checking C = h42 and is written to R3");
		write = 1'b1;
		writenum = 3'b011;
		readnum = 3'b011;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'h42);
		write = 1'b0;
		
		//Change in input: asel = 0, bsel = 1, shift = 0, ALUop = 0, loadc = 1, loads = 1
		//Testing Modification to Bin - sximm5
		$display("checking ALUout = R2 + sximm5");
		asel = 1'b0;
		bsel = 1'b1;
		shift = 2'b00;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'h42, 16'h0, 16'h55, 3'b000, 16'h55);
		
		$display("checking C = h55 and is written to R4");
		write = 1'b1;
		writenum = 3'b100;
		readnum = 3'b100;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'h55);
		write = 1'b0;
		
		//Change in input: readnum = 4, loada = 1
		//store R4 in register A
		$display("checking loada = C (h55)");
		readnum = 3'b100;
		loada = 1'b1;		
		#10;
		loadb_a_checker(16'b0, 16'h55);
		loada = 1'b0;
		
		//Change in input: asel = 0, bsel = 1, shift = 0, ALUop = 01, loadc = 1, loads = 1
		//Testing if status flag zero
		$display("checking ALUout = R2 - sximm5");
		sximm5 = 16'h55;
		asel = 1'b0;
		bsel = 1'b1;
		shift = 2'b00;
		ALUop = 2'b01;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'h55, 16'h0, 16'h0, 3'b001, 16'h0);
		
		$display("checking C = h0 and is written to R4");
		write = 1'b1;
		writenum = 3'b100;
		readnum = 3'b100;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'h0);
		write = 1'b0;
		
		//Change in input: readnum = 4, loada = 1
		//store R4 in register A
		$display("checking loada = C (h0)");
		readnum = 3'b100;
		loada = 1'b1;		
		#10;
		loadb_a_checker(16'b0, 16'h0);
		loada = 1'b0;
		
		//write h65 to R2
		$display("checking sximm8 = h65 and is written to R2");
		sximm8 = 16'h65;
		writenum = 3'b010;
		readnum = 3'b010;
		vsel = 2'b01;
		write = 1'b1;
		#10;
		new_changes_checker(16'h65);
		write = 1'b0; //set write = 0
		
		//Change in input: readnum = 2, loadb = 1
		//store R2 in register B
		$display("checking loadb = sximm8 (h65)");
		readnum = 3'b010;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'h65, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 0, bsel = 0, shift = 0, ALUop = 01, loadc = 1, loads = 1
		//Testing if status flag negative
		$display("checking ALUout = 0 - sximm8");
		asel = 1'b0;
		bsel = 1'b0;
		shift = 2'b00;
		ALUop = 2'b01;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'h65, 16'h65, 16'hFF9B, 3'b110, 16'hFF9B);
		
		$display("checking C = -65 and is written to R5");
		write = 1'b1;
		writenum = 3'b101;
		readnum = 3'b101;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'hFF9B);
		write = 1'b0;
		
		//write d127 to R2
		$display("checking sximm8 = d127 and is written to R2");
		sximm8 = 16'd127;
		writenum = 3'b010;
		readnum = 3'b010;
		vsel = 2'b01;
		write = 1'b1;
		#10;
		new_changes_checker(16'd127);
		write = 1'b0; //set write = 0
		
		//Change in input: readnum = 2, loadb = 1
		//store R2 in register B
		$display("checking loadb = sximm8 (d127)");
		readnum = 3'b010;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd127, 16'h0);
		loadb = 1'b0; //set loadb = 1

		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 1
		//Testing shifting
		$display("checking ALUout = 127 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'd127, 16'd254, 16'd254, 3'b000, 16'd254);
		
		$display("checking C = 254 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd254);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d254)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd254, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 1
		//Testing shifting
		$display("checking ALUout = 254 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b1;
		#10;
		data_checker(16'd254, 16'd508, 16'd508, 3'b000, 16'd508);
		
		$display("checking C = 508 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd508);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d508)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd508, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 508 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd508, 16'd1016, 16'd1016, 3'b000, 16'd1016);
		
		$display("checking C = 1016 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd1016);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d1016)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd1016, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 1016 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd1016, 16'd2032, 16'd2032, 3'b000, 16'd2032);
		
		$display("checking C = 2032 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd2032);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d2032)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd2032, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 2032 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd2032, 16'd4064, 16'd4064, 3'b000, 16'd4064);
		
		$display("checking C = 4064 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd4064);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d4064)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd4064, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 4064 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd4064, 16'd8128, 16'd8128, 3'b000, 16'd8128);

		$display("checking C = 8128 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd8128);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d8128)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd8128, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 8128 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd8128, 16'd16256, 16'd16256, 3'b000, 16'd16256);
		
		$display("checking C = 16256 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd16256);
		write = 1'b0;
		
		//Change in input: readnum = 6, loadb = 1
		//store R2 in register B
		$display("checking loadb = C (d16256)");
		readnum = 3'b110;
		loadb = 1'b1;
		#10;
		loadb_a_checker(16'd16256, 16'h0);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing shifting
		$display("checking ALUout = 16256 shifter left once");
		asel = 1'b1;
		bsel = 1'b0;
		shift = 2'b01;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b0; //status stays the same as before
		#10;
		data_checker(16'd16256, 16'd32512, 16'd32512, 3'b000, 16'd32512);
		
		$display("checking C = 32512 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'd32512);
		write = 1'b0;
		
		//Change in input: readnum = 6, loada = 1
		//store R2 in register B
		$display("checking loada = C (d32512)");
		readnum = 3'b110;
		loada = 1'b1;
		#10;
		loadb_a_checker(16'd16256, 16'd32512);
		loadb = 1'b0; //set loadb = 1
		
		//Change in input: asel = 1, bsel = 0, shift = 01, ALUop = 0, loadc = 1, loads = 0
		//Testing if status flag overflow
		$display("checking ALUout = 32512 + 256 = -32768, not 32768");
		sximm5 = 16'd256;
		asel = 1'b0;
		bsel = 1'b1;
		shift = 2'b00;
		ALUop = 2'b00;
		loadc = 1'b1;
		loads = 1'b1; //change loads to test status
		#10;
		data_checker(16'd32512, 16'd16256, 16'h8000, 3'b110, 16'h8000);
		
		$display("checking C = -32768 and is written to R6");
		write = 1'b1;
		writenum = 3'b110;
		readnum = 3'b110;
		vsel = 2'b11;
		#10;
		new_changes_checker(16'h8000);
		write = 1'b0;
		
		#300;
		
	
		
		if (~err) $display("PASSED");
		else $display ("FAILED");
		$stop;
	end


endmodule: datapath_tb