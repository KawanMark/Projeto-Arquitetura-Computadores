ORG 0000H
SJMP MAIN 

ORG 0030H

MAIN: 
	MOV P1, #00; inicializa o led
	CALL INICIAR; chamar a rotina para iniciar

	;---LOOP principal para checar senha
	MOV R0, #04 ; senha de 4 digitos
	MOV DPTR, #SENHA_CORRETA ; aponta para endereço da senha corretz


INICIAR:
    ; Rotina de inicialização
    MOV P1, #00H    ; Apaga o LED
    RET

LER_SENHA:
;nao sei fazer eu acho

ALARME_ATIVADO:
	SET P1.0 ;acende o led no p1.0 para alarme ativo para senha correta
	RET


SENHA_INCORRETA:
	CLR P1.0 ; apaga o led no p1.9 para indicar senha incorreta
	RET

SENHA_CORRETA:
    DB 01H, 02H, 03H, 04H  ; Define a senha como 1234

MAPEAR_TECLAS: ; Subrotina para mapear
	MOV 40H, #'#' ; e facilitar a identificacao 
	MOV 41H, #'0' ; de qual tecla foi pressionada
	MOV 42H, #'*'
	MOV 43H, #'9'
	MOV 44H, #'8'
	MOV 45H, #'7'
	MOV 46H, #'6'
	MOV 47H, #'5'
	MOV 48H, #'4'
	MOV 49H, #'3'
	MOV 4AH, #'2'
	MOV 4AH, #'1'
