		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

GPIO_PORTL_AHB_DATA_R   EQU 0x400623FC   ; PL0-PL3 (Linhas, Saída)
GPIO_PORTM_AHB_DATA_R   EQU 0x400633FC   ; PM4-PM7 (Colunas, Entrada)

        IMPORT SysTick_Wait1ms
        EXPORT Keypad_GetKey

; Coluna 3 (A,B,C,D) é usada como "backup" para a Coluna 0 (1,4,7,*).
KeyTable
        DCB "1", "2", "3", "1"   ; Row 0: 1, 2, 3, A->1
        DCB "4", "5", "6", "4"   ; Row 1: 4, 5, 6, B->4
        DCB "7", "8", "9", "7"   ; Row 2: 7, 8, 9, C->7
        DCB "*", "0", "#", "*"   ; Row 3: *, 0, #, D->*

; Keypad_Debounce
; Espera a tecla ser solta e aplica um delay
Keypad_Debounce
        PUSH {R0, R1, LR}
        
        ; Espera soltar a tecla (todas colunas PM4-PM7 devem ser 1)
WaitRelease
        LDR R1, =GPIO_PORTM_AHB_DATA_R
        LDR R0, [R1]
        AND R0, R0, #0xF0           ; Máscara das colunas
        CMP R0, #0xF0               ; Tudo em 1 (pull-up)?
        BNE WaitRelease             ; Não, continua esperando

        ; Delay de debounce (20ms)
        MOV R0, #20
        BL SysTick_Wait1ms
        
        POP {R0, R1, PC}

; Keypad_GetKey
; Retorna: R0 = caractere ASCII ou 0
Keypad_GetKey
        PUSH {R4-R7, LR}            ; Salva registradores usados
        
        LDR R5, =GPIO_PORTL_AHB_DATA_R   ; R5 = PortL (Linhas)
        LDR R6, =GPIO_PORTM_AHB_DATA_R   ; R6 = PortM (Colunas)
        MOV R4, #0                       ; R4 = índice da linha (0-3)

ScanRowLoop
        CMP R4, #4                       ; Já testou as 4 linhas?
        BHS NoKeyFound                   ; Sim, sai

        ; 1. ATIVA A LINHA
        MOV R0, #0x0F                    ; 0000 1111
        MOV R1, #1
        LSL R1, R4                       ; Bit da linha
        EOR R0, R0, R1                   ; Inverte esse bit (Active Low)
        STR R0, [R5]                     ; Escreve no Port L

        ; 2. DELAY DE ESTABILIZAÇÃO
        MOV R1, #200
DelayLoop
        SUBS R1, R1, #1
        BNE DelayLoop

        ; 3. LÊ AS COLUNAS
        LDR R0, [R6]
        AND R0, R0, #0xF0                ; Máscara PM4-PM7
        
        ; Verifica se algo foi pressionado
        CMP R0, #0xF0
        BEQ NextRow                      ; Se tudo 1, próxima linha

        ; Começamos do índice 1 para pular a Coluna 0 (PM4) que é defeituosa.
        MOV R7, #1                       ; R7 = índice da coluna (1 a 3)

ScanColLoop
        CMP R7, #4
        BHS NextRow                      ; Acabou as colunas válidas

        MOV R1, #1
        LSL R1, R7                       ; R1 = 1 << col
        LSL R1, #4                       ; Ajusta para posição PM (bits 4-7)
        TST R0, R1                       ; Testa se o bit está em 0
        BEQ KeyDetected                  ; Se for 0 (EQ), tecla encontrada!

        ADD R7, R7, #1
        B ScanColLoop

KeyDetected
        ; R4 = Linha, R7 = Coluna
        BL Keypad_Debounce               ; Espera soltar a tecla

        ; Calcula índice: R0 = (Row * 4) + Col
        LSL R0, R4, #2                   ; R0 = Row * 4
        ADD R0, R0, R7                   ; R0 = R0 + Col
        
        LDR R1, =KeyTable
        LDRB R0, [R1, R0]                ; Pega caractere da tabela
        B KeyFound

NextRow
        ADD R4, R4, #1
        B ScanRowLoop

NoKeyFound
        MOV R0, #0                       ; Nenhuma tecla
KeyFound
        POP {R4-R7, PC}

        ALIGN
        END