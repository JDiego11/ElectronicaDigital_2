/*
 * This module is the Datapath Unit of the ARM single-cycle processor
 */ 
module datapath(input logic clk, reset,
					 input logic [1:0] RegSrc,
					 input logic RegWrite,
					 input logic [1:0] ImmSrc,
					 input logic ALUSrc,
					 input logic [2:0] ALUControl,			//Cambio 1 a 2 para la ALU
					 input logic MemtoReg,
					 input logic PCSrc,
					 output logic [3:0] ALUFlags,
					 output logic [31:0] PC,
					 input logic [31:0] Instr,
					 output logic [31:0] ALUResult_Final, WriteData,		//ALUResult_Final es lo que sale de la ALU cuando se hace el desplazamiento
					 input logic [31:0] ReadData,
					 input logic Shift);							//LSL, LSR, ASR, ROR, MOV
	// Internal signals
	logic [31:0] PCNext, PCPlus4, PCPlus8;
	logic [31:0] ExtImm, SrcA, SrcB, Result;
	logic [3:0] RA1, RA2;
	logic [31:0] Shift_B, ALUResult;		//Para los desplazamientos 
	
	
	// next PC logic
	mux2 #(32) pcmux(PCPlus4, Result, PCSrc, PCNext);
	flopr #(32) pcreg(clk, reset, PCNext, PC);
	adder #(32) pcadd1(PC, 32'b100, PCPlus4);
	adder #(32) pcadd2(PCPlus4, 32'b100, PCPlus8);

	// register file logic
	mux2 #(4) ra1mux(Instr[19:16], 4'b1111, RegSrc[0], RA1);
	mux2 #(4) ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);
	regfile rf(clk, RegWrite, RA1, RA2, Instr[15:12], Result, PCPlus8, SrcA, WriteData);
	mux2 #(32) resmux(ALUResult_Final, ReadData, MemtoReg, Result);		//Salida final
	extend ext(Instr[23:0], ImmSrc, ExtImm);

	// ALU logic
		//Agregamos el shifter
	shifter shift1(WriteData, Instr[11:7], Instr[6:5], Shift_B);	//LSL, LSR, ASR, ROR, MOV
	mux2 #(32) srcbmux(Shift_B, ExtImm, ALUSrc, SrcB);				//Cambiamos WriteData con B desplazado ya que vamos a trabajar con el desplazamiento
	alu #(32) alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);
	mux2 #(32) mux_aluresult(ALUResult, SrcB, Shift, ALUResult_Final);	//Si hubo desplazamiento el resultado final de la ALU será la
																								//operación con shift, sino, sera la operación sin Shift
endmodule