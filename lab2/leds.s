		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

GPIO_PORTA_LEDS_R    EQU 0x400583C0
GPIO_PORTQ_LEDS_R    EQU 0x4006603C

        EXPORT LEDs_Write

LEDs_Write
        PUSH {R1, LR}

        ; Escreve em PQ0-PQ3 (Bits 0-3 do R0)
        LDR R1, =GPIO_PORTQ_LEDS_R
        STR R0, [R1]

        ; Escreve em PA4-PA7 (Bits 4-7 do R0)
        LDR R1, =GPIO_PORTA_LEDS_R
        STR R0, [R1]

        POP {R1, PC}

        ALIGN
        END