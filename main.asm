ORG 0000H
SJMP MAIN 

senha EQU 20h
input EQU 30h
MAIN: 
    MOV P1, #00      ; Inicializa o LED
    ACALL iniciar     ; Chama a rotina para iniciar
    ACALL registrarInput
    MOV A, input      ; Carrega a entrada para verificação (apenas para teste)
    SJMP $

iniciar:
    ACALL mapearTeclas
    ACALL registrarSenha ; Chama a rotina para registrar a senha
    ; Aqui você pode verificar a senha digitada
    ; Para fins de exemplo, vamos simular uma senha incorreta
    ACALL piscarLeds ; Chama a rotina para piscar LEDs em caso de senha incorreta
    LJMP fim

mapearTeclas: 
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
    MOV B, #04h  ; Contador de quantos dígitos recebeu
    MOV R1, #senha ; Endereço onde vai registrar a senha
    ACALL receberSenha
    RET

registrarInput:
    MOV B, #04h
    MOV R1, #input
    ACALL receberSenha
    RET

receberSenha:
    MOV B, #04h          ; Reinicia o contador de dígitos
    MOV R1, #senha       ; Reinicia o ponteiro para a senha
receber_loop:
    ACALL lerTeclado     ; Chama a rotina para ler o teclado
    JNB F0, receber_loop ; Se não houver leitura, continua
    CLR F0               ; Limpa a flag
    MOV @R1, A          ; Armazena o valor lido no endereço apontado por R1
    INC R1               ; Incrementa o endereço para o próximo dígito
    DJNZ B, receber_loop ; Decrementa B e repete se não for zero
    RET

piscarLeds:
    MOV R2, #5          ; Número de vezes que os LEDs irão piscar
piscar_loop:
    SETB P1.0           
    ACALL delay
    CLR P1.0           
    ACALL delay
    DJNZ R2, piscar_loop 
    RET

pegarChave:
    SETB F0              ; Indica que uma tecla foi pressionada
    MOV A, R0           ; Carrega o valor da tecla
    RET

lerColuna:
    JNB P0.4, pegarChave ; Verifica se a tecla da coluna 1 foi pressionada
    INC R0
    JNB P0.5, pegarChave ; Verifica se a tecla da coluna 2 foi pressionada
    INC R0
    JNB P0.6, pegarChave ; Verifica se a tecla da coluna 3 foi pressionada
    INC R0
    RET

lerTeclado:
    MOV R0, #00         ; Inicializa R0 com 0 para capturar o valor da tecla
    MOV P0, #0FFH       ; Configura as portas P0 para alto
    CLR P0.0            ; Ativa a primeira coluna
    CALL lerColuna      ; Chama a leitura das colunas
    JB F0, fim          ; Se uma tecla foi lida, sai

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

verificarInput:
    MOV R0, #senha
    MOV R1, #input
    MOV R2, #04h

percorrerInput:
    MOV A, @R0
    MOV B, @R1
    CJNE A, B, piscarLeds ; Se diferentes, pisca LEDs
    INC R0
    INC R1
    DJNZ R2, percorrerInput
    RET

delay:
    MOV R7, #150  ; Valor ajustável para o tempo de debounce
    ACALL timer
    RET

timer:
    DJNZ R7, timer
    RET

fim:
    RET
