RS      equ     P1.3   
EN      equ     P1.2    
senha   EQU 20h   ; Endereço para armazenar a senha
input   EQU 30h   ; Endereço para armazenar a tentativa de entrada
msg1:
    DB "Crie uma senha"
    DB 0

msg2:
    DB "Informe a senha"
    DB 0

ORG 0000H
LJMP START

START:
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

MAIN:
    ACALL lcd_init

    MOV A, #00h
    CALL posicionaCursor
    MOV DPTR, #msg1
    CALL escreveString
    CALL delay
    
    ACALL iniciar

    MOV A, #00h
    CALL posicionaCursor
    MOV DPTR, #msg2
    CALL escreveString
    CALL registrarInput
	
    ACALL verificarInput
    SJMP $           ; Loop infinito para parar o programa

iniciar:
    ACALL registrarSenha  ; Registra a senha inicial
    RET

; ------------------- Subrotinas do LCD -------------------;
lcd_init:
    CLR RS		
    CLR P1.7
    CLR P1.6	
    SETB P1.5
    CLR P1.4
    SETB EN
    CLR EN	
    CALL delay
    SETB EN		
    CLR EN	
    SETB P1.7
    SETB EN
    CLR EN
    CALL delay
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
    CLR P1.7
    CLR P1.6
    CLR P1.5
    CLR P1.4
    SETB EN	
    CLR EN	
    CALL delay
    RET

; ------------------- Subrotinas ativar o LED P1.1 -------------------;
piscarP1_1:
    MOV R2, #5          ; Número de vezes que o LED irá piscar
piscar_loop_1:
    SETB P1.1           ; Liga o LED em P1.1
    ACALL delay
    CLR P1.1           ; Desliga o LED em P1.1
    ACALL delay
    DJNZ R2, piscar_loop_1 ; Repete o piscar 5 vezes
    RET

; Limpa o display
clearDisplay:
    CLR RS	
    CLR P1.7		
    CLR P1.6	
    CLR P1.5		
    CLR P1.4		
    SETB EN		
    CLR EN		
    CLR P1.7	
    CLR P1.6	
    CLR P1.5		
    SETB P1.4		
    SETB EN		
    CLR EN		
    CALL delay	
    RET

; ------------------- Subrotinas para receber a senha ------------------;

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
    MOV B, #04h          ; Reinicia o contador de dígitos
receber_loop:
    ACALL lerTeclado     ; Chama a rotina para ler o teclado
    JNB F0, receber_loop ; Se não houver tecla pressionada, continua
    CLR F0               ; Limpa a flag de leitura de tecla
    MOV @R1, A           ; Armazena o valor da tecla no endereço apontado por R1
    INC R1               ; Avança para o próximo endereço
    DJNZ B, receber_loop ; Decrementa o contador e repete até 4 dígitos
    RET

; ------------------- Subrotinas ativar o alarme ------------------;
piscarLeds:
    MOV R2, #5          ; Número de vezes que os LEDs irão piscar
piscar_loop:
    SETB P1.0           ; Liga o LED
    ACALL delay
    CLR P1.0           ; Desliga o LED
    ACALL delay
    DJNZ R2, piscar_loop ; Repete o piscar 5 vezes
    RET

; ------------------- Subrotinas para envio de msgs para LCD ------------------;

enviarCaractere:
    SETB RS  	
    MOV C, ACC.7	
    MOV P1.7, C		
    MOV C, ACC.6	
    MOV P1.6, C		
    MOV C, ACC.5	
    MOV P1.5, C		
    MOV C, ACC.4
    MOV P1.4, C			
    SETB EN		
    CLR EN			
    MOV C, ACC.3		
    MOV P1.7, C			
    MOV C, ACC.2		
    MOV P1.6, C			
    MOV C, ACC.1		
    MOV P1.5, C			
    MOV C, ACC.0	
    MOV P1.4, C			
    SETB EN
    CLR EN	
    CALL delay
    CALL delay
    RET

escreveString:
    MOV R2, #00h
rot:
    MOV A, R2
    MOVC A, @A+DPTR
    ACALL enviarCaractere
    INC R2
    JNZ rot
    RET

; ------------------- Subrotinas para posicionamentos do cursor ------------------;

posicionaCursor:
    CLR RS	
    SETB P1.7
    MOV C, ACC.6
    MOV P1.6, C
    MOV C, ACC.5
    MOV P1.5, C
    MOV C, ACC.4
    MOV P1.4, C
    SETB EN		
    CLR EN	
    MOV C, ACC.3
    MOV P1.7, C
    MOV C, ACC.2
    MOV P1.6, C
    MOV C, ACC.1
    MOV P1.5, C
    MOV C, ACC.0
    MOV P1.4, C	
    SETB EN
    CLR EN	
    CALL delay
    CALL delay
    RET

; ------------------- Subrotinas do teclado -------------------;

lerTeclado:
    MOV R0, #0          ; Limpa R0 - começa pela tecla 0
    MOV P0, #0FFh
    ; Varre linha 0
    CLR P0.0
    CALL lerColuna
    JB F0, finish       ; Se tecla encontrada, sai
    ; Varre linha 1
    SETB P0.0
    CLR P0.1
    CALL lerColuna
    JB F0, finish
    ; Varre linha 2
    SETB P0.1
    CLR P0.2
    CALL lerColuna
    JB F0, finish
    ; Varre linha 3
    SETB P0.2
    CLR P0.3
    CALL lerColuna
    JB F0, finish

finish:
    RET

lerColuna:
    JNB P0.4, pegarChave
    INC R0
    JNB P0.5, pegarChave
    INC R0
    JNB P0.6, pegarChave
    INC R0
    RET

pegarChave:
    SETB F0              ; Indica que uma tecla foi pressionada
    MOV A, R0            ; Carrega o valor da tecla
    RET

; ------------------- Subrotinas para verificar a senha ------------------;

verificarInput:
    MOV R0, #senha   ; Ponteiro para a senha armazenada
    MOV R1, #input   ; Ponteiro para a entrada do usuário
    MOV R2, #04h     ; Número de dígitos para comparar

senha_igual:
    MOV A, @R0       ; Carrega um dígito da senha
    MOV B, @R1       ; Carrega o dígito correspondente da entrada
    CJNE A, B, erro  ; Se forem diferentes, vai para a rotina de erro
    INC R0           ; Avança para o próximo dígito da senha
    INC R1           ; Avança para o próximo dígito da entrada
    DJNZ R2, senha_igual
    ACALL piscarP1_1  ; Chama a sub-rotina para piscar P1.1 se a senha estiver correta
    RET              ; Se todas as comparações forem iguais, a senha está correta

erro:
    ACALL piscarLeds  ; Chama a sub-rotina para piscar o LED em P1.0 se a senha estiver errada
    RET

delay:
    MOV R7, #50
    DJNZ R7, $  
    RET

fim:
    RET
