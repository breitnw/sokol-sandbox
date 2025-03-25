##
# sokol-sandbox-c
#
# @file
# @version 0.1

CFLAGS := -std=c2x -Wall -Wextra -pthread
LDFLAGS := -lGL -ldl -lm -lX11 -lasound -lXi -lXcursor

TARGET_EXEC := sandbox
BUILD_DIR := out
SRC_DIR := src

# GENERATED CODE ======================================================

# Find all the GLSL files we want to compile
SHADER_SRCS := $(shell find $(SRC_DIR) -name '*.glsl')
SHADER_GENS := $(SHADER_SRCS:.glsl=.glsl.h)

# Build step for shaders
%.glsl.h: %.glsl
	sokol-shdc -i $< -l "glsl430" -o $@

# EXECUTABLE ==========================================================

# Find all the C files we want to compile
SRCS := $(shell find $(SRC_DIR) -name '*.c')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# The -MMD and -MP flags together generate Makefiles, looking
# at #includes and specifying them as dependencies
CPPFLAGS := $(INC_FLAGS) -MMD -MP
DEPS := $(OBJS:.o=.d)

# Build step for the executable
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Build step for C source
# FIXME should not recompile all when shaders are changed
# This should be automatic, why isn't it?
$(BUILD_DIR)/%.c.o: %.c shaders
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# PHONY TARGETS =======================================================

.PHONY: all shaders clean

all: $(BUILD_DIR)/$(TARGET_EXEC)
shaders: $(SHADER_GENS)
clean:
	rm -r $(BUILD_DIR)
	rm $(shell find $(SRC_DIR) -name '*.glsl.h')
# end

# include the .d makefiles
-include $(DEPS)
