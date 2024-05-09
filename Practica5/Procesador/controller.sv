/*
 * This module is the Control Unit of ARM single-cycle processor
 */ 
module controller(input logic clk, reset,
						input logic [31:12] Instr,
						input logic [3:0] ALUFlags,
						output logic [1:0] RegSrc,
						output logic RegWrite,
						output logic [1:0] ImmSrc,
						output logic ALUSrc,
						output logic [2:0] ALUControl,		//Cambio
						output logic MemWrite, MemtoReg,
						output logic PCSrc,
						output logic Shift);		//LSL, LSR, ASR, ROR, MOV
	logic [1:0] FlagW;
	logic PCS, RegW, MemW;
	logic NoWrite;		//CMP

	decoder dec(Instr[27:26], Instr[25:20], Instr[15:12],
					FlagW, PCS, RegW, MemW,
					MemtoReg, ALUSrc, ImmSrc, RegSrc, ALUControl,
					NoWrite,		//CMP
					Shift);		//LSL, LSR, ASR, ROR, MOV

	condlogic cl(clk, reset, Instr[31:28], ALUFlags,
					FlagW, PCS, RegW, MemW,
					PCSrc, RegWrite, MemWrite,
					NoWrite);		//CMP 

endmodule
