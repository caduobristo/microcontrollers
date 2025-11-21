// Configuração de Portas: E(Motor), K/L/M(LCD/Keypad), A/Q/P(LEDs), J(Botão)

#include <stdint.h>
#include "tm4c1294ncpdt.h"

// Definições de bits
#define GPIO_PORTA  (1U << 0)
#define GPIO_PORTE  (1U << 4)
#define GPIO_PORTJ  (1U << 8)
#define GPIO_PORTK  (1U << 9)
#define GPIO_PORTL  (1U << 10)
#define GPIO_PORTM  (1U << 11)
#define GPIO_PORTP  (1U << 13)
#define GPIO_PORTQ  (1U << 14)

void GPIO_Init(void)
{
    // Ativar clocks
    SYSCTL_RCGCGPIO_R |= (GPIO_PORTA | GPIO_PORTE | GPIO_PORTJ | 
                          GPIO_PORTK | GPIO_PORTL | GPIO_PORTM | 
                          GPIO_PORTP | GPIO_PORTQ);
    
    // Esperar pronto
    while((SYSCTL_PRGPIO_R & (GPIO_PORTA | GPIO_PORTE | GPIO_PORTJ |
                              GPIO_PORTK | GPIO_PORTL | GPIO_PORTM |
                              GPIO_PORTP | GPIO_PORTQ)) == 0) {};

    // --- PORT A (LEDs 5-8: PA4-PA7) [AHB] ---
    GPIO_PORTA_AHB_AMSEL_R &= ~0xF0;
    GPIO_PORTA_AHB_PCTL_R  &= ~0xFFFF0000;
    GPIO_PORTA_AHB_DIR_R   |= 0xF0;  // Saída
    GPIO_PORTA_AHB_AFSEL_R &= ~0xF0;
    GPIO_PORTA_AHB_DEN_R   |= 0xF0;
    GPIO_PORTA_AHB_DATA_R  &= ~0xF0; // Apagados

    // --- PORT Q (LEDs 1-4: PQ0-PQ3) [APB] ---
    GPIO_PORTQ_AMSEL_R &= ~0x0F;
    GPIO_PORTQ_PCTL_R  &= ~0x0000FFFF;
    GPIO_PORTQ_DIR_R   |= 0x0F;      // Saída
    GPIO_PORTQ_AFSEL_R &= ~0x0F;
    GPIO_PORTQ_DEN_R   |= 0x0F;
    GPIO_PORTQ_DATA_R  &= ~0x0F;     // Apagados

    // --- PORT P (Enable LEDs: PP5) [APB] ---
    GPIO_PORTP_AMSEL_R &= ~0x20;
    GPIO_PORTP_PCTL_R  &= ~0x00F00000;
    GPIO_PORTP_DIR_R   |= 0x20;      // Saída
    GPIO_PORTP_AFSEL_R &= ~0x20;
    GPIO_PORTP_DEN_R   |= 0x20;
    GPIO_PORTP_DATA_R  |= 0x20;      // Liga Transistor Q1

    // --- PORT J (Botão USR_SW1: PJ0) [AHB] ---
    GPIO_PORTJ_AHB_AMSEL_R &= ~0x01;
    GPIO_PORTJ_AHB_PCTL_R  &= ~0x0000000F;
    GPIO_PORTJ_AHB_DIR_R   &= ~0x01; // Entrada
    GPIO_PORTJ_AHB_AFSEL_R &= ~0x01;
    GPIO_PORTJ_AHB_DEN_R   |= 0x01;
    GPIO_PORTJ_AHB_PUR_R   |= 0x01;  // Pull-up

    // Interrupção PJ0
    GPIO_PORTJ_AHB_IM_R    &= ~0x01;
    GPIO_PORTJ_AHB_IS_R    &= ~0x01; // Borda
    GPIO_PORTJ_AHB_IBE_R   &= ~0x01; // Única
    GPIO_PORTJ_AHB_IEV_R   &= ~0x01; // Descida
    GPIO_PORTJ_AHB_ICR_R   |= 0x01;  // Limpa flag
    GPIO_PORTJ_AHB_IM_R    |= 0x01;  // Habilita
    
    // NVIC #51 (Port J) -> Bit 19 do EN1
    NVIC_EN1_R = (1 << 19);

    // --- PORT E (Motor) [AHB] ---
    GPIO_PORTE_AHB_AMSEL_R &= ~0x0F;
    GPIO_PORTE_AHB_PCTL_R  &= ~0x0000FFFF;
    GPIO_PORTE_AHB_DIR_R   |= 0x0F;
    GPIO_PORTE_AHB_AFSEL_R &= ~0x0F;
    GPIO_PORTE_AHB_DEN_R   |= 0x0F;
    GPIO_PORTE_AHB_DATA_R  &= ~0x0F;

    // --- PORT M (LCD/Keypad) [APB] ---
    GPIO_PORTM_AMSEL_R = 0x00;
    GPIO_PORTM_PCTL_R  = 0x00;
    GPIO_PORTM_DIR_R   = 0x07; 
    GPIO_PORTM_PUR_R   = 0xF0; 
    GPIO_PORTM_DEN_R   = 0xF7;

    // --- PORT K (LCD Dados) [APB] ---
    GPIO_PORTK_AMSEL_R = 0x00;
    GPIO_PORTK_PCTL_R  = 0x00;
    GPIO_PORTK_DIR_R   = 0xFF;
    GPIO_PORTK_DEN_R   = 0xFF;

    // --- PORT L (Keypad Rows) [APB] ---
    GPIO_PORTL_AMSEL_R = 0x00;
    GPIO_PORTL_PCTL_R  = 0x00;
    GPIO_PORTL_DIR_R   = 0x0F;
    GPIO_PORTL_DEN_R   = 0x0F;
}