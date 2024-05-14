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
		
		
		enter <= 0; #DELAY;
		
		switches <= 10'b00_1000_0001; #(DELAY*2000);
		
		
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule