module shifter	(input logic [31:0] A,					//Num in
					 input logic [4:0] shamt,				//Desplazamiento
					 input logic [1:0] sh_type,			//LSL, LSR, ASR, ROR
					 output logic [31:0] shamt_out);		//Salida
					 
	logic [31:0] logical_Shift, sign_fill;
	assign logical_Shift = A >> shamt;
	assign sign_fill = {32{1'b1}} << {32 - shamt};
	
	always_comb
		case(sh_type)
			2'b00: shamt_out = A << shamt;		//LSL
			2'b01: shamt_out = A >> shamt;		//LSR
			2'b10: begin								//ASR
				if (A[31] == 1'b1) begin
					shamt_out = logical_Shift | sign_fill;
				end else begin
					shamt_out = logical_Shift;
				end
			end
			2'b11: shamt_out = (A >> shamt) | (A << (32 - shamt));		//ROR
		endcase

endmodule