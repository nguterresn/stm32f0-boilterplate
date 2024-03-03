BUILD_TYPE ?= Debug
PROJECT_NAME ?= stm32-f0-boilterplate

build: init
	cmake --build build/$(BUILD_TYPE) --clean-first -j 8 --config $(BUILD_TYPE)

init:
	cmake -S . -B build/$(BUILD_TYPE) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -G "Unix Makefiles"

.PHONY: build init
