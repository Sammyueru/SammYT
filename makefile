# (c) Samm see License in LICENSE.txt FILE

CC := gcc
CXX := g++

PROJECT ?= float_compress
# WIN, LINUX, MACOS, UNIX, NONE
OS		?= WIN
 # RELEASE, DEBUG
STATE 	?= RELEASE
# x86, x64, ARM, ARM64
ARCH 	?= x64
# SOFTWARE, OS
TYPE 	?= SOFTWARE

SRC     := ./projects/$(PROJECT)/
BUILD   := ./build/$(PROJECT)/$(ARCH)/$(STATE)/
INCS 	:= -I./shared/inc/
LIBS 	:= -L./shared/lib/$(ARCH)/

ifeq ($(ARCH),x86)
    CFLAGS := -m32 $(INCS) -Wall
    CXXFLAGS := -m32  $(INCS) -std=c++20 -Wall
    ASFLAGS := -f elf
    LDFLAGS := -m elf_i386 -T linker.ld
else ifeq ($(ARCH),x64)
    CFLAGS := -m64 $(INCS) -Wall
    CXXFLAGS := -m64 $(INCS) -std=c++20 -Wall
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

$(ASM_OBJS): $(ASM_SOURCES)
	$(CC) $(ASFLAGS) -o $@ $^

$(C_OBJS): $(C_SOURCES)
	$(CC) $(CFLAGS) $(INCS) -c -o $@ $^

$(CXX_OBJS): $(CXX_SOURCES)
	$(CXX) $(CXXFLAGS) $(INCS) -c -o $@ $^

$(OUT): $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS)
	$(CXX) $(LDFLAGS) $(LIBS) -o $@ $^

build:
	mkdir -p $(BUILD)
	$(OUT)
rebuild: clean build
clean:
	rm -rf $(ASM_OBJS)
	rm -rf $(C_OBJS)
	rm -rf $(CXX_OBJS)
	rm -rf $(BUILD)

