ORG 0000H
SJMP MAIN 

ORG 0030H

MAIN: 
MOV P1, #00; inicializa o led
CALL INICIAR; chamar a rotina para iniciar

;---LOOP principal para checar senha