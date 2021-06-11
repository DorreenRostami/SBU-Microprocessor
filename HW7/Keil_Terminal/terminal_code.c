#include "stm32f4xx.h"

#define RS 0x20     /* PB5 mask for reg select */
#define RW 0x40     /* PB6 mask for read/write */
#define EN 0x80     /* PB7 mask for enable */

void delay(void);
void delayMs(int n);
void PORTS_init(void);

void keypad_init(void);
char keypad_getkey(void);
void LED_init(void);
void LED_blink(int value);

void LCD_command(unsigned char command);
void LCD_data(char data);
void LCD_init(void);

void UART2_init(void);
void UART2_write (char ch);
char UART2_read(void);


int main(void) {
	char key;
	int number_count = 0;
    
	PORTS_init();	
	LCD_init();
	keypad_init();
	UART2_init();
	
	while(1) {
		key = keypad_getkey(); 
		if (key != 10){
			UART2_write(key);
			delayMs(500);
			
			if(key == '*'){
				/* clear LCD display */
				LCD_command(1);
			}
			else if (key == '#' && number_count < 3) {
				LCD_command(1); 
				number_count = number_count + 1;		
			}
			else if (key == '#'){
				LCD_command(1);	
				key = UART2_read();
				delayMs(500);
				//LCD_data(key);
				while(key != 'd'){
					LCD_data(key);
					key = UART2_read();
					delayMs(500);
				}
			}
			else {
				LCD_data(key);
			}
		}	
	}			
}

//-------------------------------------------------------------------------------------------------------------------

void keypad_init(void) {
    RCC->AHB1ENR |=  0x14;	        /* enable GPIOC clock */
    GPIOC->MODER &= ~0x0000FFFF;    /* clear pin mode to input */
    GPIOC->PUPDR =   0x00000055;    /* enable pull up resistors for column pins */
}

/*
 * This is a non-blocking function to read the keypad.
 * If a key is pressed, it returns a unique code for the key.
 * Otherwise, a zero is returned.
 */
char keypad_getkey(void) {
    int row, col;
    const int row_mode[] = {0x00000100, 0x00000400, 0x00001000, 0x00004000}; /* one row is output */
    const int row_low[] =  {0x00100000, 0x00200000, 0x00400000, 0x00800000}; /* one row is low */
    const int row_high[] = {0x00000010, 0x00000020, 0x00000040, 0x00000080}; /* one row is high */

    /* check to see any key pressed */
    GPIOC->MODER = 0x00005500;      /* make all row pins output */
    GPIOC->BSRR =  0x00F00000;      /* drive all row pins low */
    delay();                        /* wait for signals to settle */
    col = GPIOC->IDR & 0x000F;      /* read all column pins */
    GPIOC->MODER &= ~0x0000FF00;    /* disable all row pins drive */
    if (col == 0x000F)              /* if all columns are high */
        return 10;                       /* no key pressed */

    /* If a key is pressed, it gets here to find out which key.
     * It activates one row at a time and read the input to see
     * which column is active. */
    for (row = 0; row < 4; row++) {
        GPIOC->MODER &= ~0x0000FF00;    /* disable all row pins drive */
        GPIOC->MODER |= row_mode[row];  /* enable one row at a time */
        GPIOC->BSRR = row_low[row];     /* drive the active row low */
        delay();                        /* wait for signal to settle */
        col = GPIOC->IDR & 0x000F;      /* read all columns */
        GPIOC->BSRR = row_high[row];    /* drive the active row high */
        if (col != 0x000F) break;       /* if one of the input is low, some key is pressed. */
    }
    GPIOC->BSRR = 0x000000F0;           /* drive all rows high before disable them */
    GPIOC->MODER &= ~0x0000FF00;        /* disable all rows */
    if (row == 4)
        return 10;                       /* if we get here, no key is pressed */

    /* gets here when one of the rows has key pressed*/
    if (row == 3 && col == 0x000E) return '*';
		if (row == 3 && col == 0x000D) return '0';
		if (row == 3 && col == 0x000B) return '#';
		if (col == 0x000E) return row * 3 + 1 + '0';    /* key in column 0 */
    if (col == 0x000D) return row * 3 + 2 + '0';    /* key in column 1 */
    if (col == 0x000B) return row * 3 + 3 + '0';    /* key in column 2 */

    return 10;   /* just to be safe */
}

