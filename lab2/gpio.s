		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========================
; Registradores Gerais
; ========================
SYSCTL_RCGCGPIO_R   EQU 0x400FE608

; ========================
; Definições dos Ports
; ========================

; PORT A (LEDs 5-8: PA4-PA7) - AHB
GPIO_PORTA_AHB_DIR_R    EQU 0x40058400
GPIO_PORTA_AHB_DEN_R    EQU 0x4005851C
GPIO_PORTA_AHB_AFSEL_R  EQU 0x40058420
GPIO_PORTA_AHB_AMSEL_R  EQU 0x40058528

; PORT Q (LEDs 1-4: PQ0-PQ3) - APB
GPIO_PORTQ_DIR_R        EQU 0x40066400
GPIO_PORTQ_DEN_R        EQU 0x4006651C
GPIO_PORTQ_AFSEL_R      EQU 0x40066420
GPIO_PORTQ_AMSEL_R      EQU 0x40066528

; PORT P (Habilitação LEDs: PP5) - APB
GPIO_PORTP_DIR_R        EQU 0x40065400
GPIO_PORTP_DEN_R        EQU 0x4006551C
GPIO_PORTP_AFSEL_R      EQU 0x40065420
GPIO_PORTP_AMSEL_R      EQU 0x40065528
GPIO_PORTP_DATA_R       EQU 0x400653FC ; Endereço de dados (todos os bits)

; PORT K (LCD D0..D7) - AHB
GPIO_PORTK_AHB_DIR_R    EQU 0x40061400
GPIO_PORTK_AHB_DEN_R    EQU 0x4006151C
GPIO_PORTK_AHB_AFSEL_R  EQU 0x40061420
GPIO_PORTK_AHB_AMSEL_R  EQU 0x40061528

; PORT L (Keypad Linhas PL0-PL3) - AHB
GPIO_PORTL_AHB_DIR_R    EQU 0x40062400
GPIO_PORTL_AHB_DEN_R    EQU 0x4006251C
GPIO_PORTL_AHB_AFSEL_R  EQU 0x40062420
GPIO_PORTL_AHB_AMSEL_R  EQU 0x40062528

; PORT M (LCD RS, E / Keypad Colunas PM4-PM7) - AHB
GPIO_PORTM_AHB_DIR_R    EQU 0x40063400
GPIO_PORTM_AHB_DEN_R    EQU 0x4006351C
GPIO_PORTM_AHB_AFSEL_R  EQU 0x40063420
GPIO_PORTM_AHB_PUR_R    EQU 0x40063510
GPIO_PORTM_AHB_AMSEL_R  EQU 0x40063528

        EXPORT GPIO_Init

;--------------------------------------------------------------------------------
; GPIO_Init: Inicializa Ports A, K, L, M, P, Q
;--------------------------------------------------------------------------------
GPIO_Init
        ; Habilita clock para A, K, L, M, P, Q
        ; Bit 0=A, 9=K, 10=L, 11=M, 13=P, 14=Q
        LDR R1, =SYSCTL_RCGCGPIO_R
        LDR R0, [R1]
        ORR R0, R0, #(1<<0)     ; Port A
        ORR R0, R0, #(1<<9)     ; Port K
        ORR R0, R0, #(1<<10)    ; Port L
        ORR R0, R0, #(1<<11)    ; Port M
        ORR R0, R0, #(1<<13)    ; Port P
        ORR R0, R0, #(1<<14)    ; Port Q
        STR R0, [R1]
        NOP
        NOP

        ; --- PORT P (Enable LEDs: PP5) ---
        ; Configura PP5 como saída e escreve 1 para ligar o transistor
        LDR R1, =GPIO_PORTP_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0x20          ; PP5 Saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTP_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0x20          ; PP5 Digital Enable
        STR R0, [R1]
        
        LDR R1, =GPIO_PORTP_AFSEL_R
        MOV R0, #0
        STR R0, [R1]
        LDR R1, =GPIO_PORTP_AMSEL_R
        STR R0, [R1]

        ; LIGA O TRANSISTOR DOS LEDS (PP5 = 1)
        LDR R1, =GPIO_PORTP_DATA_R
        LDR R0, [R1]
        ORR R0, R0, #0x20
        STR R0, [R1]

        ; --- PORT A (LEDs PA4-7) ---
        LDR R1, =GPIO_PORTA_AHB_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0xF0          ; PA4-7 Saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTA_AHB_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0xF0
        STR R0, [R1]
        
        LDR R1, =GPIO_PORTA_AHB_AFSEL_R
        MOV R0, #0
        STR R0, [R1]
        LDR R1, =GPIO_PORTA_AHB_AMSEL_R
        STR R0, [R1]

        ; --- PORT Q (LEDs PQ0-3) ---
        LDR R1, =GPIO_PORTQ_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0x0F          ; PQ0-3 Saída
        STR R0, [R1]

        LDR R1, =GPIO_PORTQ_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0x0F
        STR R0, [R1]

        LDR R1, =GPIO_PORTQ_AFSEL_R
        MOV R0, #0
        STR R0, [R1]
        LDR R1, =GPIO_PORTQ_AMSEL_R
        STR R0, [R1]

        ; --- PORT M (LCD/Keypad) ---
        LDR R1, =GPIO_PORTM_AHB_DIR_R
        LDR R0, [R1]
        ORR R0, R0, #0x07          ; PM0-2 Saída (LCD)
        BIC R0, R0, #0xF0          ; PM4-7 Entrada (Keypad)
        STR R0, [R1]

        LDR R1, =GPIO_PORTM_AHB_DEN_R
        LDR R0, [R1]
        ORR R0, R0, #0xF7
        STR R0, [R1]

        LDR R1, =GPIO_PORTM_AHB_PUR_R
        LDR R0, [R1]
        ORR R0, R0, #0xF0          ; Pull-up Keypad
        STR R0, [R1]
        
        LDR R1, =GPIO_PORTM_AHB_AFSEL_R
        MOV R0, #0
        STR R0, [R1]

        ; --- PORT K (LCD Dados) ---
        LDR R1, =GPIO_PORTK_AHB_DIR_R
        MOV R0, #0xFF              ; Tudo saída
        STR R0, [R1]
        LDR R1, =GPIO_PORTK_AHB_DEN_R
        STR R0, [R1]
        LDR R1, =GPIO_PORTK_AHB_AFSEL_R
        MOV R0, #0
        STR R0, [R1]

        ; --- PORT L (Keypad Linhas) ---
        LDR R1, =GPIO_PORTL_AHB_DIR_R
        MOV R0, #0x0F              ; PL0-3 Saída
        STR R0, [R1]
        LDR R1, =GPIO_PORTL_AHB_DEN_R
        STR R0, [R1]
        LDR R1, =GPIO_PORTL_AHB_AFSEL_R
        MOV R0, #0
        STR R0, [R1]

        BX LR

        ALIGN
        END