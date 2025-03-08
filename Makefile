# Propiedades del ejecutable
TARGET = program.exe
VERSION = 0.3.0
COPYRIGHT = "Copyright (C)"

BUILD_TYPE = $(MAKECMDGOALS)
BUILD_TYPE ?= all	# if not defined, default is release

# Rutas del proyecto
COMPILER_DIR 		:= $(dir $(MAKE))
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

# Parametros del compilador
CC 					:= "$(COMPILER_DIR)g++" -B"$(COMPILER_DIR)" 

CFLAGS 				:= -Wall -Wextra  -std=c++17 
ifeq ($(BUILD_TYPE), debug)
	CFLAGS 			+= -g -O0
else
	CFLAGS 			+= -O2
endif
ifeq ($(OS), Windows_NT)
# MinGW Windows API compatibility
	CFLAGS 			+= -lmingw32 -lmingwex	
endif

INCLUDES 			:= -I"$(COMPILER_DIR)include" -static-libgcc -static-libstdc++
LDFLAGS 			:= -L"$(COMPILER_DIR)lib" 

# set all libraries static
#	LDFLAGS += -Wl,-static

################################
# Comandos
ifeq ($(OS), Windows_NT)
    RMDIR 			:= rmdir /s /q
    COPY 			:= xcopy /q /-I /y 
    MKDIR 			:= mkdir
else
    RMDIR 			:= rm -rf
    COPY 			:= cp
    MKDIR 			:= mkdir -p
endif

################################
# Archivos de código (Carpeta /src) y objetos (Carpeta /obj)
SOURCES 			:= $(wildcard $(SRCDIR)/*.cpp)
HEADERS 			:= $(wildcard $(SRCDIR)/*.h*)
OBJS 				:= $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)

# Compilador de recursos (carpeta /res)
RC 					:= "$(COMPILER_DIR)windres"
RESOURCES 			:= $(wildcard $(RESDIR)/*.rc)
OBJS	 			+= $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR)/%.res.o)

################################ Dependencies ################################

-include dependencies/SFML.mk
INCLUDES 			+= $(SFML_INCLUDE)
LDFLAGS 			+= $(SFML_LDFLAGS)
DLLS 				+= $(SFML_DLLS)

################################
# PREREQUISITES
TARGET_PREREQUISITES:=$(OBJDIR) $(BINDIR) $(OBJS) $(foreach file, $(DLLS), $(BINDIR)/$(file))

################################

# Comandos
.PHONY: all debug release clean info

# Main Tasks
all: release
forcerelease: clean_release release
forcedebug: clean_debug debug
debug: release
release:  $(BINDIR)/$(TARGET)

# Create directories
$(OBJDIR) $(BINDIR):
	@mkdir "$@"

# Copy dlls
$(BINDIR)/%.dll: $(SFML_BIN)/%.dll
	$(if $(filter $(notdir $@),$(SFML_DLLS)),@$(COPY) "$(subst /,\,$(SFML_BIN)/$(notdir $@))" "$(subst /,\,$@)",)
#	Añadir las demás DLLs de la misma manera, cambiando SFML_DLLS 

### CREATE EXECUTABLE - Link object files (with -L linker)
$(BINDIR)/$(TARGET): $(TARGET_PREREQUISITES)
	@echo ------ Compiling started: $(TARGET) ------
	$(CC) $(OBJS) $(LDFLAGS) -o $@ \
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

info:
	@echo # DLLS: $(DLLS)
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