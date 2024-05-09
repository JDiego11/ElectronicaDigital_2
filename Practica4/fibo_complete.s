.global _start
	.equ	MAXN,	50
	.equ	SIZE,	90
_start:
	//Verificacion limite de datos correcto
	//Comparar 10 <= N <= 50
	LDR		R0,	=N
	LDR		R0,	[R0]
	CMP		R0,	#10			//Si N < 10 Abort
	BLT		Leave
	CMP		R0,	#50			//Si N > 50 Abort
	BGT		Leave
	
	//Comparar ORDER = 0, ORDER = 1
	LDR		R0,	=ORDER
	LDR		R0,	[R0]
	CMP		R0,	#0			//Si N < 0 Abort
	BLT		Leave
	CMP		R0,	#1			//Si N > 1 Abort
	BGT		Leave
	
	//Verificar que Los valores en POS estén entre 1 y 90
	LDR		R0, =POS
	LDR		R2,	=N
	LDR		R2,	[R2]

LoopVer:
	LDR		R1,	[R0],	#4
	CMP		R1,	#1			//Si POS[i] < 1 Abort
	BLT		Leave
	CMP		R1,	#90			//Si POS[i] > 90 Abort
	BGT		Leave
	
	SUBS	R2,	R2,	#1
	BNE		LoopVer
	
//Si todo es correcto, empezar
	B		Begin
	
//Abortar
Leave:
	LDR		R0,	=SortedValues			//Guardamos la direcciónn de SortedValues
	LDR		R1,	=0xA5A5A5A5				//Escribimos en R1 el mensaje de "error"
	STR		R1, [R0]					//Escribimos el "error" en SortedValues
	B		_finish						//Saltamos al final para evitar ejecutar eñ codigo

Begin:
//Organizar
	LDR		R0,	=N
	LDR		R0,	[R0]				//Traemos el valor de N a R0
	LDR		R1,	=POS				//Dirección de POS
	LDR		R2,	=ORDER
	LDR		R2,	[R2]				//Valor de Order en R2
	BL		Sort					//Saltamos a Sort para organizar POS

//Generar serie
	LDR		R0,	=SERIE				//Dirección de SERIE
	MOV		R1,	#SIZE				//R1 toma el tamaño maximo de la SERIE
	BL		Fibo

//Sacar los valores requeridos
	LDR		R0,	=SERIE				//Dirección de ORDER
	LDR		R1, =N
	LDR		R1, [R1]				//R1 como N
	LDR		R2,	=POS				//Dirección de POS
	LDR		R3,	=SortedValues		//Dirección de SortedValues
	BL		GetValues

_finish:
	B	_finish
	
Fibo:
	MOV		R3,	#0
	MOV		R2,	#0
	//Hacemos 0:0 para el primer númro de la serie
	STR		R3,	[R0],	#4
	STR		R2,	[R0],	#4
	MOV		R3,	#1
	MOV		R2,	#0
	//Hacemos 1:0 para el segundo numero de la serie
	STR		R3,	[R0],	#4
	STR		R2,	[R0],	#4
	
	SUB		R1,	R1,	#2

