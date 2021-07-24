#include <stm32f4xx.h>

#define RS 0x01     /* pin 0 = reg select */
#define RW 0x02     /* Pin 1 = read/write */
#define EN 0x04     /* Pin 2 = enable */

void ports_init(void);
char keypad_getkey(void);
void LCD_init(void);
void LCD_command(unsigned char); 
void LCD_data(char data);
void LCD_data_params(float, float, int);
void UART2_init(void);
void UART2_write(uint8_t);
void UART2_write_frame(void);
void ADC_init(void);
void TIMER_init(void);
void delayMs(int);
void delayUs(int); 

int counter = 0;
float a = 1;
float b = 1.2;
int time_unit = 5;
uint8_t frames[256];

int main(void) {
	unsigned char key;
	char adc_char;
	int adc_result;
	
	ports_init();
	LCD_init();
	UART2_init();
	ADC_init();
	TIMER_init();
	
	while(1) {
		key = keypad_getkey();
		if(key == '1') {
			a = a + 1; 
			LCD_data_params(a, b, time_unit); 
			UART2_write('a'); 
			UART2_write(a);
		}
		else if(key == '2') {
			a = a - 1; 
			LCD_data_params(a, b, time_unit); 
			UART2_write('a'); 
			UART2_write(a);
		}
		else if(key == '3') {
			b = b + 1; 
			LCD_data_params(a, b, time_unit); 
			UART2_write('b'); 
			UART2_write(b);
		}
		else if(key == '4') {
			b = b - 1; 
			LCD_data_params(a, b, time_unit); 
			UART2_write('b'); 
			UART2_write(b);
		}
		else if(key == '5') {
			time_unit = time_unit + 1; 
			LCD_data_params(a, b, time_unit);
			UART2_write('t'); 
			UART2_write(time_unit);
		}
		else if(key == '6') {
			time_unit = time_unit - 1; 
			LCD_data_params(a, b, time_unit);
			UART2_write('t'); 
			UART2_write(time_unit);
		}
		
	/*ADC1->CR2 |= 0x40000000;
		while(! (ADC1->SR & 2)) {}
		adc_result = ADC1->DR;
		if (adc_result & 0x100) {
			LCD_data(adc_result + '0');
		} else {
			LCD_data(adc_result + '0');
		}*/
	}
}

void ports_init(void) {
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOAEN;								/* turn on the GPIOA clk */
		RCC -> AHB1ENR |= RCC_AHB1ENR_GPIOBEN;								/* turn on the GPIOB clk */
		GPIOA -> MODER |= 0x555500;														/* set A4-A11 as output */
		GPIOB -> MODER |= 0x55000015;													/* set B0-B2 and B12-B15 as output */	
		RCC -> APB2ENR |= RCC_APB2ENR_SYSCFGEN;								/* enable system configuration controller clock */
}

char keypad_getkey(void){
		int row, col;
		const int row_select[] = {0x1000, 0x2000, 0x4000, 0x8000};
		/*check to see any key pressed*/
		GPIOB -> ODR |= 0xF000;										/*enable all rows*/
		GPIOB -> ODR &= ~(0xF000);								/*load all rows with zero output*/
		delayUs(5);																/*wait for signal return*/
		col = GPIOB ->IDR & 0x700;								/*read all columns*/
		GPIOB -> ODR |= 0xF000;										/*disable all rows*/
		if (col == 0x700) return 10;								/*no key pressed*/
		/*if a key is pressed, it gets here to find out which key.*/
		/*It activates one row at a time and read the input to see which column is active*/
		for (row = 0; row < 4; row++){
				GPIOB -> ODR |= 0xF000;											/*disable all rows*/
				GPIOB -> ODR |= row_select[row];						/*enable one row*/
				GPIOB -> ODR &= ~row_select[row];						/*drive the active row low*/
				delayUs(5);
				col = GPIOB -> IDR & 0x700;									/*read all columns*/
				if (col != 0x700) break;										/*if one of the input is low, some key is pressed*/
		}
		GPIOB -> ODR |= 0xF000;													/*disable all Mows00*/
		delayMs(200);
		
		if (row == 4) return 10; 																/* if we get here, no key is pressed */
		if (row == 3 && col == 0x600) return '*';
		if (row == 3 && col == 0x500) return '0';
		if (row == 3 && col == 0x300) return '#';
		if (col == 0x300) return (row * 3 + 3) + '0';						/*0000 0011 0000 0000 key in column 0*/
		if (col == 0x500) return (row * 3 + 2) + '0';						/*0000 0101 0000 0000 key in column 1*/
		if (col == 0x600) return (row * 3 + 1) + '0';						/*0000 0110 0000 0000 key in column 2*/
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
    GPIOB -> ODR &= ~(RS | RW);           					/* RS = 0, R/W = 0 */          								
		GPIOA -> ODR = command << 4; 										/* put command on data bus */
    GPIOB -> ODR |= EN;															/* pulse EN high */
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
    GPIOA -> ODR = data << 4;                				/* put data on data bus */
    GPIOB -> ODR |= EN;                   					/* pulse EN high */
    delayMs(0);              												/* Do not change this line! */
		GPIOB -> ODR &= ~EN;
    delayMs(1);
}

