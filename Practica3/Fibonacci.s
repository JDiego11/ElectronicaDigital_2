.global _start
	.equ	MAXN,	30
	.equ	SIZE,	40
	.text
_start:
//Verificacion limite de datos correcto
	//Comparar 5 <= N <= 30
	LDR		R0,	=N
	LDR		R0,	[R0]
	CMP		R0,	#5			//Si N < 5 Abort
	BLT		Leave
	CMP		R0,	#30			//Si N > 30 Abort
	BGT		Leave
	
	//Comparar ORDER = 0, ORDER = 1
	LDR		R0,	=ORDER
	LDR		R0,	[R0]
	CMP		R0,	#0			//Si N < 0 Abort
	BLT		Leave
	CMP		R0,	#1			//Si N > 1 Abort
	BGT		Leave
	
	//Verificar que Los valores en POS estén entre 1 y 40
	LDR		R0, =POS
	LDR		R2,	=N
	LDR		R2,	[R2]

LoopVer:
	LDR		R1,	[R0],	#4
	CMP		R1,	#1			//Si POS[i] < 1
	BLT		Leave
	CMP		R1,	#40			//Si POS[i] > 40
	BGT		Leave
	
	
	SUBS	R2,	R2,	#1
	BNE		LoopVer
	
//Si todo es correcto, empezar
	B		Begin
	
//Abortar
Leave:
	LDR		R0,	=SortedValues
	LDR		R1,	=0xA5A5A5A5
	STR		R1, [R0]
	B		_finish

Begin:
 //Generar la sucesion de Fibonacci
	LDR		R0,	=SERIE
	MOV		R1,	#SIZE
	
Fibo:
	MOV		R2, #0			//Iniciamos R2 en 0 y ese valor lo llevamos a la primera posicion de la serie
	STR		R2,	[R0],	#4
	ADD		R2, R2, #1		//Le sumamos 1 a R2 para que tome el valor de 1 y ese es el segundo valor
	STR		R2,	[R0],	#4
	SUB		R1,	R1,	#2

LoopFibo:
	LDR		R2,	[R0, #-8]
	LDR		R3,	[R0, #-4]
	ADD		R3,	R2,	R3
	STR		R3,	[R0],	#4
	
	SUBS	R1,	R1,	#1
	BNE		LoopFibo
		
 //Organizar de manera ascendente o descendente
	LDR		R0,	=POS					//Direccion del vector de posiciones
 	LDR		R1, =N						//Direccion del tamaño del vector de posiciones
	LDR		R1,	[R1]					//Cargamos el numero de posiciones en R1
	LDR		R2, =ORDER					//Direccion del orden 0-asc, 1-desc
	LDR		R2, [R2]					//Control de ordenamiento
	MOV		R3,	#0						//Inicializamos R3 en 0 -> i=0
	MOV		R12,	#4					//Para el MUL
	
OuterLoop:
	SUB		R5,	R1,	#1				//Hacemos N-1
	CMP		R3,	R5					//Comparar i con N-1
	BGE		EndSorter				//Termina ciclo principal
	
	MOV		R4,	#0					//Hacemos R4 como j=0
	
InnerLoop:
	SUB		R5,	R1,	#1				//Hacemos N-1
	SUB		R5,	R5, R3				//N-i-1
	CMP		R4,	R5					//Comparar j con N-i-1
	BGE		NextOuter				//Volver a hacer el ciclo principal
	
	MUL		R6,	R4,	R12				//Multiplicamos j*4 para movernos por las posiciones para hacer POS[j]
	LDR		R7,	[R0, R6]			//Cargamos en R7 lo que hay en POS[j]
	ADD		R8, R4, #1				//Hacemos R8 como j+1
	MUL		R9,	R8, R12				//Multiplicamos (j+1)*4 para hacer POS[j+1]
	LDR		R8, [R0, R9]			//Cargamos en R8 lo que hay en POS[j+1]
	
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
	STR		R7,	[R0, R9]
	STR		R8,	[R0, R6]
	
NotGreater:
	ADD		R4,	R4,	#1				//j++
	B		InnerLoop				//Volver a hacer el ciclo interno

NextOuter:
	ADD		R3,	R3,	#1				//i++
	B		OuterLoop				//Volver a hacer el ciclo principal

EndSorter:
	
 //Sacar los valores en las posiciones dadas
 	LDR		R0,	=SERIE
	LDR		R1, =N
	LDR		R2, [R1]
	LDR		R1,	=POS
	LDR		R3,	=SortedValues
	MOV		R12,	#4

GetValues:
	LDR		R4,	[R1],	#4
	SUB		R5, R4, #1
	MUL		R5, R5, R12
	LDR		R6, [R0, R5]
	STR		R6, [R3],	#4
	
	SUBS	R2,	R2,	#1
	BNE		GetValues

_finish:
	B	_finish
	
	.data
	/* Constantes y variables propias:
	 * Utilice esta zona para declarar sus constantes y variables requeridas
	 */
SERIE:			.ds.l	SIZE

	
	/* Constantes y variables dadas por el profesor:
	 * Esta zona contiene la difinicion de N, POS, ORDER y SortedValues
	 */
SortedValues:	.ds.l	MAXN 
	
N:				.dc.l	10
POS:			.dc.l	31, 12, 14, 12, 28, 30, 25, 28, 34, 38
ORDER:			.dc.l	0