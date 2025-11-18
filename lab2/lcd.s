		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========= REGISTRADORES =========

; Endereço base do Port M
GPIO_PORTM_AHB_BASE     EQU 0x40063000

; Endereço de dados do Port K (D0-D7)
GPIO_PORTK_AHB_DATA_R   EQU 0x400613FC   ; PK0..PK7

; Endereços mascarados para Port M
; Queremos controlar PM0 (RS) e PM2 (E). Máscara = (1<<0) | (1<<2) = 0x05
; O offset do endereço é a máscara << 2
; Offset = 0x05 << 2 = 0x14
GPIO_PORTM_LCD_DATA_R   EQU 0x40063014  ; (0x40063000 + 0x14)

LCD_RS  EQU (1<<0)      ; PM0
LCD_E   EQU (1<<2)      ; PM2   (RW = GND, então PM1 ignorado)

        IMPORT SysTick_Wait1ms
        EXPORT LCD_Init
        EXPORT LCD_Command
        EXPORT LCD_WriteData

; -----------------------------------------------------
LCD_PulseE
        PUSH {R0, R1}
        LDR R1, =GPIO_PORTM_LCD_DATA_R  ; Endereço mascarado (PM0, PM2)

        ; Lê o estado ATUAL (apenas de PM0 e PM2)
        LDR R0, [R1]
        
        ; Seta E (mantendo RS)
        ORR R0, R0, #LCD_E
        STR R0, [R1]

        NOP
        NOP

        ; Limpa E (mantendo RS)
        BIC R0, R0, #LCD_E
        STR R0, [R1]

        POP {R0, R1}
        BX LR

; -----------------------------------------------------
LCD_Command
        PUSH {R0, R1, LR} ; Salva R0 também

        ; envia byte inteiro em PK0..PK7
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]

        ; RS=0 (apenas em PM0 e PM2)
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        MOV R0, #0                      ; RS=0, E=0
        STR R0, [R1]                    ; Escreve 0 em PM0 e PM2

        BL LCD_PulseE
        MOV R0, #2
        BL SysTick_Wait1ms

        POP {R0, R1, PC}

; -----------------------------------------------------
LCD_WriteData
        PUSH {R0, R1, LR} ; Salva R0 também

        ; envia byte inteiro em PK0..PK7
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]                    ; R0 aqui é o caractere

        ; RS=1 (apenas em PM0 e PM2)
        LDR R1, =GPIO_PORTM_LCD_DATA_R
        MOV R0, #LCD_RS                 ; RS=1, E=0
        STR R0, [R1]                    ; Escreve 1 em PM0, 0 em PM2

        BL LCD_PulseE
        MOV R0, #2
        BL SysTick_Wait1ms

        POP {R0, R1, PC}

; -----------------------------------------------------
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

        MOV R0, #0x01     ; Clear
        BL LCD_Command

        MOV R0, #3
        BL SysTick_Wait1ms

        POP {R0,PC}
        END