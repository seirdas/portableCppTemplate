############### Compilation properties ###############
TARGET = program.exe
VERSION = 0.3.0
COPYRIGHT = "Copyright (C)"

BUILD_TYPE = $(MAKECMDGOALS)
BUILD_TYPE ?= all	# if not defined, default is release

LIBS ?= dynamic

############### Compiler paths ###############
COMPILER_DIR 		:= $(abspath $(MAKE)/../..)/
COMPILER_BIN		:= $(COMPILER_DIR)/bin
CC 					:= "$(COMPILER_BIN)/g++" -B"$(COMPILER_BIN)" 
RC 					:= "$(COMPILER_BIN)/windres"

############### Project paths ###############
SRCDIR 				:= src
RESDIR 				:= res
OBJDIR_DEBUG 		:= obj/debug
OBJDIR_RELEASE 		:= obj/release
BINDIR_RELEASE 		:= bin/release
BINDIR_DEBUG 		:= bin/debug

ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	OBJDIR 			:= $(OBJDIR_DEBUG)
	BINDIR 			:= $(BINDIR_DEBUG)
else
	OBJDIR 			:= $(OBJDIR_RELEASE)
	BINDIR 			:= $(BINDIR_RELEASE)
endif

############### Compiler params ###############
CFLAGS 				:= -Wall -Wextra -std=c++17
ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	CFLAGS 			+= -g -O0
else
	CFLAGS 			+= -O2
endif
ifeq ($(OS), Windows_NT)
# MinGW Windows API compatibility
	CFLAGS 			+= -lmingw32 -lmingwex	
endif

INCLUDES 			:= -I"$(COMPILER_DIR)include" 
COMPILER_LIBS		:= $(wildcard $(COMPILER_DIR)/lib)
COMPILER_DLLS 		:= $(notdir $(wildcard $(COMPILER_BIN)/*.dll))
LDFLAGS				:= $(foreach ldlib, $(COMPILER_LIBS), -L"$(ldlib)")
# LDFLAGS 			+= -Wl,-Bstatic -static-libgcc -static-libstdc++

MINGW_LIBS			+= $(wildcard $(COMPILER_DIR)*/lib)
MINGW_BIN			+= $(wildcard $(COMPILER_DIR)*/bin)
MINGW_DLLS 			:= $(notdir $(wildcard $(MINGW_DLLS_PATHS)/*.dll))
LDFLAGS 			+= $(foreach ldlib, $(MINGW_LIBS), -L"$(ldlib)")

# LDFLAGS 			+= -static-libgcc -static-libstdc++

############### Commands ###############
ifeq ($(OS), Windows_NT)
    RMDIR 			:= rmdir /s /q
    COPY 			:= xcopy /-I /y 
    MKDIR 			:= mkdir
else
    RMDIR 			:= rm -rf
    COPY 			:= cp
    MKDIR 			:= mkdir -p
endif

############### Files ###############
# source files (/src folder) and objects (/obj folder)
SOURCES 			:= $(wildcard $(SRCDIR)/*.cpp)
HEADERS 			:= $(wildcard $(SRCDIR)/*.h*)
OBJS 				:= $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)

# resource compiler (carpeta /res)
RESOURCES 			:= $(wildcard $(RESDIR)/*.rc)
OBJS	 			+= $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR)/%.res.o)

############### Dependencies ###############
# comment those that you don't need
-include dependencies/SFML.mk
-include dependencies/wxWidgets.mk


############### Pre-requisites ###############
TARGET_PREREQUISITES:=$(OBJDIR) $(BINDIR) $(OBJS) 
# dlls
ifeq ($(findstring dynamic, $(LIBS)), dynamic)
	TARGET_PREREQUISITES += $(foreach file, $(DLLS), $(BINDIR)/$(file))
endif

############### Rules ###############
.PHONY: all debug release clean info

all: release clean
forcerelease: clean_release release
forcedebug: clean_debug debug
debug: release
release:  $(BINDIR)/$(TARGET)

# Create directories
$(OBJDIR) $(BINDIR):
	@mkdir "$@"

# Copy dlls
$(BINDIR)/%.dll:
	$(if $(filter $(notdir $@),$(COMPILER_DLLS)),\
		@$(COPY) "$(subst /,\,$(COMPILER_BIN)/$(notdir $@))" "$(subst /,\,$@)",)
	$(if $(filter $(notdir $@),$(MINGW_DLLS)),\
		@$(COPY) "$(subst /,\,$(MINGW_BIN)/$(notdir $@))" "$(subst /,\,$@)",)
	$(if $(filter $(notdir $@),$(SFML_DLLS)),\
		@$(COPY) "$(subst /,\,$(SFML_BIN)/$(notdir $@))" "$(subst /,\,$@)",)
# 	Add other DLLs in the same way, changing DLLS list and folder

### CREATE EXECUTABLE - Link object files (with -L linker)
$(BINDIR)/$(TARGET): $(TARGET_PREREQUISITES)
	@echo ------ Compiling started: $(TARGET) ------
	$(CC) $(OBJS) $(LDFLAGS) $(LINKS) -o $@  \
		-DVERSION=\"$(VERSION)\" -DCOPYRIGHT=\"$(COPYRIGHT)\"
	@echo ------ Compilation complete! ------

# Compile each .cpp file to a .o object file ( with -I includes )
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(HEADERS)
	@echo ------ Compiling $< to $@...
	$(CC) -c $< -o $@  $(CFLAGS) $(INCLUDES)

# Compile the resource files
$(OBJDIR)/%.res.o: $(RESDIR)/%.rc
	@echo ------ Compiling release res file $@...
	$(RC) $< -o $@

# Clean up generated files
clean:
	@IF EXIST "$(BINDIR_DEBUG)" $(RMDIR) "$(BINDIR_DEBUG)"
	@IF EXIST "$(OBJDIR_DEBUG)" $(RMDIR) "$(OBJDIR_DEBUG)"
	@IF EXIST "$(OBJDIR_RELEASE)" $(RMDIR) "$(OBJDIR_RELEASE)"
	@IF EXIST "obj" $(RMDIR) "obj"
	@echo ------ Clean complete!

clean_release: 
	@IF EXIST "$(BINDIR_RELEASE)" $(RMDIR) "$(BINDIR_RELEASE)"
	@IF EXIST "$(OBJDIR_RELEASE)" $(RMDIR) "$(OBJDIR_RELEASE)"
	@echo ------ Cleaned previous release compilations

clean_debug:
	@IF EXIST "$(BINDIR_DEBUG)" $(RMDIR) "$(BINDIR_DEBUG)"
	@IF EXIST "$(OBJDIR_DEBUG)" $(RMDIR) "$(OBJDIR_DEBUG)"
	@echo ------ Cleaned previous debug compilations

# Show info
info:
	@echo # TARGET_PREREQUISITES: $(TARGET_PREREQUISITES)
	@echo # 
	@echo # BUILD_TYPE: $(BUILD_TYPE)
	@echo # RESOURCES: $(RESOURCES)
	@echo # OBJS: $(OBJS)
	@echo # INCLUDES: $(INCLUDES)
	@echo # LDFLAGS: $(LDFLAGS)
	@echo # 
	@echo # SFML_INCLUDE: $(SFML_INCLUDE)
	@echo # SFML_LDFLAGS: $(SFML_LDFLAGS)
	@echo # SFML_DLLS: $(SFML_DLLS)