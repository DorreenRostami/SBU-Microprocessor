#include <stm32f4xx.h>

#define RS 0x01     /* pin 0 = reg select */
#define RW 0x02     /* Pin 1 = read/write */
#define EN 0x04     /* Pin 2 = enable */

void ports_init(void);
void LCD_init(void);
void LCD_command(unsigned char command); 
void LCD_data(char data);
void UART2_init(void);
uint8_t UART2_read(void);
void delayMs(int n);
void delayUs(int n); 

uint8_t frames_x[256];
float a = 1;
float b = 1.2;
int time_unit = 5;

int main(void) {
	int len = 0;
	char lcd_data;
	uint8_t data;
	
	ports_init();
	UART2_init();

	while(1) {
		data = UART2_read();
		if (data == 'a') {
			a = UART2_read();
		} else if (data == 'b') {
			b = UART2_read();
		} else if (data == 't') {
			time_unit = UART2_read();
		} else {
			frames_x[len] = data;
			lcd_data = data + '0';
			len++;
		}
	}
	
}

void ports_init(void) {
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOAEN;								/* turn on the GPIOA clk */
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOBEN;								/* turn on the GPIOB clk */
		GPIOA -> MODER |= 0x555500;														/* set the GPIOA as output registers */
		GPIOB -> MODER |= 0x55555555;													/* set the GPIOB as output registers */	
		RCC -> APB2ENR |= RCC_APB2ENR_SYSCFGEN;
}

void LCD_init(void) {  
    delayMs(30);            /* initialization sequence */
    LCD_command(0x30);			
    delayMs(10);
    LCD_command(0x30);			/* set font=5x7 dot, 1-line display, 8-bit */
    delayMs(1);
    LCD_command(0x30);

    LCD_command(0x38);      /* set 8-bit data, 2-line, 5x7 font */
    LCD_command(0x06);      /* move cursor right after each char */
    LCD_command(0x01);      /* clear screen, move cursor to home */
    LCD_command(0x0F);      /* turn on display, cursor blinking */
}

void LCD_command(unsigned char command) {
    GPIOB -> ODR &= ~(RS | RW);           								/* RS = 0, R/W = 0 */          								
		GPIOA -> ODR = command << 4;                         	/* put command on data bus */
    GPIOB -> ODR |= EN;																		/* pulse EN high */
    delayMs(0);
		GPIOB -> ODR &= ~EN;
		
    if (command < 4)
        delayMs(4);        	 												/* command 1 and 2 needs up to 1.64ms */
    else
        delayMs(1);         												/* all others 40 us */
}

void LCD_data(char data) {
    GPIOB -> ODR |= RS;                   					/* RS = 1 */
    GPIOB -> ODR &= ~RW;                   					/* R/W = 0 */
    GPIOA -> ODR = data << 4;                   		/* put data on data bus */
    GPIOB -> ODR |= EN;                   					/* pulse EN high */
    delayMs(0);              												/* Do not change this line! */
		GPIOB -> ODR &= ~EN;

    delayMs(1);
}


void UART2_init(void){
	RCC->APB1ENR |= 0x20000;  // Enable UART2 CLOCK
	RCC->AHB1ENR |= 0x01; // Enable GPIOA CLOCK
	
	GPIOA->MODER |= 0x000000A0;  // bits 7-4 = 1010 = 0xA --> Alternate Function for Pin PA2 & PA3
	GPIOA->OSPEEDR |= 0x000000F0;  // bits 7-4 = 1111 = 0xF --> High Speed for PIN PA2 and PA3
	GPIOA->AFR[0] |= 0x07700;  // bits 15-8=01110111=0x77  --> AF7 Alternate function for USART2 at Pin PA2 & PA3
	
	USART2->BRR = 0x0683;   // Baud rate = 9600bps, CLK = 16MHz
	
	USART2->CR1 = 1<<13;  // UE = 1 -> Enable USART
	USART2->CR1 &= ~(1<<12);  // M =0; 8 bit word length
	
	USART2->CR1 |= (1<<2); // RE=1 -> Enable the Receiver
	USART2->CR1 |= (1<<3);  // TE=1 -> Enable Transmitter
}

uint8_t UART2_read(void) {
	while (!(USART2->SR & 0x0020));  // wait for RXNE bit to set
	return USART2->DR;
}

void delayMs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 3195; i++) ;
}

void delayUs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 8; i++) ;
}