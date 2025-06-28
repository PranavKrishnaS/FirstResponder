// PIC16F877A Configuration Bit Settings
#pragma config FOSC = HS        
#pragma config WDTE = OFF       
#pragma config PWRTE = ON       
#pragma config BOREN = OFF      
#pragma config LVP = OFF        
#pragma config CPD = OFF        
#pragma config WRT = OFF        
#pragma config CP = OFF         

#include <xc.h>
#include <stdio.h>

#define _XTAL_FREQ 20000000  // 20MHz crystal oscillator

// ========== UART Functions ==========
void UART_Init() {
    TRISC6 = 0; // TX pin output
    TRISC7 = 1; // RX pin input

    SPBRG = 129; // Baud Rate 9600 for 20MHz
    BRGH = 1;    // High speed

    SYNC = 0;    // Asynchronous
    SPEN = 1;    // Enable serial port
    TXEN = 1;    // Enable transmission
}

void UART_TxChar(char ch) {
    while (!TXIF);
    TXREG = ch;
}

void UART_TxString(const char *str) {
    while (*str)
        UART_TxChar(*str++);
}

// ========== ADC Functions ==========
void ADC_Init() {
    ADCON0 = 0x41; // ADC ON, Channel 0 (AN0)
    ADCON1 = 0x80; // Right Justified, Fosc/32
}

unsigned int ADC_Read(unsigned char channel) {
    ADCON0 &= 0xC1;                // Clear current channel selection
    ADCON0 |= (channel << 3);      // Select ADC channel
    __delay_ms(2);                 // Acquisition time
    GO_nDONE = 1;                  // Start conversion
    while (GO_nDONE);              // Wait for conversion
    return ((ADRESH << 8) + ADRESL); // Return result


// ========== Main ==========
void main(void) {
    char buffer[40];
    unsigned int temp, pulse1, pressure, pulse2;

    UART_Init();
    ADC_Init();

    UART_TxString("BP Monitor Started\r\n");

    while (1) {
        temp = ADC_Read(0);      // RA0 - LM35
        pulse1 = ADC_Read(1);    // RA1 - Piezo
        pressure = ADC_Read(2);  // RA2 - Pressure
        pulse2 = ADC_Read(3);    // RA3 - PPG
        // Convert and print values
        sprintf(buffer, "T:%u PZ:%u PR:%u PPG:%u\r\n", temp, pulse1, pressure, pulse2);
        UART_TxString(buffer);

        __delay_ms(1000);
    }
}