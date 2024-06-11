/**
 * @file: uart.s
 * 
 * @brief: this file includes the ASM functions for main program.
 */

/**
 * @brief uart_printMsgADC_asm.
 *
 * This function uses printf to send a message to the serial terminal
 * The function printf requires to be called through its wrapper __wrap_printf
 * The printf parameters are passed through registers r0-r3 and the stack. They
 * correspond to arguments in the string (%s, %d, %c, etc.). r0 is the reference to
 * the message pointer.
 * Parameters:
 *  R0: ADC_SENSOR
 *  R1: ADC_VALUE
 */
.global uart_printMsgADC_asm
uart_text_LEFTsensor:       .string "Left Sensor Value:%u\n"
uart_text_RIGHTsensor:      .string "Right Sensor Value:%u\n"
.align 2
uart_printMsgADC_asm:
    push    {lr}
uart_printMsg_ChkSensor:
    cmp     r0, #1                      // Si R0 es 1 imprimir ADC Derecho
    beq     uart_printMsg_RightValue

// Imprimir el valor del sensor izquierdo
uart_printMsg_LeftValue:
    ldr     r0, =uart_text_LEFTsensor   // Cargar la dirección de la cadena de formato para el sensor izquierdo
    bl      __wrap_printf               // Llamar a __wrap_printf para imprimir el valor del sensor izquierdo
    b       uart_printMsgADC_Exit

// Imprimir el valor del sensor derecho
uart_printMsg_RightValue:
    ldr     r0, =uart_text_RIGHTsensor  // Cargar la dirección de la cadena de formato para el sensor derecho
    bl      __wrap_printf               // Llamar a __wrap_printf para imprimir el valor del sensor derecho

// Restaurar Program Counter
uart_printMsgADC_Exit:
    pop {pc}