module displays(
	input logic [7:0] Num,
	input logic [3:0] Letter,
	output logic [6:0] Disp5, Disp4, Disp3, Disp2, Disp1);
	
	logic [19:0] ValuestoShow;			//	Almacena toda la informacion a mostrar en los 7-Segmentos
	logic [7:0] number, auxDiv;		// Auxiliares
	logic [3:0] Sign, Hundreds, Tens, Units;		// Separar signo, centenas, decenas y unidades
	logic [4:0] Enable_Hexa;			//Enable para controlar que 7-Segmentos encender
	logic En_Sign, En_Hun, En_Ten;		// Enable para activar Hexa_Sign, Hexa_Hun y Hexa_Ten
	
	always_comb begin					// Verificar Signo
		if(Num[7] == 1'b1) begin
			Sign = 4'b1111;		// Hexa_Sign -> "-"
			number = (~Num + 1'b1);		// Complemento a2 si Num es negativo
			En_Sign = 1'b1;			// Encender Hexa_Sign
		end
		else begin
			Sign = 4'b1101;		// Default, Hexa_Sign -> "Off"
			number = Num;			// Num por defecto
			En_Sign = 1'b0;		// No encender Hexa_Sign
		end
	end
	
	/*
	 * Binario a Decenas, Centenas y Unidades
	 */
	assign Hundreds	= (number / 7'd100);		// CDU /	100	= C	-> Centenas
	assign auxDiv		= (number % 7'd100);		// CDU %	100	= DU	-> aux
	assign Tens			= (auxDiv / 7'd10);		// DU  /	10		= D	-> Decenas
	assign Units		= (auxDiv % 7'd10);		// DU  %	10		= U	-> Unidades
	
	/*
	 * Organizar los 7-Segmentos
	 */
	always_comb begin				// Acomodar signo y Hexa segun se requiera
		En_Hun = 1'b1;				// Activar por defecto
		En_Ten = 1'b1;				// Hexa_Hun y Hexa_Ten
		if(Hundreds == 7'b0) begin
			if (Tens == 7'b0) begin
				ValuestoShow = {Letter, Hundreds, Tens, Sign, Units};		// Solo mostrar Letra, Signo (si lo requiere) y Unidades
				En_Hun = 1'b0;			// Desactivar Hexa_Hun
				En_Ten = 1'b0;			// Desactivar Hexa_Ten
				Enable_Hexa = {1'b1, En_Hun, En_Ten, En_Sign, 1'b1};
			end
			else begin
				ValuestoShow = {Letter, Hundreds, Sign, Tens, Units};		// Solo mostrar Letra, Signo (si lo requiere), Decenas y Unidades
				En_Hun = 1'b0;			// Desactivar Hexa_Hun
				Enable_Hexa = {1'b1, En_Hun, En_Sign, En_Ten, 1'b1};
			end
		end
		else begin
			ValuestoShow = {Letter, Sign, Hundreds, Tens, Units};			// Mostrar Letra, Signo (si lo requiere), Centenas, Decenas y Unidades
			Enable_Hexa = {1'b1, En_Sign, En_Hun, En_Ten, 1'b1};
		end
	end
	
	/*
	 * Instanciar modulos 7-Segmentos
	 */
	deco7seg dp5(ValuestoShow[19:16],	Enable_Hexa[4],	Disp5);
	deco7seg dp4(ValuestoShow[15:12],	Enable_Hexa[3],	Disp4);
	deco7seg dp3(ValuestoShow[11:8],		Enable_Hexa[2],	Disp3);
	deco7seg dp2(ValuestoShow[7:4],		Enable_Hexa[1],	Disp2);
	deco7seg dp1(ValuestoShow[3:0],		Enable_Hexa[0],	Disp1);
	
endmodule 