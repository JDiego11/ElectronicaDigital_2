/**
 * @file: pwm.s
 * 
 * This file includes the ASM functions for the pwm program. Func:
 * pwm_init
 * pwm_set_function
 * pwm_gpio_to_slice_num
 * pwm_set_clkdiv_int_frac
 * pwm_set_wrap
 * pwm_set_chan_level
 * pwm_set_enabled
 */

// General definitions
.equ    PWM_BITMASK,        0x4000  // 0000_0000_0000_0000_0100_0000_0000_0000

/**
 * @brief pwm_set_function_asm.
 *
 * This function disables resets from PWM
 * Parameters:
 *  None
 */

.global pwm_init_asm                   // To allow this function to be called from another file
pwm_init_asm:
    push {lr}
    ldr r0, =PWM_BITMASK
    bl  releaseReset
    pop {pc}

/**
 * @brief pwm_gpio_to_slice_num_asm.
 *
 * This function determinates the slice number for GPIO
 * Parameters:
 *  R0: GPIO_NUM
 * Return
 *  R0: SLICE_NUM
 */
.global pwm_gpio_to_slice_num_asm
pwm_gpio_to_slice_num_asm:
   lsr   r0, r0, #1           // R0 = 0XXXX -> Descartamos el bit menos significativo
   mov   r1, #7               // R1 = 00111 -> Para hacer la AND
   and   r0, r0, r1           // R0 = 00XXX -> Descartamos los dos bits mas significativos
   bx    lr

/**
 * @brief pwm_gpio_to_channel_asm.
 *
 * Esta funcion retorna el canal dependiendo el PIN
 * Parameters:
 *  R0: GPIO_NUM
 * Return
 *  R0: CHANNEL
 */
 .global pwm_gpio_to_channel_asm
pwm_gpio_to_channel_asm:
   mov   r1, #1
   and   r0, r0, r1
   bx    lr

/**
 * @brief pwm_set_clkdiv_int_frac_asm.
 *
 * This function set period for frequency divisor
 * Parameters:
 *  R0: SLICE_NUM
 *  R1: INTEGER
 *  R2: FRACT
 */
 .equ    PWM_BASE,      0x40050000
 .equ    CHx_DIV,       0x04
 .equ    PWM_INT_SHIF,   0x04
 .equ    PWM_FRAC_MASK,  0x0F
.global pwm_set_clkdiv_int_frac_asm
pwm_set_clkdiv_int_frac_asm:
   push  {r4}
   ldr   r3, =PWM_BASE              // Cargar la direccion base del PWM Register
   lsl   r4, r0, #4                 // Multiplicamos el slice por 16
   lsl   r0, r0, #2
   add   r0, r4, r0
   add   r3, r0                     // Slice offset mas direccion base
   mov   r4, #PWM_INT_SHIF
   lsl   r1, r1, r4                 // Desplazamos INT 4 bits a la izquierda
   mov   r4, #PWM_FRAC_MASK
   and   r2, r2, r4                 // AND con FRAC para asegurar que el valor sea de 4 bits
   orr   r1, r1, r2                 // OR para combinar INT y FRAC
   str   r1, [r3, #CHx_DIV]         // Guardar INT y FRAC en el registro del divisor
   pop   {r4}
   bx    lr

/**
 * @brief pwm_set_wrap_asm.
 *
 * This function set the TOP counter
 * Parameters:
 *  R0: SLICE_NUM
 *  R1: WRAP
 */
 .equ    CHx_TOP,    0x10
 .global pwm_set_wrap_asm
 pwm_set_wrap_asm:
    ldr   r2, =PWM_BASE                       // Cargar la direccion base del PWM Register
    lsl   r3, r0, #4                          // Multiplicamos el slice por 16
    lsl   r0, r0, #2
    add   r0, r3, r0                          // Multiplicamos el Slice por 4 y sumamos al por 16
    add   r2, r0                              // Slice offset mas direccion base
    str   r1, [r2, #CHx_TOP]                  // Guardar el valor del WRAP en el registro (TOP)
    bx    lr

/**
 * @brief pwm_set_chan_level_asm.
 *
 * This function set the level at the selected channel
 * Parameters:
 *  R0: SLICE_NUM
 *  R1: PWM_CHAN
 *  R2: DUTY_LEVEL
 */
.equ  CHx_CC,  0x0c
.global pwm_set_chan_level_asm
pwm_set_chan_level_asm:
    push  {r4}
    ldr   r3, =PWM_BASE                 // Cargar el valor base del PWM
    lsl   r4, r0, #4                    // Multiplicamos el slice por 16
    lsl   r0, r0, #2  
    add   r0, r4, r0                    // Multiplicamos el Slice por 4 y sumamos al por 16
    add   r3, r0                        // Slice offset mas direccion base
    lsl   r1, r1, #4                    // Convertir el 0 o 1 en 0 o 16 para desplazar según sea el canal A o B
    lsl   r2, r2, r1                    // Desplazamos el level para ajustar si es el canal A o B
    str   r2, [r3, #CHx_CC]
    pop   {r4}
    bx    lr

/**
 * @brief pwm_set_enabled_asm.
 *
 * This function enables PWM
 * Parameters:
 *  R0: SLICE_NUM
 *  R1: ENABLED
 */
.equ  CHx_CSR,    0x00
.global pwm_set_enabled_asm
pwm_set_enabled_asm:
   ldr   r2, =PWM_BASE                 // Cargar el valor base del PWM
   lsl   r3, r0, #4                    // Multiplicamos el slice por 16
   lsl   r0, r0, #2
   add   r0, r3, r0                    // Multiplicamos el Slice por 4 y sumamos al por 16
   add   r2, r0                        // Slice offset mas direccion base
   str   r1, [r2, #CHx_CSR]             // Guardar el enable en el registro
   bx    lr