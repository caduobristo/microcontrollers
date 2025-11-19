#include <stdint.h>
#include "tm4c1294ncpdt.h"

// Protótipos de funções externas
extern void PLL_Init(void);
extern void SysTick_Init(void);
void GPIO_Init(void);
void LCD_Init(void);
void LCD_WriteData(unsigned char data);
unsigned char Keypad_GetKey(void);

int main(void)
{
    unsigned char key;

    PLL_Init();         // Configura clock para 80MHz
    SysTick_Init();     // Inicializa SysTick
    GPIO_Init();        // Configura Portas K, L, M
    LCD_Init();         // Inicializa LCD

    while (1)
    {
        key = Keypad_GetKey(); // Verifica se alguma tecla foi pressionada
        
        if (key != 0)          // Se houve pressionamento (retorno != 0)
        {
            LCD_WriteData(key); // Envia o caractere para o LCD
        }
    }
}