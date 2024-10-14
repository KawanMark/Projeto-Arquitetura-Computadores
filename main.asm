ORG 0000H
SJMP MAIN 

ORG 0030H

senha equ 20h

MAIN: 
    MOV P1, #00 ; Inicializa o LED
    ACALL iniciar ; Chama a rotina para iniciar
    SJMP $

iniciar:
    ACALL mapearTeclas
    LJMP fim

; Subrotina para mapear e facilitar a identificação de qual tecla foi pressionada
mapearTeclas: 
    MOV 40H, #'#'  ; Botão para confirmar senha digitada 
    MOV 41H, #'0'  
    MOV 42H, #'*'  ; Botão para apagar a senha digitada
    MOV 43H, #'9'
    MOV 44H, #'8'
    MOV 45H, #'7'
    MOV 46H, #'6'
    MOV 47H, #'5'
    MOV 48H, #'4'
    MOV 49H, #'3'
    MOV 4AH, #'2'
    MOV 4BH, #'1'  ; Mapeamento da tecla '1'

; Registro da senha no endereço de memória
registrarSenha:
    MOV b, #04h  ; Contador de quantos dígitos recebeu
    MOV R1, #senha ; Endereço onde vai registrar a senha

receberSenha:
    ACALL lerTeclado
    JNB F0, receberSenha ; Caso não houve leitura de algum dígito
    CLR F0
    MOV @R1, A  ; Armazena o valor lido no endereço apontado por R1
    INC R1      ; Incrementa o endereço para o próximo dígito
    DJNZ b, receberSenha
    LJMP fim

; Sub-rotina de leitura da tecla pressionada
pegarChave:
    SETB F0
    MOV A, R0
	ACALL delay ; Debounce: adicione um pequeno atraso para evitar leituras múltiplas
    LJMP fim

; Rotina para leitura de colunas do teclado
lerColuna:
    JNB P0.4, pegarChave ; Verifica se a tecla da coluna 1 foi pressionada
    INC R0
    JNB P0.5, pegarChave ; Verifica se a tecla da coluna 2 foi pressionada
    INC R0
    JNB P0.6, pegarChave ; Verifica se a tecla da coluna 3 foi pressionada
    INC R0
    LJMP fim

; Rotina para varredura das colunas do teclado
lerTeclado:
    MOV R0, #00  ; Inicializa R0 com 0 para capturar o valor da tecla

    MOV P0, #0FFH  ; Configura as portas P0 para alto
    CLR P0.0       ; Ativa a primeira coluna
    CALL lerColuna ; Chama a leitura das colunas
    JB F0, fim     ; Se uma tecla foi lida, sai

    SETB P0.0      ; Desativa a primeira coluna
    CLR P0.1       ; Ativa a segunda coluna
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

    LJMP fim

; Rotina de delay para debounce
delay:
    MOV R7, #50  ; Valor ajustável para o tempo de debounce
    ACALL timer
    LJMP fim

; Temporizador de contagem decrescente
timer:
    DJNZ R7, timer

fim:
    RET
