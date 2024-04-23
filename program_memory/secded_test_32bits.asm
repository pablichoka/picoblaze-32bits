            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;     
	    ; Programa: Helloworld           
            ; Transmision RS-232 por software. 
            ; 115200  bps, 8 data bits, no parity, 1 stop bit, no flow control,
	    ;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;declaracion de constantes y variables
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                  
            	CONSTANT	rs232, 00001111				; puerto comunicacion serie es el FFFFFFFF
				; CONSTANT	d0, 50
				; CONSTANT	d1, 51
				; CONSTANT	d2, 52
				; CONSTANT	d3, 53
				; CONSTANT	d4, 54
				; CONSTANT	d5, 55
				; CONSTANT	d6, 56
				; CONSTANT	d7, 57
				; CONSTANT	d8, 58
				; CONSTANT	d9, 59
				; CONSTANT	d10, 5A
				; CONSTANT	d11, 5B
				; CONSTANT	d12, 5C
				; CONSTANT	d13, 5D
				; CONSTANT	d14, 5E
				; CONSTANT	d15, 5F
            						; rx es el bit 0 del puerto 00(entrada)
							; tx es el bit 7 del puerto 00(salida), esto es porque
		;el hyperterminal envia primero el LSB, por eso vamos desplazando a la 
		;izquierda al recibir, y al enviar tambien, con lo que enviamos de nuevo
		;el LSB primero como corresponde para que lo entienda el hyperterminal
            	NAMEREG		s1, txreg		;buffer de transmision
            	NAMEREG		s2, rxreg		;buffer de recepcion
		NAMEREG		s3, contbit		;contador de los 8 bits de datos
		NAMEREG		s4, cont1		;contador de retardo1
		NAMEREG		s5, cont2		;contador de retardo2
		NAMEREG 	s6, aux
		NAMEREG		s7, cont3
		NAMEREG		s8, show_reg
		NAMEREG		s9, aux2
		NAMEREG		s10, aux3
		NAMEREG		s11, aux4
		NAMEREG		s12, cont4
		
		;
		ADDRESS		00			;el programa se cargara a partir de la dir 00
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Inicio del programa
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		DISABLE		INTERRUPT
start:		;esperamos a recibir un caracter
		; CALL		recibe
		; LOAD		txreg, FFFFFFFF
		; OUTPUT		txreg, 00000050
		; CALL		recibe
		; INPUT		rxreg, 00000050 ;posicion 0
		; LOAD 		aux, rxreg
		; CALL		show
		; CALL		recibe
		; LOAD		txreg, 0000FFFF
		; OUTPUT		txreg, 0000005E
		; CALL		recibe
		; INPUT		rxreg, 0000005E ;posicion 14
		; LOAD 		aux, rxreg
		; CALL		show
		
		; CALL		recibe
		; LOAD		txreg, FFFFFFFF
		; OUTPUT		txreg, 00000050;posicion 1
		; LOAD		txreg, 000F000F
		; OUTPUT		txreg, 00000053;posicion 4
		; LOAD		txreg, ABCDEF98
		; OUTPUT		txreg, 0000005A;posicion 11
		CALL		recibe
		CALL		recorrer

		JUMP		start
		
recorrer:

		; LOAD		aux, 0000FFFF
		; CALL		show
		INPUT		rxreg, 0000005E ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		;CALL 		saltoLinea
		; INPUT		rxreg, 00000080 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000050 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000052 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000053 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000054 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000055 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000056 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000057 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000058 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000059 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 0000005A ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 0000005B ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 0000005C ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 0000005D ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 00000051 ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		CALL		recibe
		INPUT		rxreg, 0000005F ;obtengo un dato
		LOAD 		aux, rxreg; cargo el dato en aux
		CALL		show ;lo muestro
		; INPUT		rxreg, 00000070 ;obtengo un codigo de error
		; LOAD 		aux, rxreg; cargo el dato en aux
		; CALL		show ;lo muestro
		; CALL		recibe
		; ; LOAD		aux, 000000FF ;obtengo un dato
		; ; SHIFTRS232	aux; 
		; ; CALL		show ;lo muestro
		CALL		saltoLinea
		; ; CALL		recibe
		
		
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de recepcion de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recibe:		;esperamos a que se reciba un bit de inicio
		INPUT		rxreg, rs232
		AND			rxreg, 00000080
		JUMP		NZ, recibe
		CALL		wait_05bit
		;almacenamos los 8 bits de datos
		LOAD		contbit,00000009
