if (NOT DEFINED SYSTEM_PATH)
  message(FATAL_ERROR "Please include a path for SYSTEM_PATH.")
elseif(NOT DEFINED HAL_PATH)
  message(FATAL_ERROR "Please include a path for HAL_PATH.")
elseif(NOT DEFINED CPU_OPTIONS)
  message(FATAL_ERROR "Please include a path for CPU_OPTIONS.")
elseif(NOT DEFINED COMPILER_DEFINES)
  message(FATAL_ERROR "Please include a path for COMPILER_DEFINES.")
elseif(NOT DEFINED COMPILER_OPTIONS)
  message(FATAL_ERROR "Please include a path for COMPILER_OPTIONS.")
endif()
message("Loading system CMakeLists.txt...")

file(GLOB_RECURSE system_source CONFIGURE_DEPENDS ${SYSTEM_PATH}/source/*.c)
set(system_include ${SYSTEM_PATH}/include)

file(GLOB_RECURSE hal_source CONFIGURE_DEPENDS ${HAL_PATH}/Src/*.c ${HAL_PATH}/Src/Legacy/*.c)
list(FILTER hal_source EXCLUDE REGEX ".*template\\.c$")

set(hal_include ${HAL_PATH}/Inc ${HAL_PATH}/Inc/Legacy)

add_library(system ${system_source} ${hal_source} ${STARTUP_FILE_PATH})
target_include_directories(system PUBLIC ${system_include} ${hal_include})

# Add compiler definitions, avoid using -D on target_compile_options.
target_compile_definitions(system PUBLIC ${COMPILER_DEFINES})
# Add compiler options
target_compile_options(system PUBLIC ${CPU_OPTIONS} ${COMPILER_OPTIONS})
