/*
 * This module is the TOP of the ARM single-cycle processor
 */ 
module top(input logic clk, nreset, nEnter,
			  input logic [9:0] switches,			// Solo se usan 8 de los 10 suiches
			  output logic [9:0] leds,
			  output logic [6:0] disp5, disp4, disp3, disp2, disp1);

	// Internal signals
	logic reset, Enter;
	assign reset = ~nreset;
	assign Enter = ~nEnter;
	logic [31:0] PC, Instr, ReadData;
	logic [31:0] WriteData, DataAdr;
	logic MemWrite;
	
	// Instantiate instruction memory
	imem imem(PC, Instr);

	// Instantiate data memory (RAM + peripherals)
	dmem dmem(clk, MemWrite, Enter, DataAdr, WriteData, ReadData, switches, leds, disp5, disp4, disp3, disp2, disp1);

	// Instantiate processor
	arm arm(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
endmodule