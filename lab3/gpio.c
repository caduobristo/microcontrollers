// gpio.c
#include <stdint.h>
#include "tm4c1294ncpdt.h"

#define GPIO_PORTE  (1U << 4)
#define GPIO_PORTK  (1U << 9)
#define GPIO_PORTL  (1U << 10)
#define GPIO_PORTM  (1U << 11)

void GPIO_Init(void)
{
    // Ativar clocks
    SYSCTL_RCGCGPIO_R |= (GPIO_PORTE | GPIO_PORTK | GPIO_PORTL | GPIO_PORTM);
    while((SYSCTL_PRGPIO_R & (GPIO_PORTE | GPIO_PORTK | GPIO_PORTL | GPIO_PORTM)) 
           != (GPIO_PORTE | GPIO_PORTK | GPIO_PORTL | GPIO_PORTM)) {};

    // PORT E (Motor) - AHB
    GPIO_PORTE_AHB_AMSEL_R &= ~0x0F;
    GPIO_PORTE_AHB_PCTL_R  &= ~0x0000FFFF;
    GPIO_PORTE_AHB_DIR_R   |= 0x0F;
    GPIO_PORTE_AHB_AFSEL_R &= ~0x0F;
    GPIO_PORTE_AHB_DEN_R   |= 0x0F;
    GPIO_PORTE_AHB_DATA_R  &= ~0x0F;

    // PORT M (LCD/Keypad) - APB (Sem AHB no nome)
    GPIO_PORTM_AMSEL_R = 0x00;
    GPIO_PORTM_PCTL_R  = 0x00;
    GPIO_PORTM_DIR_R   = 0x07; // PM0-2 Out, PM4-7 In
    GPIO_PORTM_PUR_R   = 0xF0; // Pull-up PM4-7
    GPIO_PORTM_DEN_R   = 0xF7;

    // PORT K (LCD Dados) - APB
    GPIO_PORTK_AMSEL_R = 0x00;
    GPIO_PORTK_PCTL_R  = 0x00;
    GPIO_PORTK_DIR_R   = 0xFF;
    GPIO_PORTK_DEN_R   = 0xFF;

    // PORT L (Keypad Rows) - APB
    GPIO_PORTL_AMSEL_R = 0x00;
    GPIO_PORTL_PCTL_R  = 0x00;
    GPIO_PORTL_DIR_R   = 0x0F;
    GPIO_PORTL_DEN_R   = 0x0F;
}