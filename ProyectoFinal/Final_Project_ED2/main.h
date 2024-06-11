/**
 * @file main.h
 * @brief This is a brief description of the main H file.
 *
 * Detailed description of the main C file.
 */
 
 #include <stdint.h>

// Avoid duplication in code
#ifndef _MAIN_H_
#define _MAIN_H_

// Define Macros
#define LEFT_MOTOR_PWM_PIN 16
#define RIGHT_MOTOR_PWM_PIN 15
#define LEFT_SENSOR_PIN 26
#define RIGHT_SENSOR_PIN 27
#define LEFT_LED_PIN 17
#define RIGHT_LED_PIN 14
#define PWM_WRAP 4095
#define PWM_DIV_INTEGER 30
#define PWM_DIV_FRAC 133

#define GPIO_FUNCTION_PWM   4
#define GPIO_FUNCTION_SIO   5

#define AMBIENT_LIGHT_THRESHOLD 1000
#define DELAY               2000

// Write your definitions and other macros here
void main_asm();

//Global
void releaseReset(uint32_t);
void setFunctionGPIO(uint32_t, uint32_t);
void delay_asm(uint32_t);

//PWM
void pwm_init_asm();
uint pwm_gpio_to_slice_num_asm(uint32_t);
bool pwm_gpio_to_channel_asm(uint32_t);
void pwm_set_clkdiv_int_frac_asm(uint32_t, uint32_t, uint32_t);
void pwm_set_wrap_asm(uint32_t, uint32_t);
void pwm_set_chan_level_asm(uint32_t, uint32_t, uint32_t);
void pwm_set_enabled_asm(uint32_t, bool);

//GPIO
void gpio_init_asm();
void gpio_set_dir_asm(uint32_t, bool);
void gpio_put_asm(uint32_t, bool);

// cositas
void Stop_Moving();
void Move_Left(uint16_t);
void Move_Right(uint16_t);
void Just_Move(uint16_t, uint16_t);
void loop_try1();
void do_delay();

#endif