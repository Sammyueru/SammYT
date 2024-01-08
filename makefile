# (c) Samm see License in LICENSE.txt FILE

CC   := gcc
CXX  := g++

ifeq ($(OS),Windows_NT)
    ROOT := $(shell cd)
else
	ROOT := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
endif

PROJECT ?=float_compress
# WIN, LINUX, MACOS, UNIX, NONE
OSS		?=WIN
 # RELEASE, DEBUG
STATE 	?=RELEASE
# x86, x64, ARM, ARM64
ARCH 	?=x64
# SOFTWARE, OS
TYPE 	?=SOFTWARE

export PKG_CONFIG_PATH := "$(ROOT)shared/lib/$(ARCH)/pkgconfig/"

SRC     := ./projects/$(PROJECT)/
BUILD   := ./build/$(PROJECT)/$(ARCH)_$(STATE)/
INCS    := -I"$(ROOT)shared/inc/"
LIBS    := $(shell pkg-config --static --libs sdl2) -lmingw32 -L"$(ROOT)shared/lib/$(ARCH)" -lSDL2main -mwindows -lSDL2 -lversion -lgdi32 -limm32 -lstdc++
#`pkg-config --static --libs sdl2`
#LIBS    := -Wl,--start-group -L./shared/lib/$(ARCH)/ -lSDL2main -lSDL2 -Wl,--end-group
# -L$(ROOT)shared/lib/$(ARCH)/ -limgui
#BLIBS   := -limgui

#ifeq ($(OS),WIN)
#	LIBS += -lversion -lgdi32 -limm32
#endif

ifeq ($(ARCH),x86)
	CFLAGS   := -m32 $(INCS) -Wall
	CXXFLAGS := -m32 -std=c++20 -MMD -MP $(INCS) -Wall
	ASFLAGS  := -m32 -f elf
	LDFLAGS  := -m32
else ifeq ($(ARCH),x64)
	CFLAGS   := -m64 $(INCS) -Wall
	CXXFLAGS := -m64 -std=c++20 -MMD -MP $(INCS) -Wall
	ASFLAGS  := -m64 -f elf64
	LDFLAGS  := -m64
endif
#`pkg-config --cflags sdl2`
# LDFLAGS  += -m elf_i386 -T linker.ld
# LDFLAGS  += -m elf_x86_64 -T linker.ld

OUT     := $(BUILD)$(PROJECT).exe
ifeq ($(OSS),WIN)
	OUT := $(BUILD)$(PROJECT).exe
else ifeq ($(OSS),LINUX)
	OUT := $(BUILD)$(PROJECT).out
else ifeq ($(OSS),MACOS)
	OUT := $(BUILD)$(PROJECT).app
else
	OUT := $(BUILD)$(PROJECT).bin
endif

#ASM_SOURCES := $(wildcard $(ROOT)shared/inc/*.asm) $(wildcard $(SRC)*.asm)
#C_SOURCES   := $(wildcard $(ROOT)shared/inc/*.c) $(wildcard $(SRC)*.c)
#CXX_SOURCES := $(wildcard $(ROOT)shared/inc/*.cpp) $(wildcard $(SRC)*.cpp)

ASM_SOURCES := $(wildcard $(shell find $(SRC) -name '*.asm'))
ASM_SOURCES += $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.S'))
C_SOURCES 	:= $(wildcard $(shell find $(SRC) -name '*.c'))
C_SOURCES 	+= $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.c'))
#C_SOURCES	+= $(wildcard $(shell find $(ROOT)shared/inc/ -name '*.c'))
IMGUISRC    := $(wildcard "$(ROOT)shared/inc/imgui/*.cpp")
#IMGUISRC    := $(filter-out $(ROOT)shared/inc/imgui/added_by_samm.cpp, $(wildcard $(ROOT)shared/inc/imgui/*.cpp))
#IMGUISRC    += $(ROOT)shared/inc/imgui/added_by_samm.cpp
CXX_SOURCES := $(wildcard $(shell find $(SRC) -name '*.cpp'))
CXX_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/ -name '*.cpp'))
#CXI_SOURCES := $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.cpp'))
CXX_SOURCES := $(filter-out $(IMGUISRC), $(CXX_SOURCES))

