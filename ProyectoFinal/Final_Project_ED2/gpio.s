/**
 * @file: gpio.s
 * 
 * @brief: this file includes the ASM functions for the blinking program.
 */

// General definitions
.equ    IO_BANK0_BITMASK,   0x0020  // 0000_0000_0000_0000_0000_0000_0010_0000

/**
 * @brief gpio_init_asm.
 *
 * This function initializes the GPIO module
 * Parameters:
 *  None
 */

.global gpio_init_asm                   // To allow this function to be called from another file
gpio_init_asm:
        push {lr}
        ldr r0, =IO_BANK0_BITMASK
        bl releaseReset
        pop {pc}

/**
 * @brief gpio_set_dir_asm.
 *
 * This function sets the direction for a single GPIOx
 * Parameters:
 *  R0: GPIO_NUM
 *  R1: OUT (0: Input, 1: Output)
 */
.global gpio_set_dir_asm                // To allow this function to be called from another file
.equ    SIO_BASE, 0xd0000000            // See RP2040 datasheet: 2.3.1.7 (Processor Subsystem, SIO)
.equ    GPIO_OE_OFFSET,        32
.equ    GPIO_OE_SET_OFFSET,    4
.equ    GPIO_OE_CLR_OFFSET,    8
gpio_set_dir_asm:
	mov r2, #1			                // load a '1' to be shifted GPIO_NUM places
	lsl r2, r2, r0 	                    // shift the bit over to align with GPIO_NUM
	ldr r0, =(SIO_BASE+GPIO_OE_OFFSET)  // Address for GPIO_OE register
    cmp r1, #0                          // Check parameter to set input or output on GPIO GPIO_NUM
    beq gpio_set_dir_asm_clr            // If zero then GPIO GPIO_NUM must be an input
	str r2, [r0, #GPIO_OE_SET_OFFSET]   // set GPIO_NUM GPIO as an output
    bx  lr
gpio_set_dir_asm_clr:
	str r2, [r0, #GPIO_OE_CLR_OFFSET]   // set GPIO_NUM GPIO as an input
    bx  lr

/**
 * @brief gpio_put_asm.
 *
 * This function initializes the GPIO module
 * Parameters:
 *  R0: GPIO_NUM
 *  R1: VALUE (if false clear the GPIOx, otherwise set it)
 */
.global gpio_put_asm                    // To allow this function to be called from another file
.equ    GPIO_OUT_OFFSET,      16
.equ    GPIO_OUT_SET_OFFSET,   4
.equ    GPIO_OUT_CLR_OFFSET,   8
gpio_put_asm:
	mov r2, #1			                // load a '1' to be shifted GPIO_NUM places
	lsl r2, r2, r0 	                    // shift the bit over to align with GPIO_NUM
	ldr r0, =(SIO_BASE+GPIO_OUT_OFFSET) // Address for GPIO_OE register
    cmp r1, #0                          // Check parameter to set input or output on GPIO GPIO_NUM
    beq gpio_put_asm_clr                // If zero then GPIO GPIO_NUM must be an input
	str r2, [r0, #GPIO_OUT_SET_OFFSET]  // set GPIO_NUM GPIO as '1'
    bx  lr
gpio_put_asm_clr:
	str r2, [r0, #GPIO_OUT_CLR_OFFSET]  // set GPIO_NUM GPIO as '0'
    bx  lr