//-------------------------------------------------------------------------------------------------------------------

/* initialize port pins then initialize LCD controller */
void LCD_init(void) {
    delayMs(30);            /* initialization sequence */
    LCD_command(0x30);
    delayMs(10);
    LCD_command(0x30);
    delayMs(1);
    LCD_command(0x30);

    LCD_command(0x38);      /* set 8-bit data, 2-line, 5x7 font */
    LCD_command(0x06);      /* move cursor right after each char */
    LCD_command(0x01);      /* clear screen, move cursor to home */
    LCD_command(0x0F);      /* turn on display, cursor blinking */
}

void PORTS_init(void) {
    RCC->AHB1ENR |=  0x03;          /* enable GPIOB/A clock */
	
	  /* PB5 for LCD R/S */
    /* PB6 for LCD R/W */
    /* PB7 for LCD EN */
    GPIOB->MODER &= ~0x0000FC00;    /* clear pin mode (00..00 11 11 11 00 00 00 00 00)*/
    GPIOB->MODER |=  0x00005400;    /* set pin output mode */
    GPIOB->BSRR = 0x00C00000;       /* turn off EN and R/W */

    /* PA4-PA11 for LCD D0-D7, respectively. */
    GPIOA->MODER &= ~0x00FFFF00;    /* clear pin mode */
    GPIOA->MODER |=  0x00555500;    /* set pin output mode */
}

void LCD_command(unsigned char command) {
    GPIOB->BSRR = (RS | RW) << 16;  /* RS = 0, R/W = 0 */
    GPIOA->ODR = (command << 4);           /* put command on data bus */
    GPIOB->BSRR = EN;               /* pulse E high */
    delayMs(0);
    GPIOB->BSRR = EN << 16;         /* clear E */

    if (command < 4)
        delayMs(2);         /* command 1 and 2 needs up to 1.64ms */
    else
        delayMs(1);         /* all others 40 us */
}

void LCD_data(char data) {
    GPIOB->BSRR = RS;               /* RS = 1 */
    GPIOB->BSRR = RW << 16;         /* R/W = 0 */
    GPIOA->ODR = (data << 4);              /* put data on data bus */
    GPIOB->BSRR = EN;               /* pulse E high */
    delayMs(0);
    GPIOB->BSRR = EN << 16;         /* clear E */

    delayMs(1);
}

//-------------------------------------------------------------------------------------------------------------------

void UART2_init(void){
	RCC->APB1ENR |= 0x20000;  // Enable UART2 CLOCK
	RCC->AHB1ENR |= 0x01; // Enable GPIOA CLOCK
	
	GPIOA->MODER |= 0x000000A0;  // bits 7-4 = 1010 = 0xA --> Alternate Function for Pin PA2 & PA3
	GPIOA->OSPEEDR |= 0x000000F0;  // bits 7-4 = 1111 = 0xF --> High Speed for PIN PA2 and PA3
	GPIOA->AFR[0] |= 0x07700;  // bits 15-8=01110111=0x77  --> AF7 Alternate function for USART2 at Pin PA2 & PA3
	
	USART2->BRR = 0x0683;   // Baud rate = 9600bps, CLK = 15MHz
	
	USART2->CR1 = 1<<13;  // Enable USART
	USART2->CR1 &= ~(1<<12);  // M =0; 8 bit word length
	
	USART2->CR1 |= (1<<2); // RE=1.. Enable the Receiver
	USART2->CR1 |= (1<<3);  // TE=1.. Enable Transmitter
}

void UART2_write (char ch) {
  USART2->DR = ch; // load the data into DR register
	while (!(USART2->SR & 0x0080));
}

char UART2_read(void) {
	while (!(USART2->SR & 0x0020));  // wait for RXNE bit to set
	return USART2->DR;
}

//-------------------------------------------------------------------------------------------------------------------

/* make a small delay */
void delay(void) {
    int i;
    for (i = 0; i < 20; i++) 
			__NOP();
}

/* 16 MHz SYSCLK */
void delayMs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 3195; i++) 
					__NOP();
}
