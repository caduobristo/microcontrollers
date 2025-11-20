// main.c
// Teste do Motor de Passo em Port E (PE0-PE3)

#include <stdint.h>
#include "tm4c1294ncpdt.h"

// Protótipos
extern void PLL_Init(void);
extern void SysTick_Init(void);
extern void GPIO_Init(void);
void Stepper_CW(uint32_t delay_ms);
void Stepper_CCW(uint32_t delay_ms);

int main(void)
{
    // Inicialização
    PLL_Init();         // Clock 80MHz
    SysTick_Init();     // Timer
    GPIO_Init();        // Configura Port E como saída

    // Loop Infinito: Gira o motor
    while (1)
    {
        // Gira no sentido horário com 10ms de intervalo
        // Se o motor apenas vibrar, aumente este valor para 20 ou 50
        Stepper_CW(10); 
    }
}