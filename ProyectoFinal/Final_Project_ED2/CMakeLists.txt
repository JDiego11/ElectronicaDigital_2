cmake_minimum_required(VERSION 3.13)

# Always include it
include(pico_sdk_import.cmake)

# Project's name (Replace my_DE2_Project with your own project's name)
project(my_DE2_Project C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# SDK Initialization - Mandatory
pico_sdk_init()

# C/C++ project files
add_executable(my_DE2_Project
    main.c
    main_asm.s
    global.s
    gpio.s
    pwm.s
    uart.s
)

# pico_stdlib library. You can add more if they are needed
target_link_libraries(my_DE2_Project pico_stdlib hardware_adc hardware_pwm)

# Enable usb output, disable uart output
pico_enable_stdio_usb(my_DE2_Project 1)
pico_enable_stdio_uart(my_DE2_Project 0)

# Need to generate UF2 file for upload to RP2040
pico_add_extra_outputs(my_DE2_Project)