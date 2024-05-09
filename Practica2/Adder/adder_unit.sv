/*******************
 Adder Unit Module
*******************/

module adder_unit (dataA, dataB, dataR);
	input logic [31:0] dataA, dataB;			// Entradas operadores A y B
	output logic [31:0] dataR;					// Salida resultado R
	
	//Señales internas
	logic Sign_R, Min;
	logic [5:0] cont;
	logic [7:0] Exp_A, Exp_B, Exp_R, AminusB, BminusA, Aux_ER, Disp;
	logic [22:0] Fracc_R;
	logic [23:0] Mant_A, Mant_B, Mant_Shift;
	logic [24:0] Aux_R;
	logic [25:0] New_MA, New_MB, AuxAdd_R;
	
	assign {Exp_A, Mant_A} = {dataA[30:23], 1'b1, dataA[22:0]};		//Separamos el exponente y la fraccion de A y concatenamos un bit en '1' para formar su mantisa
	assign {Exp_B, Mant_B} = {dataB[30:23], 1'b1, dataB[22:0]};		//Separamos el exponente y la fraccion de B y concatenamos un bit en '1' para formar su mantisa
		
	/****************************************************
	 Restamos los exponentes para ver que mantisa correr
	****************************************************/
	assign AminusB = Exp_A - Exp_B;			//restamos los Exponentes de A y B
	assign BminusA = Exp_B - Exp_A;			//Sin importar cual es el menor
	assign Min = AminusB[7];					//A partir del resltado entre Exp_A - Exp_B sabremos sabremos cual es el exponente mayor
	
	always_comb begin
		if (Min) begin						//Si B es mayor que A
			Aux_ER = Exp_B;				//El exponente auxiliar es el exponente de B (el mayor)
			Disp = BminusA;				//El numero para correr la mantisa es Exp_B - Exp_A
		end
		else begin							//Si A es mayor que B
			Aux_ER = Exp_A;				//El exponente auxiliar es el exponente de A (el mayor)
			Disp = AminusB;				//El numero para correr la mantisa es Exp_A - Exp_B
		end
	end
	
	/**************************************
	 Hacemos el corrimiento de la mantissa
	**************************************/
	always_comb begin
		if (Min) begin
			Mant_Shift = Mant_A >> Disp;		//Si A es el menor, corremos su mantisa Exp_B - Exp_A bits
		end
		else begin
			Mant_Shift = Mant_B >> Disp;		//Si B es el menor, corremos su mantisa Exp_A - Exp_B bits
		end
	end
	
	/******************************************************************
	 Analisamos que pasa si tienes signos contrarios o signos iguales
	******************************************************************/
	always_comb begin
	New_MA = {2'b00, Mant_A};		//Casos default antes de ajustar mantisas
	New_MB = {2'b00, Mant_B};
		if (dataA[31] != dataB[31])		//Si los numeros tienen signos diferentes
			if (Min) begin
				if (dataA[31]) begin					//Si A es el menor y el negativo
					New_MA = ~({2'b00, Mant_Shift}) + 1'b1;		//Complemento a 2 a la mantisa desplazada de A
					New_MB = {2'b00, Mant_B};							//Mantisa default de B
				end
				else begin								//Si A es el menor y B es el negativo
					New_MA = {2'b00, Mant_Shift};						//Mantisa deslpazada de A
					New_MB = ~({2'b00, Mant_B}) + 1'b1;				//Complemento a 2 a la mantisa Default de B
				end
			end
			else begin
				if (dataA[31]) begin					//Si B es el menor y A es el negativo
					New_MA = ~({2'b00, Mant_A}) + 1'b1;				//Complemento a 2 a la mantisa default de A
					New_MB = {2'b00, Mant_Shift};						//Mantisa desplazada de B
				end
				else begin								//Si B es el menor y el negativo
					New_MA = {2'b00, Mant_A};							//Mantisa default de A
					New_MB = ~({2'b00, Mant_Shift}) + 1'b1;		//Complemento a 2 a la mantisa desplazada de B
				end
			end
		else									//Si los numeros tienen signos iguales
			if (Min) begin							//Preguntamos quien es el numero menor
				New_MA = {2'b00, Mant_Shift};		//la mantisa de B para operar es la Default y la de A es la que tiene el corrimiento
			end
			else begin
				New_MB = {2'b00, Mant_Shift};		//la mantisa de A para operar es la Default y la de B es la que tiene el corrimiento
			end
	end
	
	/**********************
	 Se suman las mantisas
	**********************/
	always_comb begin
	AuxAdd_R = New_MA + New_MB;		//Sumamos las mantisas de A y B con las posibles modificaciones
	Sign_R = AuxAdd_R[25];				//El bit de signo de la suma define el signo del resultado
		if (AuxAdd_R[25])					//Si el bit de signo en el resultado es 1
			Aux_R = ~(AuxAdd_R[24:0]) + 1'b1;		//Complemento a 2 porque el resultado es negativo
		else									//Si el bit de signo en el resultado es 0
			Aux_R = AuxAdd_R[24:0];						//Se deja igual porque el resultado es positivo
	end
	
	/***********************************
	 Para recorrer y buscar el primer 1
	***********************************/
	always_comb begin
		cont = 6'b0;				//Inicializar el contador en 0
		for (logic [5:0] c_aux = 0; c_aux <= 24; c_aux++) begin
			if (Aux_R[6'd24 - c_aux])		//Al encontrar el primer 1, romper el ciclo
				break;
			else
				cont = c_aux;					//Mientas busca el primer 1 aumenta el contador
		end
	end
	
	/********************************
	 Ajustar exponente del resultado
	********************************/
	always_comb begin
		if (Aux_R[24])				//Si el bit de Carry en el resultado de la suma es 1
			Exp_R = Aux_ER + 1'b1;				//Ajustamos el exponente sumando 1
		else							//Si no hay carry en la suma
			Exp_R = Aux_ER - {2'b00, cont};	//Se resta al exponente la cantidad de 0 antes del primer 1 encontrado
	end
	
	/******************************
	 Ajustar mantisa del resultado
	******************************/
	always_comb begin
		if (Aux_R[24])			//Si hay Carry en el resultado de la suma
			Fracc_R = Aux_R[23:1];		//Se toma como fraccion desde el bit 23 hasta el 1 del resultado
		else						//Si no hay Carry
			Fracc_R = Aux_R << cont;	//Se deslpaza hacia la izquierda la cantidad de 0 encontrados antes del primer 1
	end
	/*****************
	 Casos Especiales
	*****************/
	always_comb begin
		if ((&Exp_A == 1'b1 && |dataA[22:0] == 1'b1) || (&Exp_B == 1'b1 && |dataB[22:0] == 1'b1))
			dataR = 32'hFFFF_FFFF;					//Si A o B es NaN, resultado es NaN
		else if (dataA[31:0] == 32'h7F80_0000 || dataB[31:0] == 32'h7F80_0000)
			if (dataA[31:0] == 32'hFF80_0000 || dataB[31:0] == 32'hFF80_0000)
				dataR = 32'hFFFF_FFFF;				//Si alguno es Infinito pero el otro es -Infinito el resultado es NaN
			else
				dataR = 32'h7F80_0000;				//Si alguno es Infinito pero el otro es diferente a -Infinito o NaN, el resultado es Infinito
		else if (dataA[31:0] == 32'hFF80_0000 || dataB[31:0] == 32'hFF80_0000)
			if (dataA[31:0] == 32'h7F80_0000 || dataB[31:0] == 32'h7F80_0000)
				dataR = 32'hFFFF_FFFF;				//Si alguno es -Infinito pero el otro es Infinito el resultado es NaN
			else
				dataR = 32'hFF80_0000;				//Si alguno es -Infinito pero el otro es diferente a Infinito o NaN, el resultado es -Infinito
		else if (dataA[30:0] == dataB[30:0] && dataA[31] != dataB[31])
			dataR = 32'h0000_0000;					//Si A y B son iguales pero con diferente signo, el resultado es 0
		else if (|dataA[30:0] == 1'b0 || |dataB[30:0] == 1'b0)
			dataR = |dataA[30:0] ? dataA : dataB;		//Si alguno es 0 y el otro es numero
//		else if (&dataA[30:24] == 1'b1 || &dataB[30:24] == 1'b1 )
//			if (dataA[31] == 1'b1 && dataB[31] == 1'b1)
//				dataR = 32'hFF80_0000;
//			else if (!dataA[31] && !dataB[31])
//				dataR = 32'h7F80_0000;
		else 
			dataR = {Sign_R, Exp_R, Fracc_R};
	end
	
	//assign dataR = {Sign_R, Exp_R, Fracc_R};
	
endmodule

/**********
 TestBench
**********/
module tb_adder();
	logic [31:0] dataA, dataB, dataR;
	
	localparam delay = 20ps;
	
	adder_unit a1 (dataA, dataB, dataR);
	
	initial begin
	
	dataA = 32'hCF164B5D;
	dataB = 32'h4F164B38;
	#(delay);
	
	dataB = 32'hCF164B5D;
	dataA = 32'h4F164B38;
	#(delay);
	
	dataA = 32'h7F7F_FFFF;
	dataB = 32'h7F7F_FFFF;
	#(delay);
	
	dataA = 32'hFF7F_FFFF;
	dataB = 32'hFF7F_FFFF;
	#(delay);
	
	dataA = 32'hC0CB0000;
	dataB = 32'h00000000;
	#(delay);
	
	dataA = 32'h00000000;
	dataB = 32'hC0CB0000;
	#(delay);
	
	dataA = 32'hC0CB0000;
	dataB = 32'h80000000;
	#(delay);
	
	dataB = 32'hC0CB0000;
	dataA = 32'h80000000;
	#(delay);
	
	dataA = 32'h00000000;
	dataB = 32'hC0CB0000;
	#(delay);
	
	dataA = 32'hC0CB0000;
	dataB = 32'hC0C70000;
	#(delay);
	
	dataA = 32'h3F800000;
	dataB = 32'h41000000;
	#(delay);
	
	dataA = 32'hc0b00000;
	dataB = 32'h40100000;
	#(delay);
	
	//pos + pos
		dataA = 32'h40FC0000;	//
		dataB = 32'h3E400000;
		#(delay);
	
	//pos + pos
		dataA = 32'h40840000;
		dataB = 32'h3E400000;
		#(delay);
	
	//neg + neg
		dataA = 32'hC0FC0000;
		dataB = 32'hBE400000;
		#(delay);
		
	//pos + neg
		dataA = 32'h40FC0000;
		dataB = 32'hBE400000;
		#(delay);
		
	//neg + pos
		dataA = 32'hC0FC0000;
		dataB = 32'h3E400000;
		#(delay);
		
/*****************
 CASOS ESPECIALES
*****************/
	/*//NaN + X = NaN
		dataA = 32'hFFFFFFFF;
		dataB = 32'h40FC0000;
		#(delay);
		
		dataA = 32'h7F800000;
		dataB = 32'hFFFFFFFF;
		#(delay);
		
	//Inf + X = Inf
		dataA = 32'h7F800000;
		dataB = 32'h7F800000;
		#(delay);
		
	//-Inf + X = -Inf
		dataA = 32'hFF800000;
		dataB = 32'hFF800000;
		#(delay);
		
	//Inf + (-Inf) = NaN
		dataA = 32'h7F800000;
		dataB = 32'hFF800000;
		#(delay);
		
	//pos + neg (numB = -NumA)
		dataA = 32'h40FC0000;
		dataB = 32'hC0FC0000;
		#(delay);*/
		
		$stop;
	end
endmodule 