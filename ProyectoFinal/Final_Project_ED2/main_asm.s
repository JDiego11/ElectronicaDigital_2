/**
 * @file main_asm.s
 * @brief This is the main code of the light follower car.
 *
 */
.equ    DELAY,                  0x2FAF08
.equ    PWM_DIV_INTEGER,        30
.equ    PWM_DIV_FRAC,           133
.equ    PWM_TOP_VALUE,          5000
.equ    PWM_DUTY_ZERO,          0

.equ    GPIO_FUNCTION_SIO,      5
.equ    GPIO_FUNCTION_PWM,      4
.equ    GPIO_FUNC_OUT,          1

.equ    LEFT_SENSOR_PIN,        26
.equ    LEFT_MOTOR_PWM_PIN,     16
.equ    LEFT_LED_PIN,           17

.equ    RIGHT_SENSOR_PIN,       27
.equ    RIGHT_MOTOR_PWM_PIN,    15
.equ    RIGHT_LED_PIN,          14

.equ    AMBIENT_LIGHT,      1000

.global main_asm              // To be called from another file
main_asm:
    // Inicializacion los pines para los LEDs
    bl  gpio_init_asm

    ldr r0, =LEFT_LED_PIN
    ldr r1, =GPIO_FUNCTION_SIO
    bl  setFunctionGPIO             // Inicia funcion pin (led izquierdo)
    ldr r0, =LEFT_LED_PIN
    ldr r1, =GPIO_FUNC_OUT
    bl  gpio_set_dir_asm            // Direccion Pin led izquierdo como salida

    ldr r0, =RIGHT_LED_PIN
    ldr r1, =GPIO_FUNCTION_SIO
    bl  setFunctionGPIO             // Inicia funcion pin (led derecho)
    ldr r0, =RIGHT_LED_PIN
    ldr r1, =GPIO_FUNC_OUT
    bl  gpio_set_dir_asm            // Direccion Pin led derecho como salida

    // Inicializacion de los pines ADC
    bl  wrap_adc_init               // Quita Reset del ADC

    ldr r0, =LEFT_SENSOR_PIN
    bl  wrap_adc_gpio_init          // Inicia ADC 26
    ldr r0, =RIGHT_SENSOR_PIN
    bl  wrap_adc_gpio_init          // Inicia ADC 27

    // Inicializacion de los pines PWM
    bl  pwm_init_asm                // Quitar Reset del PWM

    ldr r0, =LEFT_MOTOR_PWM_PIN
    bl  main_init_pwm_asm           // Establecemos pin 16 como PWM
    ldr r0, =RIGHT_MOTOR_PWM_PIN
    bl  main_init_pwm_asm           // Establecemos pin 15 como PWM

// Bulce infinito
main_loop:
    ldr r0, =LEFT_SENSOR_PIN
    bl  main_read_sensor_asm        // Leer fotorresistor izquierdo
    push    {r0}
    mov r1, r0                      // Mover el valor del sensor a R1
    mov r0, #0                      // Seleccionar mostrar texto Izquierdo
    bl  uart_printMsgADC_asm        // Mostrar valor ADC Izquierdo

    ldr r0, =RIGHT_SENSOR_PIN
    bl  main_read_sensor_asm        // Leer fotorresistor derecho
    push    {r0}
    mov r1, r0                      // Mover el valor del sensor a R1
    mov r0, #1                      // Seleccionar mostrar texto Derecho
    bl  uart_printMsgADC_asm        // Mostrar valor ADC Derecho
    
    // R2: ADC Izquierdo - R3: ADC Derecho
    pop {r2, r3}

    ldr r1, =AMBIENT_LIGHT
        
    cmp r3, r1
    ble P_COND2             // Si ADC Derecho <= Luz ambiente compare adc Izquierdo
    b   Continue_Moving     // Si ADC Derecho > Luz ambiente Muevase

P_COND2:
    cmp r2, r1
    ble Call_Stop_Moving     // Si ADC Derecho <= Luz ambiente detenga
    b   Continue_Moving     // Si ADC Derecho > Luz ambiente Muevase

// Auxiliar para llamar una funcion
Call_Stop_Moving:
    bl  Stop_Moving
    b   do_delay

Continue_Moving:
    cmp r3, r2
    bgt Call_Move_Left                   // Si izquierdo es mayor que derecho
    blt Call_Move_Right                  // Si derecho es mayor que izquierdo
    beq Call_Just_Move                   // Si izquierdo es igual que derecho

// Auxiliar para llamar una funcion
Call_Move_Left:
    mov r0, r3
    bl  Move_Left
    b   do_delay

// Auxiliar para llamar una funcion
Call_Move_Right:
    mov r0, r3
    bl  Move_Right
    b   do_delay

// Auxiliar para llamar una funcion
Call_Just_Move:
    mov r0, r2
    mov r1, r3
    bl  Just_Move
    b   do_delay

// Auxiliar que llama el delay y determina el fin de un ciclo
do_delay:
    ldr r0, =DELAY
    bl  delay_asm
    b   main_loop

// Funciones del bucle infinito
/**
 * @brief Stop_Moving.
 *
 * Apaga los motores
 * Parameters:
 *  None
 */
Stop_Moving:
    push    {lr}
    // Detener motores
    ldr r0, =LEFT_MOTOR_PWM_PIN
    mov r1, #0
    bl  main_set_pwm_level_asm              // Detener izquierdo
    ldr r0, =RIGHT_MOTOR_PWM_PIN
    mov r1, #0
    bl  main_set_pwm_level_asm              // Detener Derecho
    // Apagar LEDs
    ldr r0, =LEFT_LED_PIN
    mov r1, #0
    bl  gpio_put_asm                    // Apagar LED Izquierdo
    ldr r0, =RIGHT_LED_PIN
    mov r1, #0
    bl  gpio_put_asm                    // Apagar LED Derecho
    pop {pc}

