        THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

GPIO_PORTL_AHB_DATA_R   EQU 0x400623FC
GPIO_PORTM_AHB_DATA_R   EQU 0x400633FC

        EXPORT Keypad_Init
        EXPORT Keypad_GetKey

Keypad_Init
        BX LR

; =============================================================================
; Keypad_GetKey — varredura 4×4 com preservação do LCD
; =============================================================================
Keypad_GetKey
        PUSH {R1-R7,LR}

        LDR R6, =GPIO_PORTM_AHB_DATA_R   ; colunas
        LDR R7, =GPIO_PORTL_AHB_DATA_R   ; linhas

        MOV R1, #0    ; coluna 0–3

ScanColumn
        CMP R1, #4
        BEQ NoKey

        ; set all columns HIGH
        MOV R0, #0xF0
        LDR R3, [R6]
        AND R3, R3, #0x07
        ORR R0, R0, R3
        STR R0, [R6]

        ; lower single column
        MOV R0, #1
        ADD R2, R1, #4
        LSL R0, R0, R2     ; 1 << (col+4)
        MVN R0, R0
        AND R0, R0, #0xF0

        LDR R3, [R6]
        AND R3, R3, #0x07
        ORR R0, R0, R3
        STR R0, [R6]

        ; read rows
        LDR R2, [R7]
        AND R2, R2, #0x0F
        CMP R2, #0x0F
        BNE FoundRow

        ADD R1, R1, #1
        B ScanColumn

FoundRow
        MOV R3, #0

FindRow
        CMP R3, #4
        BEQ NoKey

        MOV R4, #1
        LSL R4, R4, R3
        AND R5, R2, R4
        BEQ RowOK

        ADD R3, R3, #1
        B FindRow

RowOK
        MOV R0, R3
        LSL R0, R0, #2
        ADD R0, R0, R1

        LDR R1, =KeyTable
        LDRB R0, [R1, R0]
        B Done

NoKey
        MOV R0, #0

Done
        POP {R1-R7,PC}

KeyTable
        DCB '1','2','3','A'
        DCB '4','5','6','B'
        DCB '7','8','9','C'
        DCB '*','0','#','D'

        END
