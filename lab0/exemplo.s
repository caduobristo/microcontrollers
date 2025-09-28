; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

RANDOM_ADR EQU 0x20000300
SORT_ADR   EQU 0x20000800
; -------------------------------------------------------------------------------
; Fun��o main()
Start  
; Comece o c�digo aqui <======================================================

		LDR R0, =RANDOM_LIST   ; lista de n�meros aleat�rios
		LDR R1, =RANDOM_ADR    ; endere�o de escrita da lista alet�ria
	
Copy
		LDRB R2, [R0], #1
		STRB R2, [R1], #1
		CMP R2, #0
		BNE Copy
	
		LDR R0, =RANDOM_ADR    ; endere�o de leitura da lista aleat�ria
        LDR R1, =SORT_ADR      ; ponteiro de escrita da lista de primos
        MOV R4, #0             ; contador do n�mero de primos encontrados

FindPrimes
        LDRB R2, [R0], #1      ; R2 = valor atual
        CMP R2, #0
        BEQ BubbleSort         ; R2 = 0 -> fim da lista

        CMP R2, #2
        BLT NotPrime           ; R2 < 2 n�o � primo
        CMP R2, #2
        BEQ IsPrime            ; 2 � primo

        MOV R5, #2             ; R5 = divisor -> come�a em 2

DivLoop
        CMP R5, R2
        BGE IsPrime            ; se R5 >= R2 ent�o nenhum divisor encontrado, portanto � primo

        UDIV R6, R2, R5        ; R6 = R2 / R5
        MLS  R7, R6, R5, R2    ; R7 = R2 - (R6 * R5) -> resto da divis�o
        CMP  R7, #0
        BEQ NotPrime           ; resto = 0 -> R2 divis�vel por R5 -> n�o primo

        ADD  R5, R5, #1
        B    DivLoop

IsPrime
        STRB R2, [R1], #1      ; grava primo na lista de primos
        ADD  R4, R4, #1        ; incrementa contador de primos
        B    FindPrimes

NotPrime
        B    FindPrimes
		
BubbleSort
    LDR R0, =SORT_ADR     ; ponteiro para lista de primos
	
OuterLoop
    MOV R6, #0            ; flag de troca (0 = sem troca)
    LDR R1, =SORT_ADR     ; reinicia ponteiro
	
InnerLoop
    LDRB R2, [R1]         ; carrega elemento atual
    LDRB R3, [R1, #1]     ; carrega pr�ximo elemento
    CMP R3, #0
    BEQ EndInner          ; se pr�ximo � 0 -> fim da lista

    CMP R2, R3
    BLE NoSwap            ; se R2 <= R3, n�o troca

    ; ---- troca R2 e R3 ----
    STRB R3, [R1]         ; grava menor no lugar atual
    STRB R2, [R1, #1]     ; grava maior no pr�ximo
    MOV R6, #1            ; marca que houve troca

NoSwap
    ADD R1, R1, #1        ; avan�a na lista
    B InnerLoop

EndInner
    CMP R6, #0
    BNE OuterLoop         ; se houve troca -> repetir la�o

Stop	; lista de primos criada e ordenada
        B       Stop
		
ALIGN  
		
RANDOM_LIST
	DCB		64, 33, 99, 24, 22, 93, 58, 50, 69, 62, 95, 28, 81, 86, 80, 54, 35, 40, 77, 96, 13, 51, 94, 97, 72, 44, 78, 15, 38, 34, 90, 8, 20, 70, 92, 2, 98, 75, 60, 49, 32, 6, 91, 39, 25, 56, 12, 21, 30, 84, 10, 42, 4, 88, 45, 46, 48, 18, 16, 65, 26, 36, 74, 66, 55, 9, 87, 68, 82, 76, 52, 14, 27, 63, 57, 0
	
	ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
