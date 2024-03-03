cmake_minimum_required(VERSION 3.22)

set(CMAKE_C_STANDARD                11)
set(CMAKE_C_STANDARD_REQUIRED       ON)
set(CMAKE_C_EXTENSIONS              ON)
set(CMAKE_CXX_STANDARD              20)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            ON)

# Before setting up project.
set(CMAKE_TOOLCHAIN_FILE  ${CMAKE_CURRENT_SOURCE_DIR}/toolchain.cmake)

project(stm32-f0-boilerplate
  VERSION
    1.0
  DESCRIPTION
    "Description"
)

enable_language(C CXX ASM) # 'Enable' Assembly to load the startup file.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(APPLICATION_PATH           ${CMAKE_CURRENT_SOURCE_DIR}/application)
set(SYSTEM_PATH                ${CMAKE_CURRENT_SOURCE_DIR}/system)

## -------------- Change according to your STM32 -------------- ##

set(HAL_PATH                   ${CMAKE_CURRENT_SOURCE_DIR}/stm32f0xx_hal_driver)
set(LD_FILE_PATH               ${SYSTEM_PATH}/STM32F030R8TX_FLASH.ld)
set(STARTUP_FILE_PATH          ${SYSTEM_PATH}/startup_stm32f030r8tx.s)
set(CPU_OPTIONS                -mcpu=cortex-m0 -mfloat-abi=soft)
set(STM_DEFINE                 STM32F030x8)
include(stm32f0.cmake)         # File that includes the options and definitions

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
target_compile_options(hal PRIVATE ${CPU_OPTIONS} ${COMPILER_OPTIONS})

# Application

file(GLOB application_source CONFIGURE_DEPENDS ${APPLICATION_PATH}/source/*.c)
set(application_include ${APPLICATION_PATH}/include)

add_executable(${PROJECT_NAME} ${application_source} ${system_source} ${STARTUP_FILE_PATH})
target_include_directories(${PROJECT_NAME} PRIVATE ${application_include})
target_link_libraries(${PROJECT_NAME} hal)

target_compile_definitions(${PROJECT_NAME} PRIVATE ${COMPILER_DEFINES})
target_compile_options(${PROJECT_NAME} PRIVATE ${CPU_OPTIONS} -Wall -Wextra -Werror ${COMPILER_OPTIONS})

target_link_options(${PROJECT_NAME} PRIVATE ${CPU_OPTIONS} -T${LD_FILE_PATH} -Wl,-Map=${PROJECT_NAME}.map ${LINKER_OPTIONS})

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
)