LoopFibo:
	SUB		SP,	SP,	#12				//Reservar tres espacios en la pila para R0, R1 y LR
	STR		R0,	[SP, #8]			//Guardamos R0
	STR		R1,	[SP, #4]			//Guardamos R1
	STR		LR,	[SP]				//Guardamos LR
	
	//Traemos B
	LDR		R3, [R0, #-4]
	LDR		R2,	[R0, #-8]
	//Traemos A
	LDR		R1, [R0, #-12]
	LDR		R0,	[R0, #-16]
	
	BL		Add64
	
	MOV		R3, R1					//Copiamos el resultado de la suma (R1:R0) en R3:R2
	MOV		R2,	R0					//Para poder restaurar la posición y el tamaño sin perder el resultado (R1:R0)
	
	LDR		LR,	[SP]				//Restauramos LR
	LDR		R1,	[SP, #4]			//Restauramos R1
	LDR		R0,	[SP, #8]			//Restauramos R0
	ADD		SP,	SP,	#12				//Liberamos el stack
	
	STR		R2,	[R0],	#4			//Escribimos el nuevo numero en memoria
	STR		R3,	[R0],	#4
	
	SUBS	R1, R1,	#1				//Restamos el tamaño para ver cuantos ciclos quedan por hacer
	BNE		LoopFibo				//Si se hicieron los 90 sale del ciclo y avanza en el codigo principal

EndLoop:
	MOV		PC,	LR

//Sumar
Add64:
	ADDS	R0,	R2,	R0				//Sumamos R2 y R0 (LSB de B y A respectivamente) y si hay carry actualizamos la Flag de carry
	ADC		R1,	R3,	R1				//Sumamos R3 y R1 (MSB de B y A respectivamente) y si la Flag de carry está activa suma ese carry
	MOV		PC,	LR					//Retornamos

Sort:
	//Reservamos 6 espacios en la pila y guardamos de R4 a R9
	SUB		SP,	SP,	#24
	STR		R4,	[SP, #20]
	STR		R5,	[SP, #16]
	STR		R6,	[SP, #12]
	STR		R7,	[SP, #8]
	STR		R8,	[SP, #4]
	STR		R9,	[SP]
	
	MOV		R3,	#0					//R3 como i=0
	MOV		R12,	#4				//R12 como auxiliar para multiplicar x4
	
OuterLoop:
	
	SUB		R4,	R0,	#1				//R4 -> N-1
	CMP		R3,	R0
	BGE		EndSorter
	
	MOV		R5,	#0					//R5 como j=0
	
InnerLoop:
	SUB		R4,	R0,	#1				//R4 -> N-1 nuevamente para que en cada ciclo no se pierda el valor de N
	SUB		R4,	R4,	R3				//R5 -> N-1-i
	CMP		R5,	R4					//Si j = N-i-1
	BGE		NextOuter
	
	MUL		R6,	R5,	R12				//Multiplicamos j*4 para movernos por las posiciones para hacer POS[j]
	LDR		R7,	[R1, R6]			//Cargamos en R7 lo que hay en POS[j]
	ADD		R8,	R5,	#1				//Hacemos R8 como j+1
	MUL		R9,	R8,	R12				//Multiplicamos (j+1)*4 para hacer POS[j+1]
	LDR		R8,	[R1, R9]			//Cargamos en R8 lo que hay en POS[j+1]
	
	CMP		R2,	#1					//Comparamos el valor de ORDER con 1
	BEQ		Else					//Si ORDER es 1 va al Else y ordena descendente, si es 0 va al If y ordena ascendente
	
If:									//Ordena Ascendente
	CMP		R7, R8					//Comparamos POS[j] con POS[J+1]  //cambiar los r para cambiar el sentido.
	BLT		NotGreater				//Si POS[j] < POS[J+1] no se hace el cambio
	B		Change					//En caso de entrar al If que salte directamente al cambio para que no entre al Else
	
Else:								//Ordena Descendente
	CMP		R8, R7					//Comparamos POS[j+1] con POS[J]  //cambiar los r para cambiar el sentido.
	BLT		NotGreater				//Si POS[j+1] < POS[J] no se hace el cambio -> POS[J] > POS[J+1]
	
Change:								//Intercambiamos
	STR		R7,	[R1, R9]
	STR		R8,	[R1, R6]
	
NotGreater:
	ADD		R5,	R5,	#1				//j++
	B		InnerLoop				//Volver a hacer el ciclo interno
	
NextOuter:
	ADD		R3,	R3,	#1				//i++
	B		OuterLoop				//Volver a hacer el ciclo principal
	
EndSorter:
	//Traer de la pila de R4 a R5 y Liberar
	LDR		R9,	[SP]
	LDR		R8,	[SP, #4]
	LDR		R7,	[SP, #8]
	LDR		R6,	[SP, #12]
	LDR		R5,	[SP, #16]
	LDR		R4,	[SP, #20]
	ADD		SP,	SP,	#24
	//Retornamos
	MOV		PC,	LR

GetValues:
	//Reservamos 4 espacios en la pila y guardamos de R4 a R7
	SUB		SP,	SP,	#16
	STR		R4,	[SP, #12]
	STR		R5,	[SP, #8]
	STR		R6,	[SP, #4]
	STR		R7,	[SP]
	
	MOV		R12,	#8				//Auxiliar para la multipliación

LoopGetValues:
	LDR		R4,	[R2],	#4			//Traemos de POS el primer valor
	SUB		R5, R4, #1				//Como ese valor es una posición en la Serie y las posiciones comienzan en 0, restamos 1
	
	MUL		R5, R5, R12				//Multiplicacmos esa posición por 8 para saber qué numero en Serie es el de la posición n en POS
	LDR		R6, [R0, R5]			//Traemos el valor de esa posición de SERIE
	STR		R6, [R3],	#4			//Escribimos en SortedValues y avanzamos a la siguiente posición
	
	ADD		R5, R5, #4				//Como son 64 bits, y ya escribimos los LSB sumamos 4 para escribir los MSB
	LDR		R6, [R0, R5]			//Traemos ese valor de SERIE
	STR		R6, [R3],	#4			//Escribimos ese valor en SortedValues y avanzamos a la siguiente posición
	
	SUBS	R1,	R1,	#1				//Restamos para saber cuántas valores más nos faltan
	BNE		LoopGetValues			//Si no llegamos a 0 se sigue haciendo el loop
	
EndGetValues:
	//Recuperamos los registros R4 a R7 y liberamos del stack
	LDR		R7,	[SP]
	LDR		R6,	[SP, #4]
	LDR		R5,	[SP, #8]
	LDR		R4,	[SP, #12]
	ADD		SP,	SP,	#16
	
	MOV		PC,	LR					//Retornamos
	
	.data
	/* Constantes y variables propias:
	 * Utilice esta zona para declarar sus constantes y variables requeridas
	 */
SERIE:			.ds.l	SIZE*2			//Almacenar la Sucesion
	
	/* Constantes y variables dadas por el profesor:
	 * Esta zona contiene la difinicion de N, POS, ORDER y SortedValues
	 */
N:				.dc.l	50
POS:			.dc.l	7, 21, 45, 68, 3, 34, 55, 12, 89, 16, 29, 63, 42, 11, 81, 50, 24, 77, 9, 58, 35, 72, 4, 87, 18, 69, 27, 60, 5, 82, 47, 32, 74, 19, 53, 38, 66, 13, 79, 23, 57, 8, 70, 36, 85, 31, 61, 14, 76, 25
ORDER:			.dc.l	1

SortedValues:	.ds.l	MAXN*2