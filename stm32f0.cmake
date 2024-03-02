#### -------------- COMPILER -------------- ####

set(CPU_OPTIONS
  -mcpu=cortex-m0
  -mfloat-abi=soft
)

set(COMPILER_OPTIONS
  -Wall
  -Wextra
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(COMPILER_OPTIONS
    ${COMPILER_OPTIONS}
    -Os
  )
else()
  # Anything not release will be considered Debug
  set(COMPILER_OPTIONS
    ${COMPILER_OPTIONS}
    -Og # Optimized for debugging!
    -g3 # Max level of debug!
    -ggdb
  )
endif()

# Preprocessor defines!
set(COMPILER_DEFINES
  "USE_HAL_DRIVER"
  "STM32F030x8"
)

#### -------------- LINKER -------------- ####

set(LINKER_OPTIONS
  --specs=nosys.specs
  -mthumb
  -Wl,--start-group
  -lc
  -lm
  -Wl,--end-group
  -Wl,--print-memory-usage
)
