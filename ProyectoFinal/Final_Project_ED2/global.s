/*
 *  @file: global.s
 *
 *  This file has the functions that can be used in any module
 *  (PWM, ADC, GPIO) functions that are independent of those modules
 *
 */

.equ    ATOMIC_XOR,         0x1000
.equ    ATOMIC_SET,         0x2000
.equ    ATOMIC_CLR,         0x3000
.equ    ADC_BITMASK,        0x0001  // 0000_0000_0000_0000_0000_0000_0000_0001

/**
 * @brief releaseResetIOBank0
 *
 *  This function releases the Reset for IO_Bank0
 *  Parameters:
 *      R0: BITMASK
 */
.equ    RESETS_BASE,            0x4000c000         // See RP2040 datasheet: 2.14.3 (Subsystem Resets)
.equ    RESET_DONE_OFFSET,      8
.global releaseReset
releaseReset:
    ldr r1, =(RESETS_BASE+ATOMIC_CLR)	// Address for reset controller atomic clr register
	str r0, [r1]    	                // Request to clear reset IOBank0, ADC or PWM
    ldr r1, =RESETS_BASE                // Base address for reset controller
rstdone:     
	ldr r2, [r1, #RESET_DONE_OFFSET]    // Read reset done register
	and r2, r2, r0		                // Check bit component (0: reset has not been released yet)
	beq rstdone
    bx  lr

/**
 * @brief setFunctionGPIO.
 *
 * This function selects function SIO for GPIOx
 * Parameters:
 *  R0: GPIO_NUM
 *  R1: GPIO_SIO_FUNCTION   4 -> SIO
 *                          5 -> PWM
 */
.equ    IO_BANK0_BASE,          0x40014000       // See RP2040 datasheet: 2.19.6 (GPIO)
.equ    GPIO0_CTRL_OFFSET,  4
.global setFunctionGPIO
setFunctionGPIO:
	ldr r2, =(IO_BANK0_BASE+GPIO0_CTRL_OFFSET)  // Address for GPIO0_CTRL register
    lsl r0, r0, #3                      // Prepare register offset for GPIOx (GPIO_NUM * 8)
	str r1, [r2, r0]	                // Store selected function (SIO) in GPIOx control register
    bx  lr

/**
 * @brief delay_asm.
 *
 * This function spends several cycles doing nothing
 * Parameters:
 *  R0: BIG_NUM
 */
.global delay_asm
delay_asm:
    sub r0, r0, #1
    bne delay_asm        
    bx  lr