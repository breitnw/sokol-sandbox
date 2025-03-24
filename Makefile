##
# sokol-sandbox-c
#
# @file
# @version 0.1

CFLAGS := -std=c2x -Wall -Wextra

TARGET_EXEC := sandbox
BUILD_DIR := out
SRC_DIR := src

# GENERATED CODE ======================================================

SHADER_SRC_DIR := $(SRC_DIR)/shaders
SHADER_GEN_DIR := $(SRC_DIR)/generated

# Find all the GLSL files we want to compile
SHADER_SRCS := $(shell find $(SHADER_SRC_DIR) -name '*.glsl')
SHADER_GENS := $(SHADER_SRCS:$(SHADER_SRC_DIR)/%.glsl=$(SHADER_GEN_DIR)/%.glsl.h)

# Build step for shaders
$(SHADER_GEN_DIR)/%.glsl.h: $(SHADER_SRC_DIR)/%.glsl
	mkdir -p $(dir $@)
	sokol-shdc --input $< --output $@ --slang glsl430

# EXECUTABLE ==========================================================

# Find all the C files we want to compile
SRCS := $(shell find $(SRC_DIR) -name '*.c')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# Directories to include
SHADER_SRC_DIRS := $(shell find $(SHADER_SRC_DIR) -type d)
SHADER_GEN_DIRS := $(SHADER_SRC_DIRS:$(SHADER_SRC_DIR)=$(SHADER_GEN_DIR))
INC_DIRS := $(shell find $(SRC_DIR) -type d) $(SHADER_GEN_DIRS)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

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

.PHONY: clean all shaders
all: $(BUILD_DIR)/$(TARGET_EXEC)
clean:
	rm -r $(BUILD_DIR)
	rm -r $(SHADER_GEN_DIR)
shaders: $(SHADER_GENS)

# include the .d makefiles
-include $(DEPS)
# end
