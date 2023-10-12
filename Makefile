# See: makefiletutorial.com

TARGET_EXEC := main
CXX := clang++

BUILD_DIR := ./build
SHADER_DIR := ./shaders
SRC_DIRS := ./src

VULKAN_BASE := /Users/nick/VulkanSDK/1.3.261.1/macOS
GLSLC:=$(VULKAN_BASE)/bin/glslc

BASE_FLAGS := -std=c++20 

# Include directories
BASE_INCLUDES := -I$(VULKAN_BASE)/include -I/opt/homebrew/include

# Library directories
BASE_LFLAGS := -L$(VULKAN_BASE)/lib -L/opt/homebrew/lib

# Libraries
BASE_LIBS := -lvulkan -lglfw

CXXFLAGS := $(BASE_FLAGS) $(BASE_INCLUDES)

LDFLAGS := $(BASE_LFLAGS) $(BASE_LIBS) -Wl,-rpath,$(VULKAN_BASE)/lib

# Find all the C++ files we want to compile
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp')

FRAGMENT_SHADERS := $(shell find $(SHADER_DIR) -name '*.frag')
VERTEX_SHADERS := $(shell find $(SHADER_DIR) -name '*.vert')

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
FRAGMENT_SPV := $(SHADER_SRCS:%=$(FRAGMENT_SHADERS)/%.spv)
VERTEX_SPV := $(SHADER_SRCS:%=$(VERTEX_SHADERS)/%.spv)

# String substitution (suffix version without %).
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to the compiler so that it can find header files
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# preprocessor flags
# The -MMD and -MP flags together generate Makefiles for us!
# These files will have .d instead of .o as the output.
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# Prod flags
PROD_FLAGS := -O2

# Debug flags with -g for debugging information
DEBUG_FLAGS := -g

.PHONY: build clean

build: $(BUILD_DIR)/$(TARGET_EXEC)

# The final build step with debug flags (conditionally)
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS) $(if $(DEBUG),$(DEBUG_FLAGS)) $(if $(PROD),$(PROD_FLAGS))

# Build step for C++ source into object files with debug flags (conditionally)
$(BUILD_DIR)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(if $(DEBUG),$(DEBUG_FLAGS)) $(if $(PROD),$(PROD_FLAGS)) -c $< -o $@


# Build step for shader source into spir-v
build_frag: $(SHADER_DIR)/%.frag.spv
$(SHADER_DIR)/%.frag.spv: %.frag
	$(GLSLC) $< -o $@

build_vert: $(SHADER_DIR)/%.vert.spv
$(SHADER_DIR)/%.vert.spv: %.vert
	$(GLSLC) $< -o $@

build_shaders: build_frag build_vert
clean_shaders: FRAGMENT_SPV VERTEX_SPV
	rm $<

# Rule to run the program
run: $(BUILD_DIR)/$(TARGET_EXEC)
	./$(BUILD_DIR)/$(TARGET_EXEC)

clean:
	rm -r $(BUILD_DIR)

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)

# Rule to build prod flags (set PROD=1 to enable)
prod: PROD := 1
prod: $(BUILD_DIR)/$(TARGET_EXEC)

# Rule to build with debug flags (set DEBUG=1 to enable)
debug: DEBUG := 1
debug: $(BUILD_DIR)/$(TARGET_EXEC)