		THUMB
        AREA |.text|, CODE, READONLY, ALIGN=2

        EXPORT Start

        IMPORT PLL_Init
        IMPORT SysTick_Init
        IMPORT GPIO_Init
        IMPORT LCD_Init
        IMPORT LCD_WriteData
        IMPORT Keypad_GetKey 

; -------------------------------------------------------------------------------
; Função main()
; -------------------------------------------------------------------------------
Start
        BL PLL_Init
        BL SysTick_Init
        BL GPIO_Init
        BL LCD_Init

MainLoop
        BL Keypad_GetKey  
        CMP R0, #0            
        BEQ MainLoop
		
        BL LCD_WriteData
        B MainLoop

        ALIGN
        END