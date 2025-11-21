#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);
extern void LEDs_UpdateAngle(uint8_t angle_index);

extern volatile int stop_flag;

#define PORTE_DATA GPIO_PORTE_AHB_DATA_R
#define STEPS_FULL 2048
#define STEPS_HALF 4096

const uint8_t full_step[4] = {0x03, 0x06, 0x0C, 0x09}; 
const uint8_t half_step[8] = {0x01, 0x03, 0x02, 0x06, 0x04, 0x0C, 0x08, 0x09};
static uint8_t step_index = 0;

void Stepper_Step(uint8_t dir, uint8_t mode, uint32_t delay)
{
    uint8_t limit = (mode == 0) ? 4 : 8;
    
    if (dir == 0) { 
        step_index++; if (step_index >= limit) step_index = 0;
    } else { 
        if (step_index == 0) step_index = limit - 1; else step_index--;
    }

    uint8_t out = (mode == 0) ? full_step[step_index] : half_step[step_index];
    PORTE_DATA = (PORTE_DATA & 0xF0) | out;
    SysTick_Wait1ms(delay);
}

void Stepper_OneRound(uint8_t dir, uint8_t mode, uint32_t delay)
{
    int total_steps = (mode == 0) ? STEPS_FULL : STEPS_HALF;
    
    // Calcula passos para 45 graus
    int steps_45 = total_steps / 8;
    int current_led = 0;
    
    // Se sentido for anti-horário, inverte lógica do LED
    if (dir == 1) current_led = 7;

    for(int i = 0; i < total_steps; i++)
    {
        if (stop_flag) return;

        Stepper_Step(dir, mode, delay);

        // Atualiza LEDs a cada 45 graus
        if (i % steps_45 == 0) {
            LEDs_UpdateAngle(current_led);
            
            if (dir == 0) { // Horário: 0 -> 7
                current_led++;
                if (current_led > 7) current_led = 0;
            } else {        // Anti: 7 -> 0
                if (current_led == 0) current_led = 7;
                else current_led--;
            }
        }
    }
}