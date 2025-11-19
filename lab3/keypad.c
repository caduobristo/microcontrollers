#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);

static const unsigned char key_map[4][4] = {
	  {'1', '2', '3', 'A'}, // Linha 1 (PL0)
    {'4', '5', '6', 'B'}, // Linha 2 (PL1)
    {'7', '8', '9', 'C'}, // Linha 3 (PL2)
		{'*', '0', '#', 'D'}  // Linha 4 (PL3)
};

// Função auxiliar para debounce
void Keypad_Debounce(void)
{
    // Espera soltar todas as teclas (todas colunas PM4-PM7 devem ser 1)
    // Máscara 0xF0 verifica bits 4,5,6,7.
    while ((GPIO_PORTM_DATA_R & 0xF0) != 0xF0) {}; 
    
    SysTick_Wait1ms(20); // Delay de 20ms
}

unsigned char Keypad_GetKey(void)
{
    int row, col;
    
    // Varre as 4 linhas
    for (row = 0; row < 4; row++)
    {
        // 1. Ativa a linha atual (LOW) e desativa as outras (HIGH)
        GPIO_PORTL_DATA_R = (~(1U << row)) & 0x0F;
        
        // Pequeno delay para estabilização do sinal
        for(volatile int i=0; i<100; i++);

        // 2. Lê as colunas (PM4-PM7)
        uint32_t cols = GPIO_PORTM_DATA_R & 0xF0;
        
        if (cols != 0xF0) // Alguma tecla pressionada nesta linha
        {
            // Descobre qual coluna está em 0
            for (col = 0; col < 4; col++)
            {
                // Verifica se o bit da coluna (4+col) está em 0
                if ((cols & (1U << (4 + col))) == 0)
                {
                    Keypad_Debounce(); // Espera soltar e debounce
                    return key_map[row][col];
                }
            }
        }
    }
    
    return 0; // Nenhuma tecla pressionada
}