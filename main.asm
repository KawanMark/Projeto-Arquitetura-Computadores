    RS      equ     P1.3   
    EN      equ     P1.2    
	senha EQU 20h   ; Endereço para armazenar a senha
	input EQU 30h   ; Endereço para armazenar a tentativa de entrada

; Parte do codigo dedicada a armazenar as mensagens 
; de notificacao para o usuario
org 0400h
msg1:
	DB "Crie uma senha-"
	DB 0
msg2:
	DB "     Informe a senha-"
	DB 0
msg3:
	DB "    Senha incorreta!"
	DB 0
msg4:
	DB "     Senha correta!"
	DB 0
msg5:
	DB "Carro ligado!"
	DB 0
org 0000h
	LJMP START

; Sub-rotina para mapear as teclas do teclado
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

	ACALL criarSenha
	
	ACALL receberInput
	
	; o input do usuario com o a senha criada
	SJMP $

criarSenha:
	MOV A, #00h ; Escreve no LCD a notificacao de criar senha para o 
	CALL posicionaCursor ; usuario
	MOV DPTR, #msg1
	CALL escreveString
	CALL delay

	MOV A, #40h
	ACALL posicionaCursor 
    ACALL registrarSenha  ; Registra a senha inicial
    LJMP fim

receberInput:
	ACALL limparDisplay

	MOV A, #00h ; Notifica o usuario para informar a senha
	CALL posicionaCursor ; desbloquear a fechadura
	MOV DPTR, #msg2
	CALL escreveString

	MOV A, #40h
	ACALL posicionaCursor
	CALL registrarInput ; Registra o input

	ACALL verificarInput ; Parte dedicada para a verificacao se a senha informada esta 
	; esta correta
	JB F0, senhaIncorreta ; Se F0 estiver setado significa que a senha esta incorreta

	ACALL senhaCorreta ; Se nao, significa que a senha informada esta correta
	LJMP fim

; Sub-rotina responsavel por notificar que a senha informada
; esta incorreta e retorna para a sub-rotina de receber input
senhaIncorreta:
	ACALL limparDisplay
	
	CLR F0

	MOV A, #00h
	ACALL posicionaCursor

	MOV DPTR, #msg3
	CALL escreveString
	
	ACALL receberInput
	LJMP fim

; Informa ao usuario que a senha esta correta
senhaCorreta:
	ACALL limparDisplay
		
	MOV A, #00h
	CALL posicionaCursor

	MOV DPTR, #msg4
	CALL escreveString
	
	MOV A, #40h
	CALL posicionaCursor

	MOV DPTR, #msg5
	CALL escreveString

; Apos a execucao da sub-rotina de senha correta 
; a sub-rotina ligarMotor eh executada e permanece em execucao recursivamente 
ligarMotor:
	SETB P3.0
	CLR P3.1

	ACALL ligarMotor

; ------------------- Subrotinas do LCD -------------------;

; Sub-rotina responsavel por iniciar o funcionamento do LCD
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

	SETB P1.7
	SETB P1.6
	SETB P1.5
	SETB P1.4

	SETB EN
	CLR EN	

	CALL delay
	LJMP fim

;Limpa o display
limparDisplay:
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
	LJMP fim


; ------------------- Subrotinas para receber a senha ------------------;

; Sub-rotina utilizada para o usuario registrar a senha "mestra" da fechadura
registrarSenha:
    MOV B, #04h      ; Contador de 4 dígitos
    MOV R1, #senha   ; Ponteiro para o endereço da senha
    ACALL receber_loop  ; Chama a rotina para registrar a senha
    LJMP fim

; Sub-rotina utilizada para armazenar em um endereco separado o input do usuario
registrarInput:
    MOV B, #04h      ; Contador de 4 dígitos
    MOV R1, #input   ; Ponteiro para o endereço da tentativa de entrada
    ACALL receber_loop  ; Chama a rotina para registrar a entrada do usuário
    LJMP fim

