cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(koch)

add_executable(koch
        koch.c
        )

target_sources(koch PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/koch.c
        )

pico_sdk_init()

target_link_libraries(koch PRIVATE pico_stdlib hardware_resets hardware_irq hardware_adc hardware_i2c)

# enable usb output, disable uart output
pico_enable_stdio_usb(koch 1)
pico_enable_stdio_uart(koch 0)

pico_add_extra_outputs(koch)