next_rx_bit:CALL	wait_1bit
		SR0			rxreg
		INPUT		s0, rs232
		AND			s0, 00000080	;esto se hace para obtener quedarnos solo con el bit más significativo (de 8 bits)
		OR			rxreg, s0
		SUB 		contbit, 00000001
		JUMP		NZ, next_rx_bit
		;SHIFTRS232 rxreg
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de transmision de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transmite:	;enviamos un bit de inicio
		LOAD		s0, 00000000
		OUTPUT		s0, rs232
		CALL		wait_1bit
		;enviamos los 8 bits de datos
		LOAD 		contbit, 00000008
next_tx_bit:	OUTPUT		txreg, rs232
		CALL		wait_1bit
		SR0			txreg
		SUB 		contbit, 00000001
		JUMP		NZ, next_tx_bit
		;enviamos un bit de parada
		LOAD		s0, FF
		OUTPUT		s0, rs232
		CALL		wait_1bit
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina espera 1 bit (a 9600bps)
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;clk=50MHz, 9600bps, cont1=0A, cont2=80
            	;esta rutina ejecuta 1 + (1 + 10*(1 + 128*2 + 2)) + 1 = 2593 instruciones,
            	;aproximandose al numero teorico de (104,16us/bit)/(0,04 us/instruc) = 2604,166 instr/bit necesarias.
            	;clk=40MHz, 57600bps, cont1=05, cont2=21
            	;esta rutina ejecuta 1 + (1 + 5*(1 + 33*2 + 2)) + 1 =  instruciones,
            	;aproximandose al numero teorico de (17,36us/bit)/(0,05 us/instruc) = 347,2 instr/bit necesarias.
            	;clk=50MHz, 115200bps, cont1=03, cont2=22
            	;esta rutina ejecuta 1 + (1 + 3*(1 + 34*2 + 2)) + 1 = 216 instruciones,
            	;aproximandose al numero teorico de (8,68us/bit)/(0,04 us/instruc) = 217 instr/bit necesarias.
            	;clk=50MHz, 230400bps, cont1= 03, cont2= 10
            	;esta rutina ejecuta 1 + (1 + 3*(1 + 16*2 + 2)) + 1 = 108 instruciones,
            	;aproximandose al numero teorico de (4,34us/bit)/(0,04 us/instruc) = 108,5 instr/bit necesarias.
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;OJO: con el USB2COM no he conseguido pasar de los 230400bps bien. 
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;clk=50MHz, 460800bps, cont1= 03, cont2=06 OJO:Hay que ponerle 1 menos a cont2 y que tome 
            	;caracteres ascii de 7 bits para que funcione.
            	;esta rutina ejecuta 1 + (1 + 3*(1 + 7*2 + 2)) + 1 = 54 instruciones,
            	;aproximandose al numero teorico de (2,17us/bit)/(0,04 us/instruc) = 54,25 instr/bit necesarias.
            	;clk=50MHz, 921600bps, cont1=01, cont2=0A NO FUNCIONA
            	;esta rutina ejecuta 1 + (1 + 1*(1 + 10*2 + 2)) + 1 = 26 instruciones,
            	;aproximandose al numero teorico de (1,085us/bit)/(0,04 us/instruc) = 27,127 instr/bit necesarias.
				
				;PARA PICOBLAZE A 100MHz
					
            	;clk=100MHz, 115200bps, cont1=01, cont2=D6
            	;esta rutina ejecuta 1 + (1 + 1*(1 + 214*2 + 2)) + 1 = 434 instruciones,
            	;aproximandose al numero teorico de (8,68us/bit)/(0,02 us/instruc) = 434 instr/bit necesarias.
            	
				
				
wait_1bit:	LOAD 		cont1, 00000001  
espera2:	LOAD		cont2, 000000D6
espera1:	SUB			cont2, 00000001
			JUMP		NZ, espera1
			SUB			cont1, 00000001
			JUMP		NZ, espera2
			RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina espera 0,5 bits (bit de inicio, a 9600bps)
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;clk=50MHz, 9600bps, cont1=05, cont2=80
            	;1 + (1 + 5*(1 + 128*2 + 2)) + 1 = 1298; aprox = 1302
            	;clk=40MHz, 57600bps, cont1=03, cont2=1B
            	;1 + (1 + 3*(1 + 27*2 + 2)) + 1 = 1298; aprox = 173.6
				;clk=50MHz, 115200bps, cont1=03, cont2=10
            	;1 + (1 + 3*(1 + 16*2 + 2)) + 1 = 108; aprox = 108.5
            	;clk=50MHz, 230400bps, cont1= 03, cont2= 07
            	;1 + (1 + 3*(1 + 7*2 + 2)) + 1 = 54; aprox = 54,25
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;OJO: con el USB2COM no he conseguido pasar de los 230400bps bien. 
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;clk=50MHz, 460800bps, cont1= 01, cont2= 0A
            	;1 + (1 + 1*(1 + 10*2 + 2)) + 1 = 26; aprox = 27,125
            	;clk=50MHz, 921600bps, cont1=01, cont2=04 NO FUNCIONA
            	;1 + (1 + 1*(1 + 4*2 + 2)) + 1 = 14; aprox = 13,56
				
				;PARA PICOBLAZE A 100MHz	
				
				;clk=100MHz, 115200bps, cont1=02, cont2=34
            	;1 + (1 + 2*(1 + 52*2 + 2)) + 1 = 218; aprox = 217
            	
				
wait_05bit:	LOAD 		cont1, 00000002 
espera4:	LOAD		cont2, 00000034
espera3:	SUB		cont2, 00000001
		JUMP		NZ, espera3
		SUB		cont1, 00000001
		JUMP		NZ, espera4
		RETURN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	; FIN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

show:
		LOAD	cont3, 00000020 ;32
show_start:
		LOAD	show_reg, aux
		AND		show_reg, 80000000 ;nos quedamos solo con el bit mas significativo
		OR		show_reg, 00000000 ;comparamos el valor del bit mas significativo, si es cero, la or dara cero, si no , es un uno
		JUMP	NZ, uno	;si no es cero, vamos a imprimir un uno
		JUMP	cero
show_aux:
		RL      aux
		SUB 	cont3, 00000001
		JUMP	NZ, show_start
		LOAD	txreg, 0000000A
		CALL	transmite
		LOAD	txreg, 0000000D
		CALL	transmite
		RETURN
		
uno:
		LOAD 	txreg, 00000031 ;1 ascii
		call 	transmite
		JUMP	show_aux
		
cero:
		LOAD	txreg, 00000030 ; 0 ascii
		call	transmite
		JUMP	show_aux
		
saltoLinea:	LOAD		txreg, 0000000A
			CALL		transmite
			LOAD		txreg, 0000000D
			CALL 		transmite
			RETURN
		
		
		
		
;;TEST DE INSTRUCCIONES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;:TEST SHIFTRS232;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; LOAD		aux, 484F4C41	;HOLA
		; LOAD		aux2, 00000004
; bucle:	SHIFTRS232	aux
		; LOAD		txreg, aux
		; CALL		transmite
		; SUB			aux2, 00000001
		; JUMP 		NZ, bucle
		
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;TEST ENABLE/DISABLE/INTERRUPT;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; rutina: LOAD		aux, 00000005
		; LOAD		aux3, 00000040
; rutina1:CALL		transmite
		; SUB			aux, 00000001
		; JUMP		Z, rutina2
		; ADD			aux3, 00000001
		; LOAD		txreg, aux3
		; JUMP 		rutina1
; rutina2:ENABLE		INTERRUPT
		; LOAD		aux2, 0000000A
; bucle:	SUB			aux2, 00000001
		; JUMP		NZ, bucle
		; LOAD		aux2, 0000000A
		; JUMP		bucle
		
; interrup:		;ESTA SUBRUTINA HA DE COLOCARSE AL FINAL DEL PROGRAMA
		; DISABLE		INTERRUPT
		; CALL		recibe
		; LOAD		txreg, rxreg
		; call		transmite
		; LOAD		txreg, aux2
		; ADD			txreg, 00000030
		; call		transmite
		; RETURNI		ENABLE
		; LOAD		txreg, 0000002F
		; CALL		transmite
		; ADDRESS		000007FF	;aqui salta cuando hay una interrupcion
		; JUMP		interrup
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;TEST ADDCY/SUBCY;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; LOAD		aux3, FFFFFFFF
		; LOAD		aux2, 0000000A ;10
		; add		aux3, 00000001 ;generamos carry --> 1
		; addcy		aux2, 0000000A ;10 --> 21
		; LOAD		aux, aux2
		; call		show
		; LOAD		aux3, FFFFFFFF
		; LOAD		aux2, 0000000A ;10
		; add		aux3, 00000001 ;generamos carry --> 1
		; subcy		aux2, 00000008 ;8 --> 1
		; LOAD		aux, aux2
		; call		show