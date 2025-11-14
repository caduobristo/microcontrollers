        THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========= REGISTRADORES =========

GPIO_PORTM_AHB_DATA_R   EQU 0x400633FC   ; PM0 PM1 PM2
GPIO_PORTK_AHB_DATA_R   EQU 0x400613FC   ; PK0..PK7

LCD_RS  EQU (1<<0)      ; PM0
LCD_E   EQU (1<<2)      ; PM2   (RW = GND, então PM1 ignorado)

        IMPORT SysTick_Wait1ms
        EXPORT LCD_Init
        EXPORT LCD_Command
        EXPORT LCD_WriteData

; -----------------------------------------------------
LCD_PulseE
        PUSH {R0,R1}

        LDR R1, =GPIO_PORTM_AHB_DATA_R
        LDR R0, [R1]
        ORR R0, R0, #LCD_E
        STR R0, [R1]

        NOP
        NOP

        LDR R0, [R1]
        BIC R0, R0, #LCD_E
        STR R0, [R1]

        POP {R0,R1}
        BX LR

; -----------------------------------------------------
LCD_Command
        PUSH {R1-R3,LR}

        ; envia byte inteiro em PK0..PK7
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]

        ; RS=0
        LDR R1, =GPIO_PORTM_AHB_DATA_R
        LDR R3, [R1]
        BIC R3, R3, #LCD_RS
        STR R3, [R1]

        BL LCD_PulseE
        MOV R0, #2
        BL SysTick_Wait1ms

        POP {R1-R3,PC}

; -----------------------------------------------------
LCD_WriteData
        PUSH {R1-R3,LR}

        ; envia byte inteiro em PK0..PK7
        LDR R1, =GPIO_PORTK_AHB_DATA_R
        STR R0, [R1]

        ; RS=1
        LDR R1, =GPIO_PORTM_AHB_DATA_R
        LDR R3, [R1]
        ORR R3, R3, #LCD_RS
        STR R3, [R1]

        BL LCD_PulseE
        MOV R0, #2
        BL SysTick_Wait1ms

        POP {R1-R3,PC}

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
