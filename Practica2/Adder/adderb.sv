module adderb (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;
	output logic [31:0] dataR;
	
	/*****************
	  Señales logicas
	*****************/
	logic [7:0] Exp_A, Exp_B, Exp_R, aux1, aux2, dataA_M_dataB, dataB_M_dataA;
	logic Bigger;
	logic [23:0] Mant_A, Mant_B, Aux_Mant;
	logic [22:0] Fracc_R;
	
	assign {Exp_A, mant_A} = {dataA[30:23], 1'b1, dataA[22:0]};		//Separamos Exponente y concatenamos 1 a la fraccion de dataA
	assign {Exp_B, mant_B} = {dataB[30:23], 1'b1, dataB[22:0]};		//Separamos Exponente y concatenamos 1 a la fraccion de dataB
	assign dataR = {1'b0, Exp_R, Fracc_R};									//Unimos los componentes para el Resultado
	
	/************************************
				Para los Exponentes
	************************************/
	assign dataA_M_dataB = Exp_A - Exp_B;		//Resta los exponentes para ver
	assign dataB_M_dataA = Exp_B - Exp_A;		//quien es el mayor
	assign Bigger = dataA_M_dataB[7];			//1 en caso que B sea mayor, 0 en caso que A sea mayor

	always_comb
		if (Bigger) begin
			Exp_R = Exp_B;
			aux1 = dataB_M_dataA;
		end else begin
			Exp_R = Exp_A;
			aux1 = dataA_M_dataB;
		end
	
endmodule 