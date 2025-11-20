// stepper.c
// Controle de Motor via Port E (PE0-PE3)
// Conexões: PE0->IN1, PE1->IN2, PE2->IN3, PE3->IN4

#include <stdint.h>
#include "tm4c1294ncpdt.h"

extern void SysTick_Wait1ms(uint32_t delay);

// Sequência de Passo Completo (Full Step)
const uint8_t step_sequence[4] = {0x03, 0x06, 0x0C, 0x09};
static uint8_t step_index = 0;

// Define o registrador de dados do Port E (AHB)
// Mascara os bits que não usamos? Aqui acessamos o registrador todo
// mas preservamos os bits superiores (4-7) na lógica abaixo.
#define PORTE_DATA  GPIO_PORTE_AHB_DATA_R

void Stepper_CW(uint32_t delay_ms)
{
    step_index++;
    if (step_index > 3) step_index = 0;

    // Lê o estado atual, limpa os 4 primeiros bits (PE0-PE3)
    // e escreve a nova sequência
    uint32_t current = PORTE_DATA & 0xF0; 
    PORTE_DATA = current | step_sequence[step_index];

    SysTick_Wait1ms(delay_ms);
}

void Stepper_CCW(uint32_t delay_ms)
{
    if (step_index == 0) step_index = 3;
    else step_index--;

    uint32_t current = PORTE_DATA & 0xF0;
    PORTE_DATA = current | step_sequence[step_index];

    SysTick_Wait1ms(delay_ms);
}