BUILD_TYPE ?= Debug
PROJECT_NAME ?= stm32-f0-boilerplate
STLINK ?= STM32_Programmer_CLI

flash: build
	$(STLINK) -c port=SWD -d build/$(BUILD_TYPE)/$(PROJECT_NAME).hex -hardRst

build: init
	cmake --build build/$(BUILD_TYPE) --clean-first -j 8 --config $(BUILD_TYPE)

init:
	cmake -S . -B build/$(BUILD_TYPE) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)

.PHONY: flash build init
