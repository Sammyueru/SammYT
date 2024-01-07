# (c) Samm see License in LICENSE.txt FILE

CC := gcc
CXX := g++

PROJECT ?=float_compress
# WIN, LINUX, MACOS, UNIX, NONE
OS		?=WIN
 # RELEASE, DEBUG
STATE 	?=RELEASE
# x86, x64, ARM, ARM64
ARCH 	?=x64
# SOFTWARE, OS
TYPE 	?=SOFTWARE

SRC     := ./projects/$(PROJECT)/
BUILD   := ./build/$(PROJECT)/$(ARCH)_$(STATE)/
INCS 	:= -I./shared/inc/
LIBS 	:= -L./shared/lib/$(ARCH)/ -lmingw32 -lSDL2main -lSDL2

ifeq ($(OS),WIN)
	LIBS += -lversion -lgdi32 -limm32
endif

ifeq ($(ARCH),x86)
	CFLAGS   := -m32 $(INCS) -Wall
	CXXFLAGS := -m32  $(INCS) -std=c++20 -Wall
	ASFLAGS  := -f elf
	LDFLAGS  := 
else ifeq ($(ARCH),x64)
	CFLAGS   := -m64 $(INCS) -Wall
	CXXFLAGS := -m64 $(INCS) -std=c++20 -Wall
	ASFLAGS  := -f elf64
	LDFLAGS  := 
endif
# LDFLAGS  += -m elf_i386 -T linker.ld
# LDFLAGS  += -m elf_x86_64 -T linker.ld

OUT := $(BUILD)$(PROJECT).exe
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

$(ASM_OBJS) : $(ASM_SOURCES)
	$(CC) $(ASFLAGS) -o $@ $^

$(C_OBJS) : $(C_SOURCES)
	$(CC) $(CFLAGS) $(INCS) -c -o $@ $^

$(CXX_OBJS) : $(CXX_SOURCES)
	$(CXX) $(CXXFLAGS) $(INCS) -c -o $@ $^

create_directories:
	mkdir -p $(BUILD)

$(OUT) : $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS)
	$(CXX) $(LDFLAGS) $(LIBS) -o $@ $^

.PHONY: 

one: create_directories $(OUT)

rebuild: clean create_directories one
clean:
	rm -rf $(ASM_OBJS)
	rm -rf $(C_OBJS)
	rm -rf $(CXX_OBJS)
	rm -rf $(BUILD)

