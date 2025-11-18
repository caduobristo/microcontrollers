		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========================
; Registradores Gerais
; ========================
SYSCTL_RCGCGPIO_R   EQU 0x400FE608

; ========================
; Definições dos Ports (AHB)

; PORT K (LCD D0..D7)
GPIO_PORTK_AHB_DIR_R    EQU 0x40061400
GPIO_PORTK_AHB_DEN_R    EQU 0x4006151C
GPIO_PORTK_AHB_AFSEL_R  EQU 0x40061420
GPIO_PORTK_AHB_AMSEL_R  EQU 0x40061528

; PORT L (Keypad Linhas PL0-PL3)
GPIO_PORTL_AHB_DIR_R    EQU 0x40062400
GPIO_PORTL_AHB_DEN_R    EQU 0x4006251C
GPIO_PORTL_AHB_AFSEL_R  EQU 0x40062420
GPIO_PORTL_AHB_AMSEL_R  EQU 0x40062528

; PORT M (LCD RS, E / Keypad Colunas PM4-PM7)
GPIO_PORTM_AHB_DIR_R    EQU 0x40063400
GPIO_PORTM_AHB_DEN_R    EQU 0x4006351C
GPIO_PORTM_AHB_AFSEL_R  EQU 0x40063420
GPIO_PORTM_AHB_PUR_R    EQU 0x40063510  ; Pull-Up
GPIO_PORTM_AHB_AMSEL_R  EQU 0x40063528

; Bits de clock
; bit 9 = Port K
; bit 10 = Port L
; bit 11 = Port M

        EXPORT GPIO_Init

;--------------------------------------------------------------------------------
; GPIO_Init
;--------------------------------------------------------------------------------
GPIO_Init
        ; habilita clock para K, L, M
        LDR R1, =SYSCTL_RCGCGPIO_R
        LDR R0, [R1]
        ORR R0, R0, #(1<<9)     ; Port K
        ORR R0, R0, #(1<<10)    ; Port L
        ORR R0, R0, #(1<<11)    ; Port M
        STR R0, [R1]
        NOP
        NOP

;----- PORT M: PM0-PM2 (LCD) | PM4-PM7 (Keypad)
        LDR R1, =GPIO_PORTM_AHB_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0x07          ; PM0, PM1, PM2 = saída (LCD)
        BIC R0, R0, #0xF0          ; PM4-PM7 = entrada (Keypad)
        STR R0, [R1]

        LDR R1, =GPIO_PORTM_AHB_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0xF7          ; Habilita PM0-PM2 (LCD) e PM4-PM7 (Keypad)
        STR R0, [R1]

        LDR R1, =GPIO_PORTM_AHB_PUR_R
        LDR R0, [R1]
        ORR R0, R0, #0xF0          ; Pull-up para PM4-PM7 (Keypad)
        STR R0, [R1]

        ; AFSEL = 0
        LDR R1, =GPIO_PORTM_AHB_AFSEL_R
        LDR R0, [R1]
        BIC R0, R0, #0xF7          ; Garante que pinos usados sao GPIO
        STR R0, [R1]

        ; AMSEL = 0
        LDR R1, =GPIO_PORTM_AHB_AMSEL_R
        LDR R0, [R1]
        BIC R0, R0, #0xF7
        STR R0, [R1]

;----- PORT K: PK0–PK7 (dados D0..D7 LCD)
        LDR R1, =GPIO_PORTK_AHB_DIR_R
        MOV R0, #0xFF              ; tudo saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTK_AHB_DEN_R
        MOV R0, #0xFF
        STR R0, [R1]

        ; AFSEL = 0
        LDR R1, =GPIO_PORTK_AHB_AFSEL_R
        MOV R0, #0x00
        STR R0, [R1]

        ; AMSEL = 0
        LDR R1, =GPIO_PORTK_AHB_AMSEL_R
        MOV R0, #0x00
        STR R0, [R1]

;----- PORT L: PL0–PL3 (Linhas Keypad)
        LDR R1, =GPIO_PORTL_AHB_DIR_R
        MOV R0, #0x0F              ; PL0-PL3 saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTL_AHB_DEN_R
        MOV R0, #0x0F
        STR R0, [R1]

        ; AFSEL = 0
        LDR R1, =GPIO_PORTL_AHB_AFSEL_R
        MOV R0, #0x00
        STR R0, [R1]

        ; AMSEL = 0
        LDR R1, =GPIO_PORTL_AHB_AMSEL_R
        MOV R0, #0x00
        STR R0, [R1]

        BX LR

        ALIGN
        END