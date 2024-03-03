cmake_minimum_required(VERSION 3.22)
# Before setting up project.
set(CMAKE_TOOLCHAIN_FILE  ${CMAKE_CURRENT_SOURCE_DIR}/toolchain.cmake)

project(stm32-f0-boilerplate
  VERSION
    1.0
  DESCRIPTION
    "Description"
)

enable_language(C ASM) # 'Enable' Assembly to load the startup file.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(APPLICATION_PATH           ${CMAKE_CURRENT_SOURCE_DIR}/application)
set(SYSTEM_PATH                ${CMAKE_CURRENT_SOURCE_DIR}/system)

# Specific to a type of microcontroller.
## -- Change according to your STM32 -- ##

set(HAL_PATH                   ${CMAKE_CURRENT_SOURCE_DIR}/stm32f0xx_hal_driver)
set(LD_FILE_PATH               ${SYSTEM_PATH}/STM32F030R8TX_FLASH.ld)
set(STARTUP_FILE_PATH          ${SYSTEM_PATH}/startup_stm32f030r8tx.s)
set(CPU_OPTIONS                -mcpu=cortex-m0 -mfloat-abi=soft)
set(STM_DEFINE                 STM32F030x8)
include(stm32f0.cmake)         # File that includes the options and definitions

## ------------------------------------ ##

add_subdirectory(${SYSTEM_PATH})

file(GLOB_RECURSE application_source CONFIGURE_DEPENDS ${APPLICATION_PATH}/source/*.c)
set(application_include ${APPLICATION_PATH}/include)

add_executable(${PROJECT_NAME} ${application_source})
target_include_directories(${PROJECT_NAME} PRIVATE ${application_include})
# Add System & HAL
target_link_libraries(${PROJECT_NAME}
  PRIVATE
    hal
    system
)

target_link_options(${PROJECT_NAME} PRIVATE ${CPU_OPTIONS} -T${LD_FILE_PATH} -Wl,-Map=${PROJECT_NAME}.map ${LINKER_OPTIONS})

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
)
