    RS      equ     P1.3   
    EN      equ     P1.2    

org 0200h
msg1:
	DB "Informe a senha"
	DB 0

org 0000h
	LJMP START

org 0030h
START:
	MOV 40H, #'#' 
	MOV 41H, #'0'
	MOV 42H, #'*'
	MOV 43H, #'9'
	MOV 44H, #'8'
	MOV 45H, #'7'
	MOV 46H, #'6'
	MOV 47H, #'5'
	MOV 48H, #'4'
	MOV 49H, #'3'
	MOV 4AH, #'2'
	MOV 4BH, #'1'	  

MAIN:
	ACALL lcd_init
	MOV A, #00h
	CALL posicionaCursor
	MOV DPTR, #msg1
	CALL escreveString
	JMP $
; ------------------- Subrotinas do LCD -------------------;
lcd_init:

	CLR RS		
	
	CLR P1.7
	CLR P1.6	
	SETB P1.5
	CLR P1.4

	SETB EN
	CLR EN	

	CALL delay

	SETB EN		
	CLR EN	

	SETB P1.7

	SETB EN
	CLR EN
			
	CALL delay

	CLR P1.7
	CLR P1.6
	CLR P1.5	
	CLR P1.4	

	SETB EN	
	CLR EN	

	SETB P1.6
	SETB P1.5

	SETB EN
	CLR EN	

	CALL delay


	CLR P1.7
	CLR P1.6
	CLR P1.5
	CLR P1.4

	SETB EN
	CLR EN	

	SETB P1.7
	SETB P1.6
	SETB P1.5
	SETB P1.4

	SETB EN
	CLR EN	

	CALL delay
	RET





;Limpa o display
clearDisplay:
	CLR RS	
	CLR P1.7		
	CLR P1.6	
	CLR P1.5	
	CLR P1.4		

	SETB EN	
	CLR EN	

	CLR P1.7	
	CLR P1.6	
	CLR P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay	
	RET

; ------------------- Subrotinas para envio de msgs para LCD ------------------;

enviarCaractere:
	SETB RS  	
	MOV C, ACC.7	
	MOV P1.7, C		
	MOV C, ACC.6	
	MOV P1.6, C		
	MOV C, ACC.5	
	MOV P1.5, C		
	MOV C, ACC.4	
	MOV P1.4, C			

	SETB EN		
	CLR EN			

	MOV C, ACC.3		
	MOV P1.7, C			
	MOV C, ACC.2		
	MOV P1.6, C			
	MOV C, ACC.1		
	MOV P1.5, C			
	MOV C, ACC.0	
	MOV P1.4, C			

	SETB EN
	CLR EN	

	CALL delay
	CALL delay
	RET

escreveString:
	MOV R2, #00h
rot:
	MOV A, R2
	MOVC A, @A+DPTR
	ACALL enviarCaractere
	INC R2
	JNZ rot
	LJMP fim
; ------------------- Subrotinas para posicionamentos do cursor ------------------;

posicionaCursor:
	CLR RS	
	SETB P1.7
	MOV C, ACC.6
	MOV P1.6, C
	MOV C, ACC.5
	MOV P1.5, C
	MOV C, ACC.4
	MOV P1.4, C

	SETB EN		
	CLR EN	

	MOV C, ACC.3
	MOV P1.7, C
	MOV C, ACC.2
	MOV P1.6, C
	MOV C, ACC.1
	MOV P1.5, C
	MOV C, ACC.0
	MOV P1.4, C	

	SETB EN
	CLR EN	

	CALL delay
	CALL delay
	RET


retornaCursor:
	CLR RS	
	CLR P1.7
	CLR P1.6
	CLR P1.5
	CLR P1.4

	SETB EN
	CLR EN

	CLR P1.7
	CLR P1.6	
	SETB P1.5
	SETB P1.4

	SETB EN	
	CLR EN		

	CALL delay
	RET

; ------------------- Subrotinas do teclado -------------------;

leituraTeclado:
    MOV R0, #0          ; Limpa R0 - começa pela tecla 0
    MOV P0, #0FFh

    ; Varre linha 0
    CLR P0.0
    CALL colScan
    JB F0, finish       ; Se tecla encontrada, sai

    ; Varre linha 1
    SETB P0.0
    CLR P0.1
    CALL colScan
    JB F0, finish

    ; Varre linha 2
    SETB P0.1
    CLR P0.2
    CALL colScan
    JB F0, finish

    ; Varre linha 3
    SETB P0.2
    CLR P0.3
    CALL colScan
    JB F0, finish

finish:
    RET

colScan:
    JNB P0.4, gotKey
    INC R0
    JNB P0.5, gotKey
    INC R0
    JNB P0.6, gotKey
    INC R0
    RET

gotKey:
    SETB F0             ; Indica tecla encontrada
    RET

delay:
	MOV R7, #50
	DJNZ R7, $
	RET

fim:
	RET
