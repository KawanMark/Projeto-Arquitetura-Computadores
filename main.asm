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
SET P1.0 ;acende o led no p1.0 para alarme ativo
RET


SENHA_CORRETA:
    DB 01H, 02H, 03H, 04H  ; Define a senha como 1234