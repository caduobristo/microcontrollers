#include <stdint.h>
#include "tm4c1294ncpdt.h"

// Protótipos
extern void PLL_Init(void);
extern void SysTick_Init(void);
void GPIO_Init(void);
void LCD_Init(void);
void LCD_WriteData(unsigned char data);
void LCD_Command(unsigned char command);
unsigned char Keypad_GetKey(void);
void Stepper_OneRound(uint8_t dir, uint8_t mode, uint32_t delay);
void LEDs_Write(uint8_t pattern);
extern void SysTick_Wait1ms(uint32_t delay);
extern void EnableInterrupts(void);

volatile int stop_flag = 0;

// Interrupção do Port J
void GPIOPortJ_Handler(void)
{
    if (GPIO_PORTJ_AHB_RIS_R & 0x01) {
        GPIO_PORTJ_AHB_ICR_R = 0x01; // Limpa flag
        stop_flag = 1;               // Solicita parada
    }
}

// Funções LCD
void LCD_Clear(void) { LCD_Command(0x01); SysTick_Wait1ms(2); }
void LCD_SetCursor(uint8_t line, uint8_t col) { LCD_Command((line==0?0x80:0xC0)+col); }
void LCD_Print(char *str) { while(*str) LCD_WriteData(*str++); }
void LCD_PrintInt(int val) { LCD_WriteData((val/10)+'0'); LCD_WriteData((val%10)+'0'); }

// Espera Tecla
unsigned char Wait_Key_Press(void) {
    unsigned char key = 0;
    do { key = Keypad_GetKey(); } while (key == 0);
    while (Keypad_GetKey() != 0) { SysTick_Wait1ms(10); }
    return key;
}

int voltas = 0;
uint8_t sentido = 0; 
uint8_t modo = 0;   

int main(void)
{
    unsigned char k;
    PLL_Init(); SysTick_Init(); GPIO_Init(); LCD_Init();
    EnableInterrupts(); // Habilita interrupções (SW1)

    while (1) 
    {
        stop_flag = 0;
        LEDs_Write(0x00);

        // === PASSO 1: Voltas ===
        LCD_Clear();
        LCD_Print("Voltas (1-9):"); 
        LCD_SetCursor(1, 0);
        
        do { k = Wait_Key_Press(); } while (k < '1' || k > '9');
        voltas = k - '0';
        LCD_WriteData(k); SysTick_Wait1ms(500); 

        // === PASSO 2: Sentido ===
        LCD_Clear();
        LCD_Print("1:HORA    2:ANTI");
        
        do { k = Wait_Key_Press(); } while (k != '1' && k != '2');
        if (k == '1') sentido = 0;
        else          sentido = 1;

        // === PASSO 3: Modo ===
        LCD_Clear();
        LCD_Print("1:FULL    2:HALF");
        
        do { k = Wait_Key_Press(); } while (k != '1' && k != '2');
        if (k == '1') modo = 0;
        else          modo = 1;

        // === PASSO 4: Execução ===
        LCD_Clear();
        LCD_SetCursor(0, 0); LCD_Print(sentido ? "ANTI-" : "HORA-");
        LCD_SetCursor(0, 5); LCD_Print(modo ? "FULL" : "HALF");

        // Loop de Voltas
        while (voltas > 0 && stop_flag == 0)
        {
            LCD_SetCursor(1, 0);
            LCD_Print("RESTAM: "); LCD_PrintInt(voltas);
            
            Stepper_OneRound(sentido, modo, (modo==0 ? 5 : 3));
            voltas--;
        }
        
        // Desliga Motor
        GPIO_PORTE_AHB_DATA_R &= ~0x0F;
        LEDs_Write(0x00);

        LCD_SetCursor(1, 0);
        LCD_Print("Restam: 00 ");

        // === FIM ===
        LCD_Clear();
        
        if (stop_flag) {
            LCD_Print("   CANCELADO!");
        } else {
            LCD_Print("      FIM!");
        }

        LCD_SetCursor(1, 0);
        LCD_Print(" * P/ REINICIAR");

        do { k = Wait_Key_Press(); } while (k != '*');
    }
}