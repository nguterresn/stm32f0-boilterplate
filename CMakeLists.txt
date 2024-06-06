cmake_minimum_required(VERSION 3.22)

# Before setting up project.
set(CMAKE_TOOLCHAIN_FILE  ${CMAKE_CURRENT_SOURCE_DIR}/toolchain.cmake)

project(stm32-f0-boilerplate
  VERSION
    1.0
  DESCRIPTION
    "stm32-f0-boilerplate"
)

enable_language(C ASM) # 'Enable' Assembly to load the startup file.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # For Clangd.

set(APPLICATION_PATH           ${CMAKE_CURRENT_SOURCE_DIR}/application)
set(SYSTEM_PATH                ${CMAKE_CURRENT_SOURCE_DIR}/system)

## -------------- Change according to your STM32 -------------- ##

set(HAL_PATH                   ${CMAKE_CURRENT_SOURCE_DIR}/stm32f0xx_hal_driver)
set(LD_FILE_PATH               ${SYSTEM_PATH}/STM32F030R8TX_FLASH.ld)
set(STARTUP_FILE_PATH          ${SYSTEM_PATH}/startup_stm32f030r8tx.s)
set(CPU_OPTIONS                -mcpu=cortex-m0 -mfloat-abi=soft)
set(STM_DEFINE                 STM32F030x8)
include(stm32.cmake)         # File that includes the options and definitions

## ------------------------------------------------------------ ##

# System

file(GLOB system_source CONFIGURE_DEPENDS ${SYSTEM_PATH}/source/*.c)
set(system_include ${SYSTEM_PATH}/include)

# HAL

file(GLOB hal_source CONFIGURE_DEPENDS ${HAL_PATH}/Src/*.c ${HAL_PATH}/Src/Legacy/*.c)
list(FILTER hal_source EXCLUDE REGEX ".*template\\.c$")
set(hal_include ${HAL_PATH}/Inc ${HAL_PATH}/Inc/Legacy)

add_library(hal ${hal_source})
target_include_directories(hal PUBLIC ${hal_include} ${system_include})
# Don't look up for warnings - compile options and defines as PRIVATE.
target_compile_definitions(hal PRIVATE ${COMPILER_DEFINES})
target_compile_options(hal PRIVATE ${CPU_OPTIONS})

# Application

file(GLOB application_source CONFIGURE_DEPENDS ${APPLICATION_PATH}/source/*.c)
set(application_include ${APPLICATION_PATH}/include)

add_executable(${CMAKE_BUILD_TYPE} ${application_source} ${system_source} ${STARTUP_FILE_PATH})
target_include_directories(${CMAKE_BUILD_TYPE} PRIVATE ${application_include})
target_link_libraries(${CMAKE_BUILD_TYPE} hal)

target_compile_definitions(${CMAKE_BUILD_TYPE} PRIVATE ${COMPILER_DEFINES})
target_compile_options(${CMAKE_BUILD_TYPE} PRIVATE ${CPU_OPTIONS} -Wall -Wextra -Werror)

target_link_options(${CMAKE_BUILD_TYPE} PRIVATE ${CPU_OPTIONS} -T${LD_FILE_PATH} -Wl,-Map=${CMAKE_BUILD_TYPE}.map ${LINKER_OPTIONS})

add_custom_command(TARGET ${CMAKE_BUILD_TYPE} POST_BUILD
  COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${CMAKE_BUILD_TYPE}>
)

add_custom_command(TARGET ${CMAKE_BUILD_TYPE} POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${CMAKE_BUILD_TYPE}> ${CMAKE_BUILD_TYPE}.hex
)
