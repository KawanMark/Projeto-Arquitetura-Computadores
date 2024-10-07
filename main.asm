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


SENHA_CORRETA:
    DB 01H, 02H, 03H, 04H  ; Define a senha como 1234