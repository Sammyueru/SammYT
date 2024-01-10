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

#define PKG_CONFIG
#export

PKG_CONFIG_PATH := "$(ROOT)shared/lib/$(ARCH)/pkgconfig"
export PKG_CONFIG_PATH

SRC     := ./projects/$(PROJECT)/
BUILD   := ./build/$(PROJECT)/$(ARCH)_$(STATE)/
INCS    := -I"$(ROOT)shared/inc/"
LIBS    := -lmingw32 -L"$(ROOT)shared/lib/$(ARCH)" -lSDL2 -lSDL2main -limgui.dll -mwindows -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid
#`pkg-config --static --libs sdl2`
#LIBS    := -Wl,--start-group -L./shared/lib/$(ARCH)/ -lSDL2main -lSDL2 -Wl,--end-group
# -L$(ROOT)shared/lib/$(ARCH)/ -limgui
#BLIBS   := -limgui
# $(shell pkg-config --cflags --libs sdl2) 
#ifeq ($(OS),WIN)
#	LIBS += -lversion -lgdi32 -limm32
#endif

ifeq ($(ARCH),x86)
	CFLAGS   := -m32 $(INCS) -Wall
	CXXFLAGS := -m32 -std=c++20 -MMD -MP -pthread $(INCS) -Wall
	ASFLAGS  := -m32 -f elf
	LDFLAGS  := -m32
else ifeq ($(ARCH),x64)
	CFLAGS   := -m64 $(INCS) -Wall
	CXXFLAGS := -m64 -std=c++20 -MMD -MP -pthread $(INCS) -Wall
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

#ASM_SOURCES := $(wildcard $(shell find "$(SRC)" -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.asm'))
ASM_SOURCES := $(wildcard $(ROOT)shared/inc/**/*.asm) $(wildcard $(ROOT)shared/inc/**/*.S) $(wildcard $(SRC)**/*.asm) $(wildcard $(SRC)**/*.S)
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.asm'))
#ASM_SOURCES += $(wildcard $(shell find $(ROOT)shared/inc/* -name '*.S'))
#C_SOURCES 	:= $(wildcard $(shell find "$(SRC)" -name '*.c'))
#C_SOURCES 	+= $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.c'))
C_SOURCES := \
	$(wildcard $(ROOT)shared/inc/**/*.c) \
	$(wildcard $(SRC)**/*.c)
#C_SOURCES	+= $(wildcard $(shell find $(ROOT)shared/inc/ -name '*.c'))

IMGUISRC    := $(wildcard $(shell find "$(ROOT)shared/inc/imgui/" -name '*.cpp'))

#IMGUISRC    := $(filter-out $(ROOT)shared/inc/imgui/added_by_samm.cpp, $(wildcard $(ROOT)shared/inc/imgui/*.cpp))
#IMGUISRC    += $(ROOT)shared/inc/imgui/added_by_samm.cpp
#CXX_SOURCES := $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.cpp'))
#CXX_SOURCES += $(wildcard $(shell find "$(SRC)" -name '*.cpp'))
CXX_SOURCES := \
	$(wildcard $(ROOT)shared/inc/**/*.cpp) \
	$(wildcard $(SRC)*.cpp) \
	$(wildcard $(SRC)**/*.cpp)
#	$(wildcard $(ROOT)shared/inc/**/*.cpp)

#CXI_SOURCES := $(wildcard $(shell find "$(ROOT)shared/inc/" -name '*.cpp'))

