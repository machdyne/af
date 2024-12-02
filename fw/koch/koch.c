/*
 * Koch Firmware
 * Copyright (c) 2024 Lone Dynamics Corporation. All rights reserved.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>

#include "pico/stdlib.h"
#include "hardware/watchdog.h"
#include "hardware/adc.h"
#include "hardware/i2c.h"
#include "pico/stdlib.h"
#include "pico/binary_info.h"

// Koch GPIOs
#define KOCH_SDA		0
#define KOCH_SCL		1
#define KOCH_LEDG		12
#define KOCH_LEDR		13
#define KOCH_CSENSE	26

// I2C registers for Essen
#define ESSEN_REG_STATUS		0x00	// RO
#define ESEEN_REG_FAULT			0x01	// RO
#define ESSEN_REG_ADVANCE		0x10	// RW
#define ESSEN_REG_MOTOR_FWD	0x20	// RW
#define ESSEN_REG_MOTOR_REV	0x21	// RW
#define ESSEN_REG_MOTOR_OFF	0x22	// RW

#define BUFLEN 32

float koch_adc_current(void);
void koch_i2c_scan(void);
void koch_i2c_set(uint8_t addr, uint8_t reg, uint8_t val);
void koch_i2c_get(uint8_t addr, uint8_t reg, uint8_t *out, uint16_t len);
void koch_report(void);
void koch_parse(char *buf);

int main(void) {

	stdio_init_all();
	while (!stdio_usb_connected()) {
		sleep_ms(100);
	}

	printf("# koch initializing ...\r\n");

	// configure I2C pins
	i2c_init(i2c_default, 100 * 1000);
	gpio_set_function(KOCH_SDA, GPIO_FUNC_I2C);
	gpio_set_function(KOCH_SCL, GPIO_FUNC_I2C);
	// koch has external I2C pull-ups
	gpio_set_pulls(KOCH_SDA, false, false);
	gpio_set_pulls(KOCH_SCL, false, false);

	// configure ADC pins
	adc_init();
	adc_gpio_init(KOCH_CSENSE);
	gpio_set_pulls(KOCH_CSENSE, false, false);

	// parser
   char buf[BUFLEN];
   int bptr = 0;
   int c;

	bzero(buf, BUFLEN);

	// wait for commands
	while (1) {

		c = getchar();

		if (c > 0) {

			if (c == 0x0a || c == 0x0d) {
				putchar(0x0a);
				putchar(0x0d);
				fflush(stdout);
				koch_parse(buf);
				bptr = 0;
				bzero(buf, BUFLEN);
				continue;
			}

			if (bptr >= BUFLEN - 1) {
				printf("# buffer overflow\r\n");
				bptr = 0;
				bzero(buf, BUFLEN);
				continue;
			}

			putchar(c);
			fflush(stdout);
			buf[bptr++] = c;

		}

	}

	return 0;

}


void koch_parse(char *buf) {

	if (!strncmp(buf, "K100", 4)) {
		int id = strtol(buf+5, NULL, 10);
		printf("# advancing tape on feeder id %i ...\r\n", id);
		koch_i2c_set(id, ESSEN_REG_ADVANCE, 0x01);
	} else if (!strncmp(buf, "K200", 4)) {
		int id = strtol(buf+5, NULL, 10);
		printf("# motor (#1 / forward) on feeder id %i ...\r\n", id);
		koch_i2c_set(id, ESSEN_REG_MOTOR_FWD, 0x01);
	} else if (!strncmp(buf, "K201", 4)) {
		int id = strtol(buf+5, NULL, 10);
		printf("# motor (#2 / reverse) on feeder id %i ...\r\n", id);
		koch_i2c_set(id, ESSEN_REG_MOTOR_REV, 0x01);
	} else if (!strncmp(buf, "K202", 4)) {
		int id = strtol(buf+5, NULL, 10);
		printf("# motor(s) lock / off feeder id %i ...\r\n", id);
		koch_i2c_set(id, ESSEN_REG_MOTOR_OFF, 0x01);
	} else if (!strncmp(buf, "K900", 4)) {
		printf("# status report\r\n");
		koch_report();
	} else {
		printf("# unknown command\r\n");
	}

}

void koch_report(void) {

	// 2V = 2A
	float current = koch_adc_current();
	printf("CURRENT: %f amps\n", current);

	koch_i2c_scan();

}

float koch_adc_current(void) {
	const float conversion_factor = 3.3f / (1 << 12);
	adc_select_input(0);
	return(adc_read() * conversion_factor);
}

void koch_i2c_scan(void) {

	printf("\nI2C Bus Scan\n");
	printf("   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n");

	for (int addr = 0; addr < (1 << 7); ++addr) {
		if (addr % 16 == 0) {
			printf("%02x ", addr);
		}

		// Perform a 1-byte dummy read from the probe address. If a slave
		// acknowledges this address, the function returns the number of bytes
		// transferred. If the address byte is ignored, the function returns
		// -1.

		// Skip over any reserved addresses.
		int ret;
		uint8_t rxdata;

		ret = i2c_read_timeout_us(i2c_default, addr, &rxdata, 1, false,
				1000);

		printf(ret < 0 ? "." : "@");
		printf(addr % 16 == 15 ? "\n" : "  ");

	}

}

void koch_i2c_set(uint8_t addr, uint8_t reg, uint8_t val) {

	int ret;
	uint8_t buf[2];

	buf[0] = reg;
	buf[1] = val;

	ret = i2c_write_blocking(i2c_default, addr, buf, 2, false);

}

void koch_i2c_get(uint8_t addr, uint8_t reg, uint8_t *out, uint16_t len) {

	int ret;
	uint8_t buf[1];

	buf[0] = reg;

	ret = i2c_write_blocking(i2c_default, addr, buf, 1, true);
	ret = i2c_read_blocking(i2c_default, addr, out, len, false);

}
