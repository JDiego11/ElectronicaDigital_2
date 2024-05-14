.global _start
_start:
	
	LDR		R0, =AddLEDs
	LDR		R1, [R0]		// Guardamos la ubicación de los switches
	MOV		R10, #10		// Inicializamos R10 como A, el primer valor a ingresar
	
main:						// Programa principal
	LDR		R2, [R1, #64]			// Leemos los switches
	LSL		R2, R2, #24
	ASR		R2, R2, #24			// Desplazamiento para acomodar el signo
	
	STR		R2, [R1]				// Escribimos el numero A o B en los LEDs -> (Binary)
	//STR		R2, [R1, #8]		// Escribimos el numero A o B en los 4 LSB 7-Segmentos -> (Signed)
	//STR		R10, [R1, #12]		// Escribmos A o B en el MSB 7-Segmento
	
	LDR		R3, [R1, #80]		// Leemos el pulsador "Enter"
	CMP		R3, #1
	BNE		main				// Si no hay señal de enter siga leyendo los switches
	
ReleaseButton1:					// Al haber presionado el boton
	LDR		R3, [R1, #80]		// Leemos el nuevo estado del pulsador "Enter"
	CMP		R3, #0
	BNE		ReleaseButton1		// Si no lo ha soltado se quede ahí hasta que lo suelte

	CMP		R10, #10		// Si R10 = 10 Ingresa A
	BEQ		ReadA
	
	CMP		R10, #11		// Si R10 = 11 Ingresa B
	BEQ		ReadB
	
	CMP		R10, #12		// Si R10 = 12 Se muestra A + B
	BEQ		ShowR

ReadA:
	MOV		R4, R2				// R4 = A
	MOV		R10, #11			// R10 = 11 para en el siguiente ciclo leer B
	B		main				// Saltamos a main para recibir B

ReadB:
	MOV		R5, R2				// R5 = B
	MOV		R10, #12			// R10 = 12 para en el siguiente ciclo mostrar R
	//B		main				// Saltamos a main para mostrar R

ShowR:
	ADD		R6, R4, R5			// R6 = A + B -> A + B = R
	STR		R6, [R1]			// Escribimos el numero R en los LEDs -> (Binary)
	//STR		R2, [R1, #8]		// Escribimos el numero R en los 4 LSB 7-Segmentos -> (Signed)
	//STR		R10, [R1, #12]		// Escribmos R en el MSB 7-Segmento
	
	LDR		R3, [R1, #80]		// Leemos el pulsador "Enter"
	CMP		R3, #1
	BNE		ShowR				// Si no hay señal de enter siga leyendo los switches
	
ReleaseButton2:					// Al haber presionado el boton
	LDR		R3, [R1, #80]		// Leemos el nuevo estado del pulsador "Enter"
	CMP		R3, #0
	BNE		ReleaseButton2		// Si no lo ha soltado se quede ahí hasta que lo suelte

	MOV		R10, #10			// R10 = 10 para en el siguiente ciclo leer A
	B		main				// Saltamos a main para recibir A

.data
AddLEDs:	.dc.l 0xff200000