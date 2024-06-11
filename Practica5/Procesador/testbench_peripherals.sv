/*
 * Testbench to test the peripherals part
 */ 
module testbench_peripherals();
	logic clk;
	logic reset;
	logic enter;
	logic [9:0] switches, leds;
	logic [6:0] disp5, disp4, disp3, disp2, disp1;

	localparam DELAY = 10;
	
	// instantiate device to be tested
	top dut(clk, reset, enter, switches, leds, disp5, disp4, disp3, disp2, disp1);

	// initialize test
	initial
	begin
		reset <= 0; #DELAY; 
		reset <= 1; 
		
		
		switches <= 10'd4; #(DELAY*200);
		
		//enter <= 1;
		
		/*switches <= 10'b00_0001_0001; #(DELAY*200);	// 17
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_0010_0101; #(DELAY*200);	// 37
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		#(DELAY*200);					// 54
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_1011_1101; #(DELAY*200);	// -67
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_1111_0011; #(DELAY*200);	// -13
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		#(DELAY*200);					// -80
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_0110_0100; #(DELAY*200);	// 100
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_1100_1110; #(DELAY*200);	// -50
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		#(DELAY*200);					// 50
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_1010_1010; #(DELAY*200);	// -86
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		switches <= 10'b00_0001_0000; #(DELAY*200);	// 16
		enter <= 0; #(DELAY*10);
		enter <= 1; #(DELAY*10);
		
		#(DELAY*200);					// -70*/
		
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule