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
            	CONSTANT	rs232, 00001111		; puerto comunicacion serie es el 00
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
		;
		ADDRESS		00			;el programa se cargara a partir de la dir 00
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Inicio del programa
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:	
		CALL		recibe			;controlamos el inicio

		CALL		testARQ			;probamos la nueva arquitectura a 32 bits
		CALL		recibe			;esperamos
		
		CALL		testSHF			;probamos la nueva instruccion
		CALL		recibe			;esperamos
		
		CALL		testFullMem		;mostramos toda la memoria del SECDED
		CALL		recibe			;esperamos -> ACTIVAMOS INTERRUPTOR
		
		CALL		testCorErr		;mostramos la tabla de datos corregida
		CALL		recibe			;esperamos
		
		CALL		testWrMem		;escribimos en la memoria y mostramos la nueva tabla de datos
		CALL		recibe			;esperamos
		
		CALL		testMemShf		;probamos la aplicación de la nueva instruccion en combinación con el SECDED
		CALL		recibe			;esperamos -> DESACTIVAMOS INTERRUPTOR
		
		CALL		testErrCode		;mostramos los 4 códigos de error
		CALL		recibe			;esperamos -> ACTIVAMOS INTERRUPTOR
		
		CALL		testErrCode		;mostramos los 4 códigos de error
		
		JUMP		start			;cerramos bucle
		
		;TEST PICOBLAZE
		;Muestra de datos a 32 bits
testARQ:
		LOAD		s10, FFFFFFFF	;cargo todo unos
		LOAD		aux, s10		;lo cargo en aux
		CALL		show			;muestro los 32 unos
		CALL		saltoLinea
		
		;Muestra de uso de instrucción SHIFTRS232
testSHF:
		LOAD		s11, 484F4C41	;HOLA
		LOAD		aux, s11		;lo cargo en aux
		CALL		show			;lo muestro en binario
		LOAD		s25, 00000004	;cargo el contador
bucle:	
		SHIFTRS232	s11				;OLAH -> LAHO -> AHOL -> HOLA
		LOAD		txreg, s11		;transmite caracter a la derecha
		CALL		transmite		;enviamos 8 bits menos sig (ascii)
		SUB			s25, 00000001	;decrementamos contador
		JUMP		NZ, bucle		;si da 0, salimos, sino, seguimos
		CALL		saltoLinea
		RETURN
		
		;TEST SECDED
		;Mostrar datos almacenados en memoria de 32bits
testFullMem:
		LOAD		s26, 0000000F	;contador a 16
		LOAD		s12, 00000050	;primera dirección de memoria
bucle2:
		INPUT		aux, s12		;cargo en aux el valor que devuelve la memoria
		CALL		show			;lo muestro		
		ADD			s12, 00000001	;apunto al siguiente registro
		SUB			s26, 00000001	;decremento 1 el contador
		JUMP		NZ, bucle2		;si no he acabado, sigo en bucle, sino salto
		CALL		saltoLinea
		RETURN
		
testCorErr:
		;TRAS HABER ACTIVADO CORRECIÓN DE ERRORES
		CALL		testFullMem
		RETURN
		
testWrMem:
		LOAD		s13, FF0000FF	;dato random
		OUTPUT		s13, 00000050	;lo escribo en la posicion 1
		LOAD		s14, 0F0F0F0F	;dato random
		OUTPUT		s14, 0000005A	;lo escribo en la posicion 10
		LOAD		s15, 484F4C41	;HOLA
		OUTPUT		s15, 0000005E	;lo escribo en la posicion 15
		CALL		testFullMem		;muestro toda la memoria para ver los cambios

testMemShf:
		INPUT		s16, 0000005E	;cargo la palabra HOLA en s16
		LOAD		s27, 00000004	;cargo el contador
bucle3:	
		SHIFTRS232	s16				;OLAH -> LAHO -> AHOL -> HOLA
		LOAD		txreg, s16		;transmite caracter a la derecha
		CALL		transmite		;enviamos 8 bits menos sig (ascii)
		SUB			s27, 00000001	;decrementamos contador
		JUMP		NZ, bucle3		;si da 0, salimos, sino, seguimos
		CALL		saltoLinea
		RETURN
		
testErrCode:
		INPUT		aux, 00000054	;cargo dato err_code = 00
		CALL		show			;lo muestro
		INPUT		aux, 00000070	;cargo codigo de error para mostar
		CALL		show			;lo muestro
		CALL		recibe			;espero pulsación
		
		INPUT		aux, 00000055	;cargo dato err_code = 01
		CALL		show			;lo muestro
		INPUT		aux, 00000070	;cargo codigo de error para mostar
		CALL		show			;lo muestro
		CALL		recibe			;espero pulsación
		
		INPUT		aux, 00000056	;cargo dato err_code = 10
		CALL		show			;lo muestro
		INPUT		aux, 00000070	;cargo codigo de error para mostar
		CALL		show			;lo muestro
		CALL		recibe			;espero pulsación
		
		INPUT		aux, 00000057	;cargo dato err_code = 11
		CALL		show			;lo muestro
		INPUT		aux, 00000070	;cargo codigo de error para mostar
		CALL		show			;lo muestro
		CALL		recibe			;espero pulsación
		
		CALL		saltoLinea
		RETURN
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de recepcion de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recibe:		;esperamos a que se reciba un bit de inicio
		INPUT		rxreg, rs232
		AND			rxreg, 80
		JUMP		NZ, recibe
		CALL		wait_05bit
		;almacenamos los 8 bits de datos
		LOAD		contbit,09
next_rx_bit:	CALL		wait_1bit
		SR0		rxreg
		INPUT		s0, rs232
		AND		s0, 80
		OR		rxreg, s0
		SUB 		contbit, 01
		JUMP		NZ, next_rx_bit
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de transmision de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transmite:	;enviamos un bit de inicio
		LOAD		s0, 00
		OUTPUT		s0, rs232
		CALL		wait_1bit
		;enviamos los 8 bits de datos
		LOAD 		contbit, 08
next_tx_bit:	OUTPUT		txreg, rs232
		CALL		wait_1bit
		SR0		txreg
		SUB 		contbit, 01
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
					
            	;clk=100MHz, 115200bps, cont1=0A, cont2=14
            	;esta rutina ejecuta 1 + (1 + 10*(1 + 20*2 + 2)) + 1 = 433 instruciones,
            	;aproximandose al numero teorico de (8,68us/bit)/(0,02 us/instruc) = 434 instr/bit necesarias.
            	
				
				
wait_1bit:	LOAD 		cont1, 0A  
espera2:	LOAD		cont2, 14
espera1:	SUB		cont2, 01
		JUMP		NZ, espera1
		SUB		cont1, 01
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
				
				;clk=100MHz, 115200bps, cont1=05, cont2=14
            	;1 + (1 + 5*(1 + 20*2 + 2)) + 1 = 218; aprox = 217
            	
				
wait_05bit:	LOAD 		cont1, 05 
espera4:	LOAD		cont2, 14
espera3:	SUB		cont2, 01
		JUMP		NZ, espera3
		SUB		cont1, 01
		JUMP		NZ, espera4
		RETURN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	; FIN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
