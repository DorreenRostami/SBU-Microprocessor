#include "stm32F4xx.h"

#define RCC_AHB1ENR 0x40023830

void init(void);

void UART2_init(void);
void UART2_write(char);
char UART2_read(void);

void LED_init(void);
void LED_blink(void);

void delayMs(int);

int calculate(int, int[]);
void UART2_write_number(int);


int main (void) {
	char data;
	int abc[] = {0, 0, 0};
	int number_count = 0;
	int curr_number = 0;	
	
	UART2_init();
	
	while(1) {
		data = UART2_read();
		delayMs(500);
		
		//LED_blink();	
	
		if (data == '*'){
			curr_number = 0;	
		}
		else if (data == '#' && number_count < 3){		
			abc[number_count] = curr_number;
			curr_number = 0;	
			number_count = number_count + 1;
		}
		else if (data == '#'){	
			curr_number = calculate(curr_number, abc);
			//UART2_write('h');
			//delayMs(500);
			UART2_write_number(curr_number);
			curr_number = 0;
		}
		else {
			curr_number = (curr_number*10) + (data - '0');
		}

	}
}


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

void UART2_write_number(int number){
	int len = 1;
	int power = 1;
	for(int i = 10; i <= number; i = i*10){
		len = len + 1;
		power = power * 10;
	}
	power = power / 10;
	
	for (int i = len; i > 0; i = i - 1){
		UART2_write(((number / power) % 10) + '0');
		power = power / 10;
		delayMs(500);
	}
	UART2_write('d');
}

//-------------------------------------------------------------------------------------------------------------------

void LED_init(void) {
    // enable PB0 for green LED
    RCC->AHB1ENR |=  0x02;	            /* enable GPIOB clock */
    GPIOB->MODER &= ~0x00000003;    /* clear pin mode */
    GPIOB->MODER |=  0x00000001;    /* set pin output mode */
}

void LED_blink(void) {
	GPIOB -> ODR = 0x1;   /* turn on LED */
	delayMs(1000);				// wait a second...
  GPIOB -> ODR = 0x0;   /* turn off LED */
}

//-------------------------------------------------------------------------------------------------------------------

int calculate(int x, int numbers[]){
		return numbers[0]*x + 2*numbers[1]*x + 3*numbers[2]*x;
}


void delayMs(int n) {
    int i;
    for (; n > 0; n--)
        for (i = 0; i < 7000; i++) ;
}