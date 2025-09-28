; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

RANDOM_ADR EQU 0x20000300
SORT_ADR   EQU 0x20000800
; -------------------------------------------------------------------------------
; Função main()
Start  
; Comece o código aqui <======================================================

		LDR R0, =RANDOM_LIST   ; lista de números aleatórios
		LDR R1, =RANDOM_ADR    ; endereço de escrita da lista aletória
	
Copy
		LDRB R2, [R0], #1
		STRB R2, [R1], #1
		CMP R2, #0
		BNE Copy
	
		LDR R0, =RANDOM_ADR    ; endereço de leitura da lista aleatória
        LDR R1, =SORT_ADR      ; ponteiro de escrita da lista de primos
        MOV R4, #0             ; contador do número de primos encontrados

FindPrimes
        LDRB R2, [R0], #1      ; R2 = valor atual
        CMP R2, #0
        BEQ BubbleSort         ; R2 = 0 -> fim da lista

        CMP R2, #2
        BLT NotPrime           ; R2 < 2 não é primo
        CMP R2, #2
        BEQ IsPrime            ; 2 é primo

        MOV R5, #2             ; R5 = divisor -> começa em 2

DivLoop
        CMP R5, R2
        BGE IsPrime            ; se R5 >= R2 então nenhum divisor encontrado, portanto é primo

        UDIV R6, R2, R5        ; R6 = R2 / R5
        MLS  R7, R6, R5, R2    ; R7 = R2 - (R6 * R5) -> resto da divisão
        CMP  R7, #0
        BEQ NotPrime           ; resto = 0 -> R2 divisível por R5 -> não primo

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
    LDRB R3, [R1, #1]     ; carrega próximo elemento
    CMP R3, #0
    BEQ EndInner          ; se próximo é 0 -> fim da lista

    CMP R2, R3
    BLE NoSwap            ; se R2 <= R3, não troca

    ; ---- troca R2 e R3 ----
    STRB R3, [R1]         ; grava menor no lugar atual
    STRB R2, [R1, #1]     ; grava maior no próximo
    MOV R6, #1            ; marca que houve troca

NoSwap
    ADD R1, R1, #1        ; avança na lista
    B InnerLoop

EndInner
    CMP R6, #0
    BNE OuterLoop         ; se houve troca -> repetir laço

Stop	; lista de primos criada e ordenada
        B       Stop
		
ALIGN  
		
RANDOM_LIST
	DCB		64, 33, 99, 24, 22, 93, 58, 50, 69, 62, 95, 28, 81, 86, 80, 54, 35, 40, 77, 96, 13, 51, 94, 97, 72, 44, 78, 15, 38, 34, 90, 8, 20, 70, 92, 2, 98, 75, 60, 49, 32, 6, 91, 39, 25, 56, 12, 21, 30, 84, 10, 42, 4, 88, 45, 46, 48, 18, 16, 65, 26, 36, 74, 66, 55, 9, 87, 68, 82, 76, 52, 14, 27, 63, 57, 0
	
	ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
