/* **************************************
	Módulo controlador de tráfico de luces 
	************************************** */
module trafficlight #(FPGAFREQ = 50_000_000, 
   T_GREENMAIN = 18, T_YELLOWMAIN = 4, T_GREENSEC = 10, T_YELLOWSEC = 3, T_GREENPEAT = 5, T_RED = 2, T_RESET = 3)
   (clk, nreset, nPeatonalBtn, main_lights, sec_lights, peat_lights, led_peatonal, HexaTens, HexaUnits);

	/* Entradas y salidas */
	input logic clk, nreset, nPeatonalBtn;
	output logic [2:0] main_lights;	// rojo, amarillo, verde -> Semaforo Principal
	output logic [2:0] sec_lights;	// rojo, amarillo, verde -> Semaforo Secundario
	output logic [1:0] peat_lights;	// rojo, --------- verde -> Semaforo Peatonal
	output logic led_peatonal;			// Led esperando semaforo peatonal
	output logic [7:0] HexaTens;
	output logic [7:0] HexaUnits;		//Salidas 7-Segmentos

	/* Circuito para invertir señal de reloj */
	logic reset, PeatonalBtn;
	assign reset = ~nreset;
	assign PeatonalBtn = ~nPeatonalBtn;
	
	/* Señales internas para contar segundos a partir del reloj de la FPGA */
	localparam FREQDIVCNTBITS = $clog2(FPGAFREQ);	// Bits para contador divisor de frecuencia
	logic [FREQDIVCNTBITS-1:0] cnt_divFreq;	// Contador para generar un (1) segundo 
	localparam SECCNTBITS = $clog2(T_GREENMAIN);		// Bits para el contador de segundos
	logic [SECCNTBITS-1:0] cnt_secLeft;			// Contador de segundos restantes
	logic cnt_timeIsUp;								// Tiempo completado en estado actual
	logic [3:0] Units, Tens; 					//Unidades y decenas, serviran para escribir el numero en el 7-segmentos
	
	/* Division de segundos para mostrarlos en el 7-Segmentos */
	logic [7:0] iTens, iUnits;
	assign Tens  = ((cnt_secLeft + 1'b1) % 4'b1010);
	assign Units = ((cnt_secLeft + 1'b1) / 4'b1010);
	always_comb begin
		if (Units == 4'b0000)
			HexaUnits = 8'b11111111;
		else
			HexaUnits = ~iUnits;
	end
	
	/*instanciar modulo 7-Segmentos */
	deco7seg_hexa SegTens (Tens, iTens);
	deco7seg_hexa SegUnits (Units, iUnits);
	assign HexaTens = ~iTens;
	//assign HexaUnits = ~iUnits;
	
	/* Definición de estados de la FSM y señales internas para estado actual y siguiente */
	typedef enum logic [2:0] {Srst, Smg, Smy, Ssg, Ssy, Spg, Sar} State;
	State currentState, nextState;
	
	/* *********************************************************************************************
		Circuito secuencial para actualizar estado actual con el estado siguiente. 
		Se emplea señal de reloj de 50 Mhz.  
		********************************************************************************************* */
	always_ff @(posedge clk, posedge reset) 
		if (reset)
			currentState <= Srst;
		else 
			currentState <= nextState;	
	
	/*******************************************
		Registro para el boton de paso peatonal
	********************************************/
	always_ff @(posedge clk, posedge reset)
		if (reset)
			led_peatonal <= 1'b0;
		/*else if (PeatonalBtn)
			if (currentState != Ssy)
				led_peatonal <= 1'b1;
			else
				led_peatonal <= 1'b0;*/
		else if (currentState == Spg)
			//if (PeatonalBtn)
				led_peatonal = 1'b0;
		else
			if (PeatonalBtn)
				led_peatonal = 1'b1;
	
	/* *********************************************************************************************
		Circuito combinacional para determinar siguiente estado de la FSM 
		********************************************************************************************* */
	always_comb begin
		if(cnt_timeIsUp)
			case (currentState)
				Srst:
					nextState = Smg;
				Smg:	
					nextState = Smy;
				Smy:	
					nextState = Ssg;
				Ssg:	
					nextState = Ssy;
				Ssy:									//Preguntar si hay señal de paso de peatones
					if (led_peatonal)
						nextState = Spg;
					else
						nextState = Smg;
				Spg:
					nextState = Sar;
				Sar:
					nextState = Smg;
				default:		
					nextState = Smg;
			endcase
		else	
			nextState = currentState;
	end
	
	/* *********************************************************************************************
		Circuito combinacional para manejar las salidas
		********************************************************************************************* */
	always_comb begin
		main_lights = 3'b100;			// Para simplificar cada case - Principal
		sec_lights = 3'b100;				// Para simplificar cada case - Secundario
		peat_lights = 2'b10;				// Para simplificar cada case	- Peatonal
		case (currentState)
			Smg: 
				main_lights = 3'b001;
			Smy:  
				main_lights = 3'b010;
			Ssg: 
				sec_lights = 3'b001;
			Ssy:  
				sec_lights = 3'b010;
			Spg:
				peat_lights = 2'b01;
		endcase
	end	

	/* *********************************************************************************************
		Circuito secuencial para el contador de segundos y la visualización en displays
		********************************************************************************************* */
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			cnt_divFreq <= 0;
			cnt_secLeft <= SECCNTBITS'(T_RESET-1);	// Casting
			cnt_timeIsUp <= 0;
		end else begin
			cnt_divFreq <= cnt_divFreq + 1'b1;
			cnt_timeIsUp <= 0;

			if (cnt_divFreq == FPGAFREQ-1) begin // ¿Un segundo completado?
				cnt_divFreq <= 0;
				cnt_secLeft <= cnt_secLeft - 1'b1;

				// Determinar si se completaron los segundos del estado correspondiente
				if(cnt_secLeft == 0) begin // Contador == 0 y pasará en este ciclo a modCnt-1
					cnt_timeIsUp <= 1;
					case (currentState)
						Srst:
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);			// Casting
						Smg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWMAIN-1);	// Casting
						Smy:
							cnt_secLeft <= SECCNTBITS'(T_GREENSEC-1);		// Casting
						Ssg:
							cnt_secLeft <= SECCNTBITS'(T_YELLOWSEC-1);	// Casting
						Ssy:
							if (led_peatonal)
								cnt_secLeft <= SECCNTBITS'(T_GREENPEAT-1);	// Casting
							else
								cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);	// Casting
						Spg:
							cnt_secLeft <= SECCNTBITS'(T_RED-1);	// Casting
						Sar:
							cnt_secLeft <= SECCNTBITS'(T_GREENMAIN-1);			// Casting
					endcase
				end
			end
		end	
	end
