		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

; ========= REGISTRADORES =========
GPIO_PORTL_AHB_DATA_R   EQU 0x400623FC   ; PL0-PL3 (Linhas, Saída)
GPIO_PORTM_AHB_DATA_R   EQU 0x400633FC   ; PM4-PM7 (Colunas, Entrada)

        IMPORT SysTick_Wait1ms
        EXPORT Keypad_GetKey

KeyTable
        DCB "*", "0", "#", "D"
        DCB "1", "2", "3", "A"
        DCB "4", "5", "6", "B"
        DCB "7", "8", "9", "C"

; -----------------------------------------------------
; Keypad_Debounce
; Espera a tecla ser solta e aplica um delay
; -----------------------------------------------------
Keypad_Debounce
        PUSH {R0, R1, LR}
        
        ; Espera soltar a tecla
WaitRelease
        LDR R1, =GPIO_PORTM_AHB_DATA_R
        LDR R0, [R1]
        AND R0, R0, #0xF0           ; Mascara colunas
        CMP R0, #0xF0               ; Todas soltas (em pull-up)?
        BNE WaitRelease             ; Nao, continue esperando

        ; Delay de debounce
        MOV R0, #20                 ; 20ms
        BL SysTick_Wait1ms
        
        POP {R0, R1, PC}

; -----------------------------------------------------
; Keypad_GetKey
; Faz a varredura do teclado e retorna a tecla.
; Retorno: R0 = caractere ASCII (se pressionado)
;               0 (se nao pressionado)
; -----------------------------------------------------
Keypad_GetKey
        PUSH {R1-R7, LR}
        
        LDR R5, =GPIO_PORTL_AHB_DATA_R   ; R5 = PortL (Linhas)
        LDR R6, =GPIO_PORTM_AHB_DATA_R   ; R6 = PortM (Colunas)
        MOV R4, #0                      ; R4 = indice da linha (0-3)

ScanRowLoop
        CMP R4, #4                      ; Ja testou as 4 linhas?
        BHS NoKeyFound                  ; Sim, nenhuma tecla encontrada

        ; Ativa uma linha (joga para '0')
        MOV R0, #0x0F                   ; 0b00001111 (todas linhas altas)
        MOV R1, #1
        LSL R1, R4                      ; R1 = 1 << R4
        EOR R0, R0, R1                  ; Inverte o bit da linha atual
                                        ; (0b1110, 0b1101, 0b1011, 0b0111)
        STR R0, [R5]                    ; Escreve em PL0-PL3

        ; Lê as colunas
        LDR R0, [R6]
        AND R0, R0, #0xF0               ; Mascara PM4-PM7
        CMP R0, #0xF0                   ; Alguma coluna em '0'?
        BEQ NextRow                     ; Nao, proxima linha

        ; --- Tecla pressionada ---
        ; Descobrir qual coluna
        MOV R7, #0                      ; R7 = indice da coluna (0-3)
ScanColLoop
        CMP R7, #4
        BHS NextRow                     ; (Nao deve acontecer)

        MOV R1, #1
        LSL R1, R7                      ; R1 = 1 << R7
        LSL R1, #4                      ; R1 = 1 << (R7 + 4)
        TST R0, R1                      ; Testa o bit da coluna
        BNE NextCol                     ; Bit '1'? Nao eh essa, proxima

        ; --- Tecla encontrada ---
        ; Linha = R4, Coluna = R7
        BL Keypad_Debounce              ; Espera soltar

        ; Calcular indice da tabela: R0 = R4 * 4 + R7
        LSL R0, R4, #2                  ; R0 = R4 * 4
        ADD R0, R0, R7                  ; R0 = (R4 * 4) + R7
        
        LDR R1, =KeyTable
        LDRB R0, [R1, R0]               ; Carrega o byte (caractere)
        B KeyFound

NextCol
        ADD R7, R7, #1
        B ScanColLoop

NextRow
        ADD R4, R4, #1
        B ScanRowLoop

NoKeyFound
        MOV R0, #0                      ; Retorna 0
KeyFound
        POP {R1-R7, PC}

        ALIGN
        END