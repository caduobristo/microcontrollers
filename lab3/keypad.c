#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);

// Coluna 3 (A,B,C,D) retorna 1,4,7,*
static const unsigned char key_map[4][4] = {
    {'1', '2', '3', '1'}, 
    {'4', '5', '6', '4'}, 
    {'7', '8', '9', '7'}, 
    {'*', '0', '#', '*'}  
};

unsigned char Keypad_GetKey(void)
{
    int row, col;
    GPIO_PORTL_DATA_R |= 0x0F;

    for (row = 0; row < 4; row++)
    {
        GPIO_PORTL_DATA_R = (GPIO_PORTL_DATA_R & 0xF0) | ((~(1U << row)) & 0x0F);
        for(volatile int i=0; i<200; i++);

        uint32_t cols = GPIO_PORTM_DATA_R & 0xF0;
        if (cols != 0xF0) 
        {
            SysTick_Wait1ms(2);
            if ((GPIO_PORTM_DATA_R & 0xF0) == cols) 
            {
                // Pula Coluna 0 (defeituosa)
                for (col = 1; col < 4; col++)
                {
                    if ((cols & (1U << (4 + col))) == 0)
                    {
                        GPIO_PORTL_DATA_R |= 0x0F; 
                        return key_map[row][col];
                    }
                }
            }
        }
        GPIO_PORTL_DATA_R |= 0x0F;
    }
    return 0; 
}