endmodule

/* ****************
	Módulo testbench 
	**************** */
module testbench();
	/* Declaración de señales y variables internas */
	logic clk, reset, led_peatonal, nPeatonalBtn;
	logic [2:0] main_lights, sec_lights;
	logic [1:0] peat_lights;

	localparam FPGAFREQ = 8;
	localparam T_GREENMAIN = 8;
	localparam T_YELLOWMAIN = 3;
	localparam T_GREENSEC = 6;
	localparam T_YELLOWSEC = 2;
	localparam T_GREENPEAT = 3;
	localparam T_RED = 2;
	localparam T_RESET = 3;
	localparam delay = 20ps;
	
	// Instanciar objeto
	trafficlight #(FPGAFREQ, T_GREENMAIN, T_YELLOWMAIN, T_GREENSEC, T_YELLOWSEC, T_GREENPEAT, T_RED, T_RESET) tl 
	              (clk, ~reset, ~nPeatonalBtn, main_lights, sec_lights, peat_lights, led_peatonal);
	// Simulación
	initial begin
		clk = 0;
		reset = 1;
		nPeatonalBtn = 0;
		#(delay*(T_RESET)*FPGAFREQ*2);
		
		reset = 0;
		nPeatonalBtn = 0;
		#(delay*(T_GREENMAIN+T_YELLOWMAIN+T_GREENSEC+T_YELLOWSEC)*FPGAFREQ*2);
		
		reset = 1;
		#delay;
		reset = 0;
		#delay;
		nPeatonalBtn = 1;
		#delay;
		nPeatonalBtn = 0;
		#(delay*(T_GREENMAIN+T_YELLOWMAIN+T_GREENSEC+T_YELLOWSEC+T_GREENPEAT+T_RED)*FPGAFREQ*2);

		$stop;
	end
	
	// Proceso para generar el reloj
	always #(delay/2) clk = ~clk;
endmodule