void LCD_data_params(float a, float b, int time_unit) { 
	int aa1 = a;
	char aa1_char = aa1 + '0';
	//float aa2 = a * 10 - aa1 * 10;
	//int aa2_i = aa2;
	//char aa2_char = aa2_i + '0';
	
	int bb1 = b;
	char bb1_char = bb1 + '0';
	//float bb2 = a * 10 - bb1 * 10;
	//int bb2_i = bb2;
	//char bb2_char = bb2_i + '0';
	
	char tt = time_unit + '0';
	LCD_command(0x01);
	
	LCD_data('A');
	LCD_data('=');
	LCD_data(aa1_char);
	//LCD_data('.');
	//LCD_data(aa2_char);
	LCD_data('v');
	LCD_data(',');
	
	LCD_data('B');
	LCD_data('=');
	LCD_data(bb1_char);
	//LCD_data('.');
	//LCD_data(bb2_char);
	LCD_data('v');
	LCD_data(',');
	
	LCD_data('T');
	LCD_data('=');
	LCD_data(tt);
	LCD_data('m');
	LCD_data('s');
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

void UART2_write (uint8_t ch) {
  USART2->DR = ch; // load the data into DR register
	while (!(USART2->SR & 0x0080)); // Wait for TC to SET.. This indicates that the data has been transmitted
}

void UART2_write_frame(){
		int i;		
		for (i = 0; i < counter; i++) {
			UART2_write(frames[i]);
			LCD_data(frames[i] + '0');
		}
		counter = 0;
}

void ADC_init() {
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN; //anable GPIOC clk
	GPIOC->MODER |= 0xC; //C1 = analog
	
	RCC->APB2ENR |= 0x00000100; //enable ADC1 clock 
	ADC1->CR2 = 0; //SW trigger
	ADC1->SQR3 = 1; //conversion sequence starts at ch 1
	ADC1->SQR1 = 0; //conversion sequence length 1
	ADC1->CR2 |= 1; //enable ADC1
}

void TIMER_init() {
	__disable_irq();
	
	RCC->APB1ENR |= RCC_APB1ENR_TIM2EN; 	//enable clock of timer 2
	TIM2->PSC = 16000 - 1; 								//set prescaler -> clk divided by 16000 to get counter frequency
	TIM2->ARR = 200 - 1; 									//auto reload register
	TIM2->DIER |= 1; 											//enable the update interrupt
	TIM2->CNT = 0; 												//clear timer counter
	TIM2->CR1 |= 1; 											//enable counting
	NVIC_EnableIRQ(TIM2_IRQn); 						//CMSIS ISR name
	
	RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;		//enable clock of timer 3
	TIM3->PSC = 160 - 1;									//set prescaler
	TIM3->ARR = 1 - 1; 										//auto reload register 
	TIM3->DIER |= 1; 											//enable the update interrupt
	TIM3->CNT = 0; 												//clear timer counter
	TIM3->CR1 |= 1; 											//enable counting
	NVIC_EnableIRQ(TIM3_IRQn); 						//CMSIS ISR name
	
	__enable_irq();
}

void TIM2_IRQHandler(void) { //
	TIM2->SR = 0;
	UART2_write_frame();
}

void TIM3_IRQHandler(void) {
	int adc_result;
	float converted_data;
	int data;
	TIM3->SR = 0;
	
	ADC1->CR2 |= 0x40000000;
	while(! (ADC1->SR & 2)) {}
	adc_result = ADC1->DR;
	
	// A hierachical encoder to get data
	data = 0;
	if (adc_result & 0x1) {
		data = 1;
	} if (adc_result & 0x10) {
		data = 2;
	} if (adc_result & 0x100) {
		data = 3;
	} if (adc_result & 0x1000) {
		data = 4;
	} if (adc_result & 0x10000) {
		data = 5;
	} if (adc_result & 0x100000) {
		data = 6;
	} if (adc_result & 0x1000000) {
		data = 7;
	} if (adc_result & 0x10000000) {
		data = 8;
	}
	
	converted_data = a * data + b; 
	frames[counter] = data;
	counter++;
}

/* delay n milliseconds (16 MHz CPU clock) */
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