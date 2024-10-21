ORG 0000H
SJMP MAIN

senha EQU 20h   ; Endereço para armazenar a senha
input EQU 30h   ; Endereço para armazenar a tentativa de entrada

MAIN:
    MOV P1, #00      ; Inicializa o LED apagado
    ACALL iniciar    ; Chama a rotina de iniciar (registra a primeira senha)
    ACALL registrarInput  ; Captura a entrada do usuário para verificação
    ACALL verificarInput  ; Verifica se a senha está correta
    SJMP $           ; Loop infinito para parar o programa

iniciar:
    ACALL mapearTeclas
    ACALL registrarSenha  ; Registra a senha inicial
    RET

mapearTeclas:
    ; Mapeia as teclas para o teclado
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
    RET

registrarSenha:
    MOV B, #04h      ; Contador de 4 dígitos
    MOV R1, #senha   ; Ponteiro para o endereço da senha
    ACALL receberSenha  ; Chama a rotina para registrar a senha
    RET

registrarInput:
    MOV B, #04h      ; Contador de 4 dígitos
    MOV R1, #input   ; Ponteiro para o endereço da tentativa de entrada
    ACALL receberSenha  ; Chama a rotina para registrar a entrada do usuário
    RET

receberSenha:
    ; Rotina para capturar 4 dígitos de senha ou entrada
    MOV B, #04h          ; Reinicia o contador de dígitos
    MOV R1, #senha       ; Ponteiro para a senha
receber_loop:
    ACALL lerTeclado     ; Chama a rotina para ler o teclado
    JNB F0, receber_loop ; Se não houver tecla pressionada, continua
    CLR F0               ; Limpa a flag de leitura de tecla
    MOV @R1, A           ; Armazena o valor da tecla no endereço apontado por R1
    INC R1               ; Avança para o próximo endereço
    DJNZ B, receber_loop ; Decrementa o contador e repete até 4 dígitos
    RET

piscarLeds:
    MOV R2, #5          ; Número de vezes que os LEDs irão piscar
piscar_loop:
    SETB P1.0           ; Liga o LED
    ACALL delay
    CLR P1.0           ; Desliga o LED
    ACALL delay
    DJNZ R2, piscar_loop ; Repete o piscar 5 vezes
    RET

lerTeclado:
    MOV R0, #00         ; Inicializa R0 com 0 para capturar o valor da tecla
    MOV P0, #0FFH       ; Configura as portas P0 para alto
    CLR P0.0            ; Ativa a primeira coluna
    CALL lerColuna      ; Chama a leitura das colunas
    JB F0, fim          ; Se uma tecla foi lida, sai da rotina

    SETB P0.0           ; Desativa a primeira coluna
    CLR P0.1            ; Ativa a segunda coluna
    CALL lerColuna
    JB F0, fim

    SETB P0.1           ; Desativa a segunda coluna
    CLR P0.2            ; Ativa a terceira coluna
    CALL lerColuna
    JB F0, fim

    SETB P0.2           ; Desativa a terceira coluna
    CLR P0.3            ; Ativa a quarta coluna (se aplicável)
    CALL lerColuna
    JB F0, fim

    RET

lerColuna:
    JNB P0.4, pegarChave ; Verifica se a tecla da coluna 1 foi pressionada
    INC R0
    JNB P0.5, pegarChave ; Verifica se a tecla da coluna 2 foi pressionada
    INC R0
    JNB P0.6, pegarChave ; Verifica se a tecla da coluna 3 foi pressionada
    INC R0
    RET

pegarChave:
    SETB F0              ; Indica que uma tecla foi pressionada
    MOV A, R0            ; Carrega o valor da tecla
    RET

verificarInput:
    ; Comparar a senha com a entrada
    MOV R0, #senha   ; Ponteiro para a senha armazenada
    MOV R1, #input   ; Ponteiro para a entrada do usuário
    MOV R2, #04h     ; Número de dígitos para comparar

senha_igual:
    MOV A, @R0       ; Carrega um dígito da senha
    MOV B, @R1       ; Carrega o dígito correspondente da entrada
    CJNE A, B, erro  ; Se forem diferentes, vai para a rotina de erro
    INC R0           ; Avança para o próximo dígito da senha
    INC R1           ; Avança para o próximo dígito da entrada
    DJNZ R2, senha_igual  ; Continua verificando os próximos dígitos
    RET              ; Se todas as comparações forem iguais, a senha está correta

erro:
    ; Se a senha estiver incorreta, aciona o alarme (pisca os LEDs)
    ACALL piscarLeds
    RET

delay:
    MOV R7, #150     ; Tempo de atraso ajustável
    ACALL timer
    RET

timer:
    DJNZ R7, timer
    RET

fim:
    RET