; Sub-rotina auxiliar para receber qualquer input do usuario
receber_loop:
    ACALL lerTeclado     ; Chama a rotina para ler o teclado
    JNB F0, receber_loop ; Se não houver tecla pressionada, continua
    CLR F0               ; Limpa a flag de leitura de tecla
    MOV @R1, A           ; Armazena o valor da tecla no endereço apontado por R1
    INC R1               ; Avança para o próximo endereço
    DJNZ B, receber_loop ; Decrementa o contador e repete até 4 dígitos
    LJMP fim

; ------------------- Subrotinas ativar o alarme ------------------;
piscarP1_1:
    MOV R2, #5          ; Número de vezes que o LED irá piscar
piscar_loop_1:
    SETB P1.1           ; Liga o LED em P1.1
    ACALL delay
    CLR P1.1           ; Desliga o LED em P1.1
    ACALL delay
    DJNZ R2, piscar_loop_1 ; Repete o piscar 5 vezes
    LJMP fim

piscarLeds:
    MOV R2, #5          ; Número de vezes que os LEDs irão piscar
piscar_loop:
    SETB P1.0           ; Liga o LED
    ACALL delay
    CLR P1.0           ; Desliga o LED
    ACALL delay
    DJNZ R2, piscar_loop ; Repete o piscar 5 vezes
    LJMP fim

; ------------------- Subrotinas para envio de msgs para LCD ------------------;

; Sub-rotina utilizada por enviar um unico caractere que sera 
; projetado no LCD
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
	LJMP fim

; Sub-rotinas para realizar a escrita das mensagens para o usuario por meio do LCD
escreveString:
	MOV R2, #00h
rot:
	MOV A, R2
	MOVC A, @A+DPTR ; O acumulador recebe o valor presente no endereco somando com o valor de R2
	; fazendo a iteracao da string
	ACALL enviarCaractere
	INC R2 ; Aumenta o endereco 
	JNZ rot 
	LJMP fim

; ------------------- Subrotinas para posicionamentos do cursor ------------------;

; Sub-rotina que realiza o posicionamento do cursor onde sera escrito o 
; caractere no LCD
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
	LJMP fim


; ------------------- Subrotinas do teclado -------------------;

lerTeclado:
    MOV R0, #0          ; Limpa R0 - começa pela tecla 0
    MOV P0, #0FFh

    ; Varre linha 0
    CLR P0.0
    CALL verificarColuna
    JB F0, finish       ; Se tecla encontrada, sai

    ; Varre linha 1
    SETB P0.0
    CLR P0.1
    CALL verificarColuna
    JB F0, finish

    ; Varre linha 2
    SETB P0.1
    CLR P0.2
    CALL verificarColuna
    JB F0, finish

    ; Varre linha 3
    SETB P0.2
    CLR P0.3
    CALL verificarColuna
    JB F0, finish

finish:
    LJMP fim

verificarColuna:
    JNB P0.4, pegarChave
    INC R0
    JNB P0.5, pegarChave
    INC R0
    JNB P0.6, pegarChave
    INC R0
    LJMP fim

pegarChave:
    SETB F0 
	
	MOV A, #40h ; Informa a tecla digitada no LCD
	ADD A, R0
	MOV R0, A
	MOV A, @R0
	CALL enviarCaractere

	MOV A, R0            ; Indica tecla encontrada
    LJMP fim

; ------------------- Subrotinas para verificar a senha ------------------;

verificarInput:
	CLR F0
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
    DJNZ R2, senha_igual
    ACALL piscarP1_1  ; Continua verificando os próximos dígitos
    LJMP fim              ; Se todas as comparações forem iguais, a senha está correta


erro:
	SETB F0
    ; Se a senha estiver incorreta, aciona o alarme (pisca os LEDs)
    ACALL piscarLeds
    LJMP fim

; ------------------- Subrotinas auxiliares ------------------;

delay:
	MOV R7, #50
	DJNZ R7, $
	LJMP fim

fim:
	RET
