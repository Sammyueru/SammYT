# (c) Samm see License in LICENSE.txt FILE

CC := gcc
CXX := g++

PROJECT ?= float_compress
OS		?= WIN # WIN, LINUX, MACOS, UNIX, NONE
STATE 	?= RELEASE # RELEASE, DEBUG
ARCH 	?= x64 # x86, x64, ARM, ARM64
TYPE 	?= SOFTWARE # SOFTWARE, OS

SRC     := ./projects/$(PROJECT)/
BUILD   := ./build/$(PROJECT)/
#OBJECTS := ./build/objects/$(PROJECT)/
INCS 	:= -I./shared/inc/
LIBS 	:= -L./shared/lib/$(ARCH)/

ifeq ($(ARCH),x86)
    CFLAGS := -m32 -Wall
    CXXFLAGS := -m32 -std=c++20 -Wall
    ASFLAGS := -f elf
    LDFLAGS := -m elf_i386 -T linker.ld
else ifeq ($(ARCH),x64)
    CFLAGS := -m64 -Wall
    CXXFLAGS := -m64 -std=c++20 -Wall
    ASFLAGS := -f elf64
    LDFLAGS := -m elf_x86_64 -T linker.ld
endif

ifeq ($(OS),WIN)
	OUT := $(BUILD)$(PROJECT).exe
else ifeq ($(OS),LINUX)
	OUT := $(BUILD)$(PROJECT).out
else ifeq ($(OS),MACOS)
    OUT := $(BUILD)$(PROJECT).app
else
	OUT := $(BUILD)$(PROJECT).bin
endif

ASM_SOURCES := $(wildcard $(shell find $(SRC) -name '*.asm'))
C_SOURCES 	:= $(wildcard $(shell find $(SRC) -name '*.c'))
CXX_SOURCES := $(wildcard $(shell find $(SRC) -name '*.cpp'))

ASM_OBJS = $(ASM_SOURCES:.asm=.o)
C_OBJS = $(C_SOURCES:.c=.o)
CXX_OBJS = $(CXX_SOURCES:.cpp=.o)

$(OUT): $(ASM_OBJS)
    $(CC) $(ASFLAGS) -o $@ $^

$(OUT): $(C_OBJS)
    $(CC) $(CFLAGS) -o $@ $^

$(OUT): $(CXX_OBJS)
    $(CXX) $(CXXFLAGS) -o $@ $^

rebuid: clean build
build: $(OUT)
clean:
    rm build
