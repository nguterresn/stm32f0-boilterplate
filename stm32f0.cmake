#### -------------- COMPILER -------------- ####

set(COMPILER_OPTIONS
  -Og # Optimized for debugging!
  -g3 # Max level of debug!
)

# Preprocessor defines!
set(COMPILER_DEFINES
  "USE_HAL_DRIVER"
  ${STM_DEFINE}
)

#### -------------- LINKER -------------- ####

set(LINKER_OPTIONS
  --specs=nosys.specs
  -mthumb

  ## -- MATH LIBRARY START -- ##
  -Wl,--start-group
  -lc
  -lm
  -Wl,--end-group
  ## -- MATH LIBRARY END -- ##

  # Print memory usage - flash, ram, etc
  -Wl,--print-memory-usage
)
