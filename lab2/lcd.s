		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

GPIO_PORTM_AHB_BASE     EQU 0x40063000
GPIO_PORTK_AHB_DATA_R   EQU 0x400613FC   ; PK0..PK7
GPIO_PORTM_LCD_DATA_R   EQU 0x40063014   ; Mascara para PM0 e PM2

LCD_RS  EQU (1<<0)
LCD_E   EQU (1<<2)

        IMPORT SysTick_Wait1ms
        EXPORT LCD_Init
        EXPORT LCD_Command
        EXPORT LCD_WriteData
        EXPORT LCD_Clear
        EXPORT LCD_SetCursor
        EXPORT LCD_PrintString

LCD_PulseE
        PUSH {R0, R1, LR}
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        LDR R0, [R1]
        ORR R0, R0, #LCD_E
        STR R0, [R1]
        MOV R0, #1
        BL SysTick_Wait1ms          ; Delay pequeno
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        LDR R0, [R1]
        BIC R0, R0, #LCD_E
        STR R0, [R1]
        POP {R0, R1, PC}

LCD_Command
        PUSH {R0, R1, LR}
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        MOV R0, #0                  ; RS=0
        STR R0, [R1]
        BL LCD_PulseE
        MOV R0, #2
        BL SysTick_Wait1ms
        POP {R0, R1, PC}

LCD_WriteData
        PUSH {R0, R1, LR}
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        MOV R0, #LCD_RS             ; RS=1
        STR R0, [R1]
        BL LCD_PulseE
        MOV R0, #1                  ; Delay menor para dados
        BL SysTick_Wait1ms
        POP {R0, R1, PC}

LCD_Init
        PUSH {R0,LR}
        MOV R0, #50
        BL SysTick_Wait1ms
        MOV R0, #0x38     ; 8-bit, 2 linhas
        BL LCD_Command
        MOV R0, #0x0C     ; Display ON, cursor OFF
        BL LCD_Command
        MOV R0, #0x06     ; Entry mode
        BL LCD_Command
        BL LCD_Clear
        POP {R0,PC}

; Limpa a tela
LCD_Clear
        PUSH {R0, LR}
        MOV R0, #0x01
        BL LCD_Command
        MOV R0, #2        ; Comando Clear precisa de mais tempo
        BL SysTick_Wait1ms
        POP {R0, PC}

; Posiciona cursor. R0 = Linha (0 ou 1), R1 = Coluna
LCD_SetCursor
        PUSH {R0, R1, LR}
        CMP R0, #0
        BEQ SetLine0
        MOV R0, #0xC0     ; Endereço base Linha 1
        B AddCol
SetLine0
        MOV R0, #0x80     ; Endereço base Linha 0
AddCol
        ADD R0, R0, R1    ; Adiciona coluna
        BL LCD_Command
        POP {R0, R1, PC}

; Imprime string terminada em 0. R0 = Endereço da String
LCD_PrintString
        PUSH {R0, R1, LR}
        MOV R1, R0        ; R1 aponta para string
PrintLoop
        LDRB R0, [R1], #1 ; Carrega byte e incrementa ponteiro
        CMP R0, #0        ; Fim da string?
        BEQ PrintDone
        BL LCD_WriteData
        B PrintLoop
PrintDone
        POP {R0, R1, PC}

        END