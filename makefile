# (c) Samm see License in LICENSE.txt FILE

CC   := gcc
CXX  := g++
ROOT := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

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
INCS 	:= -I$(ROOT)shared/inc/
LIBS 	:= -lmingw32 -L./shared/lib/$(ARCH)/ -lSDL2main -lSDL2 -ldinput8 -ldxguid -ldxerr8 -luser32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -lgdi32

#ifeq ($(OS),WIN)
#	LIBS += -lversion -lgdi32 -limm32
#endif

ifeq ($(ARCH),x86)
	CFLAGS   := -m32 $(INCS) -Wall
	CXXFLAGS := -m32 -std=c++20 $(INCS) -Wall
	ASFLAGS  := -f elf
	LDFLAGS  := -m32 -L./shared/lib/$(ARCH)/
else ifeq ($(ARCH),x64)
	CFLAGS   := -m64 $(INCS) -Wall
	CXXFLAGS := -m64 -std=c++20 $(INCS) -Wall
	ASFLAGS  := -f elf64
	LDFLAGS  := -m64 -L./shared/lib/$(ARCH)/
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

#ASM_SOURCES := $(wildcard $(ROOT)shared/inc/*.asm) $(wildcard $(SRC)*.asm)
#C_SOURCES   := $(wildcard $(ROOT)shared/inc/*.c) $(wildcard $(SRC)*.c)
#CXX_SOURCES := $(wildcard $(ROOT)shared/inc/*.cpp) $(wildcard $(SRC)*.cpp)

ASM_SOURCES := $(wildcard $(shell find $(ROOT)shared/inc/ $(SRC) -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.S'))
C_SOURCES 	:= $(wildcard $(shell find $(ROOT)shared/inc/ $(SRC) -name '*.c'))
#C_SOURCES	+= $(wildcard $(shell find $(ROOT)shared/inc/ -name '*.c'))
CXX_SOURCES := $(wildcard $(shell find $(ROOT)shared/inc/ $(SRC) -name '*.cpp'))
#CXX_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/ -name '*.cpp'))

ASM_OBJS = $(patsubst %.asm,%.o,$(ASM_SOURCES))
C_OBJS   = $(patsubst %.c,%.o,$(C_SOURCES))
CXX_OBJS = $(patsubst %.cpp,%.o,$(CXX_SOURCES))

$(ASM_OBJS) : $(ASM_SOURCES)
	$(CC) $(ASFLAGS) $< -o $^

$(C_OBJS) : $(C_SOURCES)
	$(CC) $(CFLAGS) -c $< -o $@

$(CXX_OBJS) : $(CXX_SOURCES)
	$(CXX) $(CXXFLAGS) -c $< -o $@

create_directories:
	mkdir -p $(BUILD)

$(OUT) : $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS)
	$(CXX) $(LDFLAGS) $^ -o $@ $(INCS) $(LIBS)

.PHONY: one

one: create_directories $(OUT)

rebuild: clean one
clean:
	rm -rf $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(BUILD)

