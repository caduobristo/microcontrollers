        THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========================
; Registradores Gerais
; ========================
SYSCTL_RCGCGPIO_R   EQU 0x400FE608

; ========================
; Definições dos Ports (AHB)
; PORT K  (LCD D0..D7)
GPIO_PORTK_AHB_DIR_R    EQU 0x40061400
GPIO_PORTK_AHB_DEN_R    EQU 0x4006151C
GPIO_PORTK_AHB_AFSEL_R  EQU 0x40061420
GPIO_PORTK_AHB_AMSEL_R  EQU 0x40061528

; PORT M  (LCD RS, E)
GPIO_PORTM_AHB_DIR_R    EQU 0x40063400
GPIO_PORTM_AHB_DEN_R    EQU 0x4006351C
GPIO_PORTM_AHB_AFSEL_R  EQU 0x40063420
GPIO_PORTM_AHB_AMSEL_R  EQU 0x40063528

; Bits de clock
; bit 9 = Port K
; bit 11 = Port M

        EXPORT GPIO_Init

;--------------------------------------------------------------------------------
; GPIO_Init
; Configura:
;   Port K -> D0..D7 do LCD (saída digital)
;   Port M -> PM0 (RS), PM1 (RW=GND, não usado), PM2 (E) como saída
;--------------------------------------------------------------------------------
GPIO_Init
        ; habilita clock para K e M
        LDR R1, =SYSCTL_RCGCGPIO_R
        LDR R0, [R1]
        ORR R0, R0, #(1<<9)     ; Port K
        ORR R0, R0, #(1<<11)    ; Port M
        STR R0, [R1]
        NOP
        NOP

;----- PORT M: PM0 (RS), PM1 (RW=IGNORAR, ligado ao GND), PM2 (E)
        LDR R1, =GPIO_PORTM_AHB_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0x07          ; PM0–PM2 = saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTM_AHB_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0x07
        STR R0, [R1]

        ; AFSEL = 0
        LDR R1, =GPIO_PORTM_AHB_AFSEL_R
        MOV R0, #0x00
        STR R0, [R1]

        ; AMSEL = 0
        LDR R1, =GPIO_PORTM_AHB_AMSEL_R
        MOV R0, #0x00
        STR R0, [R1]

;----- PORT K: PK0–PK7 (dados D0..D7)
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

        BX LR

        ALIGN
        END