# Change to INC_SOURCES:
CXX_SOURCES := $(filter-out $(wildcard $(ROOT)shared/inc/imgui/**.cpp), $(CXX_SOURCES)) #$(filter-out $(IMGUISRC), $(CXX_SOURCES))

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

ASM_OBJS  := $(patsubst %.asm,$(BUILD)objects/%.asm.o,$(notdir $(ASM_SOURCES)))
C_OBJS    := $(patsubst %.c,$(BUILD)objects/%.c.o,$(notdir $(C_SOURCES)))
CXX_OBJS  := $(patsubst %.cpp,$(BUILD)objects/%.cpp.o,$(notdir $(CXX_SOURCES)))
#CXI_OBJS  := $(patsubst %.cpp,%.cpp.o,$(CXI_SOURCES))
#C_OBJS    := $(patsubst %.c,%.c.o,$(CNEW_ALL_SRC))
#CXX_OBJS  := $(patsubst %.cpp,%.cpp.o,$(CNEW_ALL_SRC))

IMGUIOBJS := $(patsubst %.cpp,$(BUILD)objects/%.imgui.o,$(IMGUISRC))
#IMGUIOBJ  := "$(ROOT)shared/inc/imgui/dear.imgui.o"

IMGUI_DLL := "$(ROOT)shared/lib/$(ARCH)/imgui.dll"
IMGUI_DLL_A := "$(ROOT)shared/lib/$(ARCH)/libimgui.dll.a"

$(ASM_OBJS): $(ASM_SOURCES)
	$(CC) $(ASFLAGS) -c $< -o $@

$(C_OBJS): $(C_SOURCES)
	$(CC) $(CFLAGS) -c $< -o $@

#$(CXI_OBJS): $(CXI_SOURCES)
#	$(CXX) $(CXXFLAGS) -c $< -o $@

$(IMGUIOBJS): $(IMGUISRC)
	$(CXX) $(CXXFLAGS) -c $< -o $@
#-lSDL2main -lSDL2

#$(IMGUIOBJ): $(IMGUIOBJS)
#	ar rcs $@ $^
#	$(CXX) $(LDFLAGS) $(INCS) $^ -o $@ $(LIBS)

#-include $(C_OBJS:.o=.d)
#-include $(CXX_OBJS:.o=.d)
#-include $(ASM_OBJS:.o=.d)

$(CXX_OBJS): $(CXX_SOURCES)
	$(CXX) $(CXXFLAGS) -c $< -o $@

create_directories:
	mkdir -p $(BUILD) $(foreach file,$(IMGUIOBJS),$(shell dirname $(file))) $(foreach file,$(ASM_OBJS),$(shell dirname $(file))) $(foreach file,$(C_OBJS),$(shell dirname $(file))) $(foreach file,$(CXX_OBJS),$(shell dirname $(file)))

#"$(ROOT)shared/lib/$(ARCH)/libimgui.a": $(IMGUIOBJS)
#	$(CXX) $(LDFLAGS) -shared -o $@ $^
#	ar rcs $@ $^

$(IMGUI_DLL): $(IMGUISRC)
	$(CXX) $(LDFLAGS) -mwindows $(INCS) -shared -o $@ $^ -L"$(ROOT)shared/lib/$(ARCH)" -lSDL2 -lSDL2main

$(IMGUI_DLL_A): $(IMGUI_DLL)
	$(CC) -shared -Wl,--out-implib,$(IMGUI_DLL_A) $<

build_libs: create_directories $(IMGUI_DLL_A) #"$(ROOT)shared/lib/$(ARCH)/libimgui.a"

$(OUT): $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(IMGUI_DLL) # $(IMGUIOBJS)
	$(CXX) $(LDFLAGS) $(INCS) $^ -o $@ $(LIBS)
	cp $(IMGUI_DLL) $(dir $(OUT))

#$(ASM_OBJS) $(CNEW_ALL_SRC) $(CPPNEW_ALL_SRC)

#.PHONY:

test:
	@echo $(CXX_SOURCES)
	@echo $(PKG_CONFIG_PATH)
	pkg-config --libs sdl2

one: create_directories $(OUT)
#one_all: build_libs one

rebuild: clean one

clean_objs:
	rm -rf $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(CPPNEW_ALL_SRC) $(CNEW_ALL_SRC) $(wildcard $(IMGUIOBJS)) $(IMGUIOBJ) 
#	$(C_OBJS:.o=.d) $(CXX_OBJS:.o=.d) $(ASM_OBJS:.o=.d)

clean-objs: clean_objs

clean:
	rm -rf $(ASM_OBJS) $(C_OBJS) $(CXX_OBJS) $(CPPNEW_ALL_SRC) $(CNEW_ALL_SRC) $(wildcard $(IMGUIOBJS)) $(IMGUIOBJ) $(BUILD)
#	$(C_OBJS:.o=.d) $(CXX_OBJS:.o=.d) $(ASM_OBJS:.o=.d) 

clean_libs:
	rm -rf $(IMGUI_DLL) $(IMGUI_DLL_A)

clean_with_libs:
	clean
	clean_libs

#EOF
