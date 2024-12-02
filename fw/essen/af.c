/*
 * Essen Autofeeder Firmware
 * Copyright (c) 2024 Lone Dynamics Corporation. All rights reserved.
 *
 */

#include "ch32v003fun.h"
#include "i2c_slave.h"
#include <stdio.h>

#define AF_I2C_ADDR	0x9

#define AF_ELED_PORT GPIOA
#define AF_ELED_PIN 1

#define AF_DRVMODE_PORT GPIOC
#define AF_DRVMODE_PIN 3

#define AF_DRV1_PORT GPIOC
#define AF_DRV1_PIN 5

#define AF_DRV2_PORT GPIOC
#define AF_DRV2_PIN 7

#define AF_DRVSLPN_PORT GPIOC
#define AF_DRVSLPN_PIN 6

#define AF_I2C_SDA_PORT GPIOC
#define AF_I2C_SDA_PIN 1

#define AF_I2C_SCL_PORT GPIOC
#define AF_I2C_SCL_PIN 2

volatile uint8_t i2c_regs[32] = {0x00};

void i2c_onWrite(uint8_t reg, uint8_t length);
void i2c_onRead(uint8_t reg);

void adc_init( void )
{
	// ADCCLK = 24 MHz => RCC_ADCPRE = 0: divide by 2
	RCC->CFGR0 &= ~(0x1F<<11);

	// Enable ADC
	RCC->APB2PCENR |= RCC_APB2Periph_ADC1;
	
	// PD4 is analog input chl 7
	GPIOD->CFGLR &= ~(0xf<<(4*4));	// CNF = 00: Analog, MODE = 00: Input
	
	// Reset the ADC to init all regs
	RCC->APB2PRSTR |= RCC_APB2Periph_ADC1;
	RCC->APB2PRSTR &= ~RCC_APB2Periph_ADC1;
	
	// Set up single conversion for chl 7
	ADC1->RSQR1 = 0;
	ADC1->RSQR2 = 0;
	//ADC1->RSQR3 = 7;	// 0-9 for 8 ext inputs and two internals
	ADC1->RSQR3 = 6;	// 0-9 for 8 ext inputs and two internals
	
	// set sampling time for chl 7
	ADC1->SAMPTR2 &= ~(ADC_SMP0<<(3*7));
   // Possible times: 0->3,1->9,2->15,3->30,4->43,5->57,6->73,7->241 cycles
   ADC1->SAMPTR2 = 1/*9 cycles*/ << (3/*offset per channel*/ * 7/*channel*/);

	// turn on ADC and set rule group to sw trig
	ADC1->CTLR2 |= ADC_ADON | ADC_EXTSEL;

	// Reset calibration
	ADC1->CTLR2 |= ADC_RSTCAL;
	while(ADC1->CTLR2 & ADC_RSTCAL);
	
	// Calibrate
	ADC1->CTLR2 |= ADC_CAL;
	while(ADC1->CTLR2 & ADC_CAL);
	
	// should be ready for SW conversion now
}

uint16_t adc_get( void )
{
	// start sw conversion (auto clears)
	ADC1->CTLR2 |= ADC_SWSTART;
	
	// wait for conversion complete
	while(!(ADC1->STATR & ADC_EOC));
	
	// get result
	return ADC1->RDATAR;
}

