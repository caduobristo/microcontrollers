		THUMB
        AREA |.data|, DATA, READWRITE
        ; Variáveis em RAM
Sequence    SPACE 100       ; Vetor para armazenar até 100 números
MaxRound    DCD 0         ; Rodada atual (quantos números mostrar)
CurrentIdx  DCD 0         ; Índice sendo verificado na rodada atual

        AREA |.text|, CODE, READONLY, ALIGN=2

        EXPORT Start

        IMPORT PLL_Init
        IMPORT SysTick_Init
        IMPORT GPIO_Init
        IMPORT LCD_Init
        IMPORT LCD_Clear
        IMPORT LCD_SetCursor
        IMPORT LCD_PrintString
        IMPORT LCD_WriteData
        IMPORT LCD_Command
        IMPORT Keypad_GetKey
        IMPORT SysTick_Wait1ms
        IMPORT LEDs_Write

; Strings Constantes
Str_Intro1   DCB "Jogo da memória", 0
Str_Intro2   DCB "Aperte * p/ ini", 0
Str_Watch    DCB "Observe...", 0
Str_YourTurn DCB "Sua vez...", 0
Str_Win      DCB "Acertou!", 0
Str_Lose     DCB "Errou! Fim.", 0
Str_Win100   DCB "Parabéns", 0

        ALIGN ; Garante alinhamento de memória após as strings

; Endereço do SysTick para número aleatório
NVIC_ST_CURRENT_R EQU 0xE000E018

Start
        BL PLL_Init
        BL SysTick_Init
        BL GPIO_Init
        BL LCD_Init

ResetGame
        ; Inicializa variaveis
        LDR R0, =MaxRound
        MOV R1, #0
        STR R1, [R0]
        
        ; Desliga LEDs
        MOV R0, #0
        BL LEDs_Write

        BL LCD_Clear
        LDR R0, =Str_Intro1
        BL LCD_PrintString
        MOV R0, #1
        MOV R1, #0
        BL LCD_SetCursor
        LDR R0, =Str_Intro2
        BL LCD_PrintString

        ; Espera botão * para começar
WaitStart
        BL Keypad_GetKey
        CMP R0, #'*'
        BNE WaitStart

        BL LCD_Clear
        MOV R0, #500
        BL SysTick_Wait1ms

NewRound
        ; Incrementa rodada
        LDR R0, =MaxRound
        LDR R1, [R0]
        ADD R1, R1, #1
        STR R1, [R0]
        
        ; Verifica se chegou a 100
        CMP R1, #100
        BNE ContinueRound
        B   GameWin100
ContinueRound
        ; Geração de número aleatório
        SUB R2, R1, #1     ; Índice no vetor = Rodada - 1
        
        ; Pega valor atual do SysTick (pseudo-aleatório)
        LDR R3, =NVIC_ST_CURRENT_R
        LDR R0, [R3]
        
        ; Modulo 9 (números 1 a 9)
        MOV R3, #9
ModLoop
        CMP R0, R3
        BLO ModDone
        SUB R0, R0, R3
        B ModLoop
ModDone
        ADD R0, R0, #'1'   ; Converte para ASCII '1'..'9'
        
        ; Guarda no vetor Sequence[R2]
        LDR R3, =Sequence
        STRB R0, [R3, R2]

        ; Mostra mensagem "Observe..."
        BL LCD_Clear
        LDR R0, =Str_Watch
        BL LCD_PrintString
        MOV R0, #500
        BL SysTick_Wait1ms
        
        ; Loop para mostrar a sequencia acumulada
        LDR R4, =Sequence  ; Ponteiro vetor
        MOV R5, #0         ; Contador i

        LDR R0, =MaxRound
        LDR R6, [R0]       ; Limite do loop

LoopShow
        CMP R5, R6
        BGE EndShow

        BL LCD_Clear
        MOV R0, #0
        MOV R1, #7         ; Meio da tela
        BL LCD_SetCursor
        
        LDRB R0, [R4, R5]  ; Carrega numero da sequencia
        BL LCD_WriteData   ; Mostra no LCD
        
        ; Mostra nos LEDs também (converte ASCII para valor numérico)
        SUB R0, R0, #'0'
        BL LEDs_Write
        
        ; Delay visualização
        MOV R0, #1000      ; 1 segundo
        BL SysTick_Wait1ms
        
        ; Apaga para o proximo numero
        BL LCD_Clear
        MOV R0, #0
        BL LEDs_Write      ; Apaga LEDs
        MOV R0, #200       ; Breve pausa apagado
        BL SysTick_Wait1ms

        ADD R5, R5, #1
        B LoopShow

EndShow
        ; Fase do Jogador
        BL LCD_Clear
        LDR R0, =Str_YourTurn
        BL LCD_PrintString

        ; Posiciona cursor na linha de baixo (Linha 1, Coluna 0) para digitar
        MOV R0, #1
        MOV R1, #0
        BL LCD_SetCursor
        
        MOV R5, #0         ; Índice atual do jogador (reset)
        
InputLoop
        LDR R0, =MaxRound
        LDR R6, [R0]
        CMP R5, R6         ; Se acertou todos da rodada
        BGE RoundSuccess

        ; Espera tecla pressionada
WaitKey
        BL Keypad_GetKey
        CMP R0, #0
        BEQ WaitKey
        
        MOV R7, R0         ; Salva a tecla pressionada em R7
        
        ; Espera soltar (debounce)
WaitRelease
        BL Keypad_GetKey
        CMP R0, #0
        BNE WaitRelease
        
        ; --- VERIFICAÇÃO ---
        LDR R4, =Sequence
        LDRB R1, [R4, R5]  ; Carrega o valor correto da memória
        
        CMP R7, R1         ; Compara Tecla Pressionada (R7) com Memória (R1)
        BNE GameOver       ; Se diferente, perdeu
        
        MOV R0, R7         ; Restaura a tecla de R7 para R0
        BL LCD_WriteData
        
        ADD R5, R5, #1     ; Próximo índice
        B InputLoop

RoundSuccess
        ; Acertou a rodada inteira
        BL LCD_Clear
        LDR R0, =Str_Win
        BL LCD_PrintString
        
        ; Pisca LEDs indicando sucesso
        MOV R0, #0xFF
        BL LEDs_Write
        MOV R0, #500
        BL SysTick_Wait1ms
        MOV R0, #0
        BL LEDs_Write
        
        B NewRound         ; Vai para próxima rodada

GameOver
        ; Errou
        BL LCD_Clear
        LDR R0, =Str_Lose
        BL LCD_PrintString
        
        ; Pisca LEDs indicando erro
        MOV R4, #5
ErrorBlink
        MOV R0, #0xFF
        BL LEDs_Write
        MOV R0, #200
        BL SysTick_Wait1ms
        MOV R0, #0
        BL LEDs_Write
        MOV R0, #200
        BL SysTick_Wait1ms
        SUBS R4, R4, #1
        BNE ErrorBlink
        
        B ResetGame        ; Reinicia jogo do zero

GameWin100
        BL LCD_Clear
        LDR R0, =Str_Win100
        BL LCD_PrintString
        
        ; Loop infinito piscando feliz
WinLoop
        MOV R0, #0xAA
        BL LEDs_Write
        MOV R0, #200
        BL SysTick_Wait1ms
        MOV R0, #0x55
        BL LEDs_Write
        MOV R0, #200
        BL SysTick_Wait1ms
        B WinLoop

        ALIGN
        END