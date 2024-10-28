    ORG 0200h          ; Armazena a string na memória de programa
string1:
    DB "Informe a senha ", 0  ; String com terminador nulo

    ORG 0000h          ; Início do programa principal
    LJMP MAIN          ; Pula para a rotina principal

; ----------------------- Definições ------------------------
senha  EQU 20h         ; Endereço para armazenar a senha
input  EQU 30h         ; Endereço para armazenar a tentativa de entrada
RS     EQU P1.3        ; RS conectado ao P1.3
EN     EQU P1.2        ; Enable conectado ao P1.2

; -------------------- Programa Principal -------------------
MAIN:
    MOV P1, #00H       ; Inicializa o LED apagado
    ACALL iniciar      ; Chama a rotina de iniciar (configura a senha)
    SJMP $             ; Loop infinito para encerrar o programa

; ------------------- Rotina de Inicialização ----------------
iniciar:
    ACALL ligarLcd         ; Inicializa o LCD
    MOV A, #00h            ; Posição inicial do cursor (linha 1, coluna 0)
    ACALL posicionaCursor  ; Posiciona o cursor
    ACALL exibirString1    ; Exibe a mensagem "Informe a senha"
    LJMP fim               ; Encaminha para o fim do programa

; -------------------- Inicialização do LCD ------------------
ligarLcd:
    CLR RS                 ; RS = 0, modo comando
    ; Envia comandos de configuração
    CLR P1.7               ; 8 bits: D7-D4
    CLR P1.6
    SETB P1.5
    CLR P1.4

    SETB EN                ; Gera pulso no Enable
    CLR EN
    CALL delay             ; Delay para estabilizar

    ; Repete pulso para garantir comunicação
    SETB EN
    CLR EN
    SETB P1.7              ; Envia comando extra
    SETB EN
    CLR EN
    CALL delay

    ; Configura LCD em 4 bits
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

    ; Finaliza inicialização
    LJMP fim

; ------------------ Exibição da String ----------------------
exibirString1:
    MOV DPTR, #string1   ; Aponta para a string armazenada
    ACALL exibirString   ; Chama a rotina para exibir a string
    LJMP fim             ; Encaminha para o fim

exibirString:
    CLR A                ; Limpa o acumulador A
loop_mensagem:
    MOVC A, @A+DPTR      ; Lê o próximo caractere da memória
    JZ fimMensagem       ; Se 0, fim da string
    ACALL enviarCaractere ; Envia caractere ao LCD
    INC DPTR             ; Avança para o próximo caractere
    SJMP loop_mensagem   ; Continua a exibição

fimMensagem:
    RET

; ------------------ Envio de Caractere ----------------------
enviarCaractere:
    SETB RS              ; RS = 1, modo dado
    MOV P1, A            ; Envia o caractere
    SETB EN              ; Gera pulso no Enable
    CLR EN
    LJMP fim

; ---------------- Posição do Cursor no LCD ------------------
posicionaCursor:
    CLR RS               ; Modo comando
    SETB P1.7            ; Configura bits do cursor
    MOV C, ACC.6
    MOV P1.6, C
    MOV C, ACC.5
    MOV P1.5, C
    MOV C, ACC.4
    MOV P1.4, C

    SETB EN              ; Gera pulso no Enable
    CLR EN
    CALL delay
    CALL delay
    ACALL fim

; -------------------- Retorno do Cursor ---------------------
retornaCursor:
    CLR RS               ; Retorna cursor ao início
    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    SETB EN
    CLR EN
    CALL delay
    ACALL fim

; -------------------- Limpar Display ------------------------
limparDisplay:
    CLR RS
    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    SETB EN
    CLR EN
    CALL delay
    ACALL fim

; ------------------ Delay e Timer ---------------------------
delay:
    MOV R7, #50
loop_delay:
    DJNZ R7, loop_delay
    RET

timer:
    DJNZ R7, timer
    LJMP fim

; ------------------- Mapeamento de Teclas -------------------
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
    LJMP fim

; -------------------- Captura de Senha ----------------------
registrarSenha:
    MOV B, #04h         ; 4 dígitos
    MOV R1, #senha      ; Ponteiro para a senha
    ACALL receberSenha  ; Chama rotina para capturar senha
    LJMP fim

receberSenha:
    MOV B, #04h
receber_loop:
    ACALL lerTeclado    ; Lê entrada do teclado
    JNB F0, receber_loop
    CLR F0
    MOV @R1, A
    INC R1
    DJNZ B, receber_loop
    LJMP fim

; ------------------ Piscar LEDs (Alarme) --------------------
piscarLeds:
    MOV R2, #5          ; Pisca 5 vezes
piscar_loop:
    SETB P1.0           ; Liga LED
    ACALL delay
    CLR P1.0            ; Desliga LED
    ACALL delay
    DJNZ R2, piscar_loop
    LJMP fim

; ------------------- Leitura de Teclado ---------------------
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
    LJMP fim

lerColuna:
    JNB P0.4, pegarChave
    INC R0
    JNB P0.5, pegarChave
    INC R0
    JNB P0.6, pegarChave
    INC R0
    LJMP fim

pegarChave:
    SETB F0
    MOV A, R0
    LJMP fim

; ------------------ Verificação da Senha --------------------
verificarInput:
    MOV R0, #senha
    MOV R1, #input
    MOV R2, #04h
senha_igual:
    MOV A, @R0
    MOV B, @R1
    CJNE A, B, erro
    INC R0
    INC R1
    DJNZ R2, senha_igual
    LJMP fim

erro:
    ACALL piscarLeds
    LJMP fim

; ------------------------ Fim -------------------------------
fim:
    RET