int main()
{
	uint8_t dir;
	uint32_t count = 0;

	SystemInit();
	funGpioInitAll();

	printf("\r\r\n\nessen firmware\n\r");

	// motor driver #1
	(AF_DRV1_PORT)->CFGLR &= ~(0xf<<(4*AF_DRV1_PIN));
	(AF_DRV1_PORT)->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*AF_DRV1_PIN);

	// motor driver #2
	(AF_DRV2_PORT)->CFGLR &= ~(0xf<<(4*AF_DRV2_PIN));
	(AF_DRV2_PORT)->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*AF_DRV2_PIN);

	// motor mode (floating = h-bridge)
	//(AF_DRVMODE_PORT)->CFGLR &= ~(0xf<<(4*AF_DRVMODE_PIN));
	//(AF_DRVMODE_PORT)->CFGLR |= (GPIO_CNF_IN_FLOATING)<<(4*AF_DRVMODE_PIN);

	// motor mode (low = full-bridge pwm)
	(AF_DRVMODE_PORT)->CFGLR &= ~(0xf<<(4*AF_DRVMODE_PIN));
	(AF_DRVMODE_PORT)->CFGLR |= (GPIO_CNF_IN_FLOATING)<<(4*AF_DRVMODE_PIN);
	(AF_DRVMODE_PORT)->BSHR = (1 << (16+AF_DRVMODE_PIN));

	// driver sleep disable
	(AF_DRVSLPN_PORT)->CFGLR &= ~(0xf<<(4*AF_DRVSLPN_PIN));
	(AF_DRVSLPN_PORT)->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*AF_DRVSLPN_PIN);
	(AF_DRVSLPN_PORT)->BSHR = (1 << AF_DRVSLPN_PIN);


	// configure IR LED
	(AF_ELED_PORT)->CFGLR &= ~(0xf<<(4*AF_ELED_PIN));
	(AF_ELED_PORT)->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*AF_ELED_PIN);

	// configure I2C slave
   funPinMode(PC1, GPIO_CFGLR_OUT_10Mhz_AF_OD); // SDA
   funPinMode(PC2, GPIO_CFGLR_OUT_10Mhz_AF_OD); // SCL

	SetupI2CSlave(AF_I2C_ADDR, i2c_regs, sizeof(i2c_regs),
		i2c_onWrite, i2c_onRead, false);

//	printf("waiting 1 second ...\n\r");
//	Delay_Ms( 1000 );

	// init adc
	adc_init();

	while(1)
	{
		printf("WAITING FOR COMMAND\n\r");
		Delay_Ms( 2000 );
	}

}

void moveTapeMotor(int ms) {
	(AF_DRV1_PORT)->BSHR = (1 << AF_DRV1_PIN);
   Delay_Ms(ms);
   (AF_DRV1_PORT)->BSHR = ( 1 << (16 + AF_DRV1_PIN) );
}

#define AF_THRES_START 1010
#define AF_THRES_HOLE_MIN 985
#define AF_THRES_HOLE_MAX 995

void moveTapeToPickPosition() {

	// LED on
	(AF_ELED_PORT)->BSHR = (1 << AF_ELED_PIN);
	Delay_Ms(10);

	int start = 1;
	int breakOnMark = 0;
	int tapeEnd = 0;

	while (1) {

		int av = adc_get();

		printf(" ADC: %d\r\n", av);

		if (av > AF_THRES_START) { start = 0; }

		if (!start && av >= AF_THRES_HOLE_MIN && av <= AF_THRES_HOLE_MAX) {
			printf("MARK FOUND\r\n");
			break;
		}

		moveTapeMotor(5);
		Delay_Ms(10);

	}

	// LED off
	(AF_ELED_PORT)->BSHR = ( 1 << (16 + AF_ELED_PIN) );
	Delay_Ms(10);

}

void i2c_onWrite(uint8_t reg, uint8_t length) {
	printf("i2c_onWrite reg: %x len: %x val: %x\n\r", reg, length,
		i2c_regs[reg]);
	if (reg == 0x10) {
		moveTapeToPickPosition();
	} else if (reg == 0x20) {	// forward
		(AF_DRV1_PORT)->BSHR = (1 << AF_DRV1_PIN);
   	(AF_DRV2_PORT)->BSHR = (1 << (16 + AF_DRV2_PIN));
	} else if (reg == 0x21)	{	// reverse
   	(AF_DRV1_PORT)->BSHR = (1 << (16 + AF_DRV1_PIN));
		(AF_DRV2_PORT)->BSHR = (1 << AF_DRV2_PIN);
	} else if (reg == 0x22) {	// off
   	(AF_DRV1_PORT)->BSHR = (1 << (16 + AF_DRV1_PIN));
   	(AF_DRV2_PORT)->BSHR = (1 << (16 + AF_DRV2_PIN));
	}
}

void i2c_onRead(uint8_t reg) {
	printf("i2c_onRead reg: %x val: %x\n\r", reg, i2c_regs[reg]);
}

