/**
 * @file main.c
 * @brief This is a brief description of the main C file.
 *
 * Detailed description of the main C file.
 */

// Standard libraries
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/pwm.h"

// The header files
#include "main.h"

/**
 * @brief Main program.
 *
 * This function initializes the MCU and does an infinite cycle.
 */

void wrap_adc_init();
void wrap_adc_gpio_init(uint32_t);
void wrap_adc_select_input(uint32_t);
uint16_t wrap_adc_read();

int main() {
	// STDIO initialization
    stdio_init_all();

	main_asm();

    return 0;
}
void wrap_adc_init() {
    adc_init();
}

void wrap_adc_gpio_init(uint32_t PIN) {
    adc_gpio_init(PIN);
}

void wrap_adc_select_input(uint32_t CHAN) {
    adc_select_input(CHAN);
}

uint16_t wrap_adc_read() {
    return adc_read();
}
