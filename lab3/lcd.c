#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);

#define LCD_RS  (1U << 0)
#define LCD_E   (1U << 2)
#define LCD_CTRL_PORT  GPIO_PORTM_DATA_BITS_R[0x07]

void LCD_PulseE(void) {
    LCD_CTRL_PORT |= LCD_E;
    SysTick_Wait1ms(1);
    LCD_CTRL_PORT &= ~LCD_E;
}

void LCD_Command(unsigned char command) {
    GPIO_PORTK_DATA_R = command;
    LCD_CTRL_PORT = 0x00;
    LCD_PulseE();
    SysTick_Wait1ms(2);
}

void LCD_WriteData(unsigned char data) {
    GPIO_PORTK_DATA_R = data;
    LCD_CTRL_PORT = LCD_RS;
    LCD_PulseE();
    SysTick_Wait1ms(2);
}

void LCD_Init(void) {
    SysTick_Wait1ms(50);
    LCD_Command(0x38);
    LCD_Command(0x0C);
    LCD_Command(0x06);
    LCD_Command(0x01);
    SysTick_Wait1ms(10);
}