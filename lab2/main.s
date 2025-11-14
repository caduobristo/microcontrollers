; Programa mínimo: inicializa clock, SysTick, GPIO, LCD
; e escreve "HI" na primeira linha

        THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

        EXPORT Start

        IMPORT PLL_Init
        IMPORT SysTick_Init
        IMPORT GPIO_Init
        IMPORT LCD_Init
        IMPORT LCD_WriteData

; -------------------------------------------------------------------------------
; Função main()
; -------------------------------------------------------------------------------
Start
        BL PLL_Init
        BL SysTick_Init
        BL GPIO_Init
        BL LCD_Init

        MOV R0, #'H'
        BL LCD_WriteData
        MOV R0, #'I'
        BL LCD_WriteData

MainLoop
        B MainLoop

        ALIGN
        END
