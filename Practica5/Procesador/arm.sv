/*
 * This module is the ARM single-cycle processor, 
 * which instantiates the Control and Datapath units
 */ 
module arm(input logic				clk, reset,
			  output logic	[31:0] 	PC,
			  input logic	[31:0] 	Instr,
			  output logic 			MemWrite,
			  output logic [31:0] 	ALUResult, WriteData,
			  input logic 	[31:0] 	ReadData);

	// Internal signals to interconnect the control and datapath units
	logic [3:0] ALUFlags;
	logic RegWrite, ALUSrc, MemtoReg, PCSrc;
	logic [1:0] RegSrc, ImmSrc;
	logic [2:0] ALUControl;		//Cambio
	logic Shift;		//Desplazamiento para LSL, LSR, ASR, ROR, MOV

	// Control unit instantiation
	controller c(clk, reset, Instr[31:12], ALUFlags,
						RegSrc, RegWrite, ImmSrc,
						ALUSrc, ALUControl,
						MemWrite, MemtoReg, PCSrc,
						Shift);		//LSL, LSR, ASR, ROR, MOV
						
	// Datapath unit instantiation
	datapath dp(clk, reset,
						RegSrc, RegWrite, ImmSrc,
						ALUSrc, ALUControl,
						MemtoReg, PCSrc,
						ALUFlags, PC, Instr,
						ALUResult, WriteData, ReadData,
						Shift);		//LSL, LSR, ASR, ROR, MOV
endmodule
