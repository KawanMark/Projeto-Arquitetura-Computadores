ORG 0000H
SJMP MAIN 

ORG 0030H

MAIN: 
	MOV P1, #00; inicializa o led
	ACALL INICIAR; chamar a rotina para iniciar

	;---LOOP principal para checar senha
	MOV R0, #04 ; senha de 4 digitos
	MOV DPTR, #senhaIncorreta ; aponta para endereço da senha correta


iniciar:
    ; Rotina de inicialização
    MOV P1, #00H    ; Apaga o LED
   	ljmp fim

alarmeAtivado:
	SETB P1.0 ;acende o led no p1.0 para alarme ativo para senha correta
	ljmp fim

senhaIncorreta:
	CLR P1.0 ; apaga o led no p1.9 para indicar senha incorreta
	lmjp fim

senhasCorreta:
    DB 01H, 02H, 03H, 04H  ; Define a senha como 1234

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
	MOV 4AH, #'1'

registrarSenha:
	MOV b, #04h ; Contador de quantos digitos recebeu
	MOV R1, #20h ; Endereco onde vai registrar a senha
	ACALL receberSenha

receberSenha:
	ACALL leituraTeclado
	JNB F0, receberSenha ; Caso nao houve leitura de algum digito
	djnz b, fim
	mov a, 	

pegarChave:
	SETB F0
	LJMP fim

lerColuna:
	JNB P0.4, pegarChave
	INC R0
	JNB P0.5, pegarChave
	INC R0
	JNB P0.6, pegarChave
	INC R0
	ljpm fim
	
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

verificarAlarme:

delay:
	MOV R7, #50
	DJNZ R7, $
	fim
fim:
	ret
