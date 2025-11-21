#include <stdint.h>
#include "tm4c1294ncpdt.h"

void LEDs_Write(uint8_t pattern)
{
    // PQ0-3
    GPIO_PORTQ_DATA_R = (GPIO_PORTQ_DATA_R & 0xF0) | (pattern & 0x0F);
    
    // PA4-7 (Bits 4-7 do pattern)
    GPIO_PORTA_AHB_DATA_R = (GPIO_PORTA_AHB_DATA_R & 0x0F) | (pattern & 0xF0);
}

void LEDs_UpdateAngle(uint8_t angle_index)
{
    // Garante índice 0-7
    angle_index &= 0x07; 
    uint8_t pattern = (1 << angle_index);
    LEDs_Write(pattern);
}