/**
 * @brief Move_Left.
 *
 * Enciende el motor Derecho para girar a la izquierda
 * Enciende Led Izquierdo
 * Parameters:
 *  R0: RIGHT_ADC_VALUE
 */
Move_Left:
    push    {r0, lr}
    // Ajustar motores
    ldr r0, =LEFT_MOTOR_PWM_PIN
    mov r1, #0
    bl  main_set_pwm_level_asm              // Detener izquierdo
    ldr r0, =RIGHT_MOTOR_PWM_PIN
    pop {r1}
    bl  main_set_pwm_level_asm              // Mover Derecho
    // Apagar LEDs
    ldr r0, =LEFT_LED_PIN
    mov r1, #1
    bl  gpio_put_asm                    // Encender LED Izquierdo
    ldr r0, =RIGHT_LED_PIN
    mov r1, #0
    bl  gpio_put_asm                    // Apagar LED Derecho
    pop {pc}

/**
 * @brief Move_Right.
 *
 * Enciende el motor Izquierdo para girar a la Derecha
 * Enciende Led Derecho
 * Parameters:
 *  R0: LEFT_ADC_VALUE
 */
Move_Right:
    push    {lr}
    // Ajustar motores
    mov r1, r0
    ldr r0, =LEFT_MOTOR_PWM_PIN
    //mov r1, r2
    bl  main_set_pwm_level_asm              // Mover izquierdo
    ldr r0, =RIGHT_MOTOR_PWM_PIN
    mov r1, #0
    bl  main_set_pwm_level_asm              // Detern Derecho
    // Apagar LEDs
    ldr r0, =LEFT_LED_PIN
    mov r1, #0
    bl  gpio_put_asm                    // Apagar LED Izquierdo
    ldr r0, =RIGHT_LED_PIN
    mov r1, #1
    bl  gpio_put_asm                    // Encender LED Derecho
    pop {pc}

/**
 * @brief Just_Move.
 *
 * Enciende ambos motores para ir recto
 * Enciende ambos leds
 * Parameters:
 *  R0: LEFT_ADC_VALUE
 *  R1: RIGHT_ADC_VALUE
 */
Just_Move:
    push    {r1, lr}
    mov r1, r0
    ldr r0, =LEFT_MOTOR_PWM_PIN
    //mov r1, r2
    bl  main_set_pwm_level_asm              // Mover izquierdo
    ldr r0, =RIGHT_MOTOR_PWM_PIN
    //mov r1, r3
    pop {r1}
    bl  main_set_pwm_level_asm              // Detern Derecho
    // Apagar LEDs
    ldr r0, =LEFT_LED_PIN
    mov r1, #1
    bl  gpio_put_asm                    // Encender LED Izquierdo
    ldr r0, =RIGHT_LED_PIN
    mov r1, #1
    bl  gpio_put_asm                    // Encender LED Derecho
    pop {pc}

// Funciones que se usaran dentro del programa principal
/**
 * @brief main_init_pwm_asm.
 *
 * Esta función inicializa el PWM en un PIN
 * Parameters:
 *  R0: PIN
 */
main_init_pwm_asm:
    push    {r0, lr}
    ldr r1, =GPIO_FUNCTION_PWM
    bl  setFunctionGPIO
    pop {r0}

    push    {r0}
    bl  pwm_gpio_to_channel_asm         // R0: Chan_num
    mov r1, r0                          // Move Chan_num (R0) to R1
    pop {r0}

    push    {r1}
    bl  pwm_gpio_to_slice_num_asm       // R0: slice_num
    pop {r1}

    push {r0, r1}
    ldr r1, =PWM_TOP_VALUE
    bl pwm_set_wrap_asm
    pop {r0, r1}

    push    {r0, r1}
    ldr r1, =PWM_DIV_INTEGER
    ldr r2, =PWM_DIV_FRAC
    bl  pwm_set_clkdiv_int_frac_asm
    pop {r0, r1}

    push {r0}
    ldr r2, =PWM_DUTY_ZERO
    bl  pwm_set_chan_level_asm
    pop {r0}

    mov r1, #1              // Enable True
    bl  pwm_set_enabled_asm
    pop {pc}

/**
 * @brief main_set_pwm_level_asm.
 *
 * Esta función establece el nivel/Duty del PWM
 * Parameters:
 *  R0: PIN
 *  R1: DUTY_LEVEL
 */
main_set_pwm_level_asm:
    push   {r0, r1, lr}
    bl  pwm_gpio_to_channel_asm         // R0: Chan_num
    mov r1, r0                          // Move Chan_num (R0) to R1
    pop {r0, r2}                        // Traer Duty_level (R1) de la pila a R2

    push    {r1, r2}
    bl  pwm_gpio_to_slice_num_asm       // R0: slice_num
    pop {r1, r2}                        // R1: Chan_num, R2: Duty_level

    bl  pwm_set_chan_level_asm
    pop {pc}

/**
 * @brief main_read_sensor_asm.
 *
 * Esta función recibe el ADC (0, 1, 2), lo lee y retorna el valor
 * Parameters:
 *  R0: ADC_CHx     (Pin-26)
 * Return
 *  R0: DUTY_LEVEL
 */
main_read_sensor_asm:
    sub r0, r0, #26                 // Pin - 26
    push    {r0, lr}
    bl  wrap_adc_select_input
    pop {r0}

    bl  wrap_adc_read
    pop {pc}