C_ALL_SRC	   := $(C_SOURCES)
CPP_ALL_SRC    := $(CXX_SOURCES) $(IMGUISRC)
#CPPNEW_ALL_SRC := $(patsubst %.cpp,%.new.cpp,$(CPP_ALL_SRC))
#CNEW_ALL_SRC   := $(patsubst %.c,%.new.c,$(C_ALL_SRC))

#$(CNEW_ALL_SRC): $(C_ALL_SRC)
#	$(CXX) $(CFLAGS) -E -DSDL_MAIN_HANDLED $< -o $@
#
#$(CPPNEW_ALL_SRC): $(CPP_ALL_SRC)
#	$(CXX) $(CXXFLAGS) -E -DSDL_MAIN_HANDLED -E -Dmain=SDL_main $< -o $@

#preprocess: $(CNEW_ALL_SRC) $(CPPNEW_ALL_SRC)

ASM_OBJS  := $(patsubst %.asm,%.asm.o,$(ASM_SOURCES))
C_OBJS    := $(patsubst %.c,%.c.o,$(C_SOURCES))
CXX_OBJS  := $(patsubst %.cpp,%.cpp.o,$(CXX_SOURCES))
CXI_OBJS  := $(patsubst %.cpp,%.cpp.o,$(CXI_SOURCES))
#C_OBJS    := $(patsubst %.c,%.c.o,$(CNEW_ALL_SRC))
#CXX_OBJS  := $(patsubst %.cpp,%.cpp.o,$(CNEW_ALL_SRC))

IMGUIOBJS := $(patsubst %.cpp,%.imgui.o,$(IMGUISRC))
IMGUIOBJ  := "$(ROOT)shared/inc/imgui/dear.imgui.o"

$(ASM_OBJS): $(ASM_SOURCES)
	$(CC) $(ASFLAGS) -c $< -o $@

$(C_OBJS): $(C_SOURCES)
	$(CC) $(CFLAGS) -c $< -o $@

$(CXI_OBJS): $(CXI_SOURCES)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(IMGUIOBJS): $(IMGUISRC)
	$(CXX) $(CXXFLAGS) -c $< -o $@
#-lSDL2main -lSDL2

$(IMGUIOBJ): $(IMGUIOBJS)
	$(CXX) $(LDFLAGS) $(INCS) $^ -o $@ $(LIBS)
#	ar rcs $@ $^

-include $(C_OBJS:.o=.d)
-include $(CXX_OBJS:.o=.d)
-include $(ASM_OBJS:.o=.d)

$(CXX_OBJS): $(CXX_SOURCES)
	$(CXX) $(CXXFLAGS) -c $< -o $@

create_directories:
	mkdir -p $(BUILD)

#$(ROOT)shared/lib/$(ARCH)/libimgui.a: $(IMGUIOBJS)
#	ar rcs $@ $^

build_libs: $(ROOT)shared/lib/$(ARCH)/libimgui.a

$(OUT): $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(IMGUIOBJ)
	$(CXX) $(LDFLAGS) $(INCS) $^ -o $@ -lmingw32 $(LIBS)

#$(ASM_OBJS) $(CNEW_ALL_SRC) $(CPPNEW_ALL_SRC)

.PHONY:

one: create_directories $(OUT)
#one_all: build_libs one

rebuild: clean one

clean_objs:
	rm -rf $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(CPPNEW_ALL_SRC) $(CNEW_ALL_SRC) $(wildcard $(IMGUIOBJS)) $(IMGUIOBJ) $(C_OBJS:.o=.d) $(CXX_OBJS:.o=.d) $(ASM_OBJS:.o=.d)

clean-objs: clean_objs

clean:
	rm -rf $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(CPPNEW_ALL_SRC) $(CNEW_ALL_SRC) $(wildcard $(IMGUIOBJS)) $(IMGUIOBJ) $(C_OBJS:.o=.d) $(CXX_OBJS:.o=.d) $(ASM_OBJS:.o=.d) $(BUILD)

clean_libs:
	rm -rf $(ROOT)shared/lib/$(ARCH)/libimgui.a

clean_with_libs:
	clean
	clean_libs

#EOF
