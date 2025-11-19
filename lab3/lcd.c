#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);

// Definições dos pinos de controle no Port M
#define LCD_RS  (1U << 0)  // PM0
#define LCD_RW  (1U << 1)  // PM1
#define LCD_E   (1U << 2)  // PM2

// Endereço mascarado para escrita segura em PM0, PM1, PM2
// Usaremos o array DATA_BITS definido no header para facilitar
#define LCD_CTRL_PORT GPIO_PORTM_DATA_BITS_R[0x07]

void LCD_PulseE(void)
{
    LCD_CTRL_PORT |= LCD_E;      // E = 1
    SysTick_Wait1ms(1);          // Pequeno delay
    LCD_CTRL_PORT &= ~LCD_E;     // E = 0
}

void LCD_Command(unsigned char command)
{
    // 1. Coloca o dado no barramento (Port K)
    GPIO_PORTK_DATA_R = command;
    
    // 2. Configura RS=0, RW=0 para comando
    LCD_CTRL_PORT = 0x00; 

    // 3. Pulsa Enable
    LCD_PulseE();
    
    // 4. Aguarda o comando processar
    SysTick_Wait1ms(2);
}

void LCD_WriteData(unsigned char data)
{
    // 1. Coloca o dado no barramento (Port K)
    GPIO_PORTK_DATA_R = data;
    
    // 2. Configura RS=1, RW=0 para dados
    LCD_CTRL_PORT = LCD_RS;

    // 3. Pulsa Enable
    LCD_PulseE();
    
    // 4. Aguarda a escrita
    SysTick_Wait1ms(2);
}

void LCD_Init(void)
{
    SysTick_Wait1ms(50);    // Espera inicialização elétrica
    
    LCD_Command(0x38);      // 8-bit, 2 linhas, 5x7 pontos
    LCD_Command(0x0C);      // Display ON, Cursor OFF, Blink OFF
    LCD_Command(0x06);      // Entry Mode: Incrementa cursor
    LCD_Command(0x01);      // Clear Display
    
    SysTick_Wait1ms(10);    // Espera limpar
}