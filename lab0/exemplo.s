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

		LDR R0, =RANDOM_LIST
		LDR R1, =RANDOM_ADR
	
Copy
		LDRB R2, [R0], #1
		STRB R2, [R1], #1
		CMP R2, #0
		BNE Copy
	
Stop
        B       Stop
		
ALIGN  
		
RANDOM_LIST
	DCB		64, 33, 99, 24, 22, 93, 58, 50, 69, 62, 95, 28, 81, 86, 80, 54, 35, 40, 77, 96, 13, 51, 94, 97, 72, 44, 78, 15, 38, 34, 90, 8, 20, 70, 92, 2, 98, 75, 60, 49, 32, 6, 91, 39, 25, 56, 12, 21, 30, 84, 10, 42, 4, 88, 45, 46, 48, 18, 16, 65, 26, 36, 74, 66, 55, 9, 87, 68, 82, 76, 52, 14, 27, 63, 57, 0
	
	ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
