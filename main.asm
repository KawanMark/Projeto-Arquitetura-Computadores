ORG 0000H
SJMP MAIN 

ORG 0030H

senha equ 20h

MAIN: 
	MOV P1, #00; inicializa o led
	ACALL iniciar; chamar a rotina para iniciar
	SJMP $
iniciar:
	ACALL mapearTeclas
	LJMP fim

; Subrotina para mapear
; e facilitar a identificacao
; de qual tecla foi pressionada
mapearTeclas: 
	MOV 40H, #'#' ; Botao para confirmar senha digitada 
	MOV 41H, #'0' 
	MOV 42H, #'*' ; Botao para apagar a senha digitada
	MOV 43H, #'9'
	MOV 44H, #'8'
	MOV 45H, #'7'
	MOV 46H, #'6'
	MOV 47H, #'5'
	MOV 48H, #'4'
	MOV 49H, #'3'
	MOV 4AH, #'2'
	MOV 4BH, #'1'

registrarSenha:
	MOV b, #04h ; Contador de quantos digitos recebeu
	MOV R1, #senha ; Endereco onde vai registrar a senha

receberSenha:
	ACALL lerTeclado
	JNB F0, receberSenha ; Caso nao houve leitura de algum digito
	CLR F0
	MOV @R1, A
	INC R1
	DJNZ b, receberSenha
	LJMP fim

pegarChave:
	SETB F0
	MOV A, R0
	LJMP fim

lerColuna:
	JNB P0.4, pegarChave
	INC R0
	JNB P0.5, pegarChave
	INC R0
	JNB P0.6, pegarChave
	INC R0
	LJMP fim
	
lerTeclado:
	MOV R0, #00

	MOV P0, #0FFH
	CLR P0.0
	CALL lerColuna
	JB F0, fim

	SETB P0.0
	CLR P0.1
	CALL lerColuna
	JB F0, fim

	SETB P0.1
	CLR P0.2
	CALL lerColuna
	JB F0, fim

	SETB P0.2
	CLR P0.3
	CALL lerColuna
	JB F0, fim

delay:
	MOV R7, #50
	ACALL timer
	LJMP fim

timer:
	DJNZ R7, fim

fim:
	ret
