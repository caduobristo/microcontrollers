#include <stdint.h>
#include "tm4c1294ncpdt.h"

// Definições de bits para facilitar leitura
#define GPIO_PORTK  (1U << 9)
#define GPIO_PORTL  (1U << 10)
#define GPIO_PORTM  (1U << 11)

void GPIO_Init(void)
{
    // Ativar o clock para as portas K, L, M
    SYSCTL_RCGCGPIO_R |= (GPIO_PORTK | GPIO_PORTL | GPIO_PORTM);
    
    // Esperar as portas ficarem prontas
    while((SYSCTL_PRGPIO_R & (GPIO_PORTK | GPIO_PORTL | GPIO_PORTM)) != (GPIO_PORTK | GPIO_PORTL | GPIO_PORTM)){};

    // --- Configuração do Port M (LCD Control + Keypad Cols) ---
    // PM0 (RS), PM1 (RW), PM2 (E) -> Saídas
    // PM4-PM7 (Keypad Cols) -> Entradas
    
    GPIO_PORTM_AMSEL_R = 0x00;      // Desabilita analógico
    GPIO_PORTM_PCTL_R  = 0x00;      // GPIO normal
    
    // Direção: PM0, PM1, PM2 = Saída (1); PM4-PM7 = Entrada (0)
    // 0x07 = 0000 0111
    GPIO_PORTM_DIR_R = 0x07; 
    
    // Habilita Pull-Up nas colunas (PM4-PM7)
    // 0xF0 = 1111 0000
    GPIO_PORTM_PUR_R = 0xF0;
    
    // Habilita função digital em PM0-PM2 e PM4-PM7
    // 0xF7 = 1111 0111
    GPIO_PORTM_DEN_R = 0xF7;

    // --- Configuração do Port K (LCD Data D0-D7) ---
    GPIO_PORTK_AMSEL_R = 0x00;
    GPIO_PORTK_PCTL_R  = 0x00;
    GPIO_PORTK_DIR_R   = 0xFF;      // Todos saídas (D0-D7)
    GPIO_PORTK_DEN_R   = 0xFF;      // Habilita digital

    // --- Configuração do Port L (Keypad Rows PL0-PL3) ---
    GPIO_PORTL_AMSEL_R = 0x00;
    GPIO_PORTL_PCTL_R  = 0x00;
    GPIO_PORTL_DIR_R   = 0x0F;      // PL0-PL3 saídas
    GPIO_PORTL_DEN_R   = 0x0F;      // Habilita digital
}