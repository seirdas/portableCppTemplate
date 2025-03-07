# Propiedades del ejecutable
TARGET = program.exe
VERSION = 0.3.0
COPYRIGHT = "Copyright (C)"

BUILD_TYPE = $(MAKECMDGOALS)
BUILD_TYPE ?= release	# if not defined, default is release

# Rutas del proyecto
COMPILER_DIR 		:= $(dir $(MAKE))
SRCDIR 				:= src
RESDIR 				:= res
OBJDIR_DEBUG 		:= obj/debug
OBJDIR_RELEASE 		:= obj/release
BINDIR_RELEASE 		:= bin/release
BINDIR_DEBUG 		:= bin/debug

ifeq ($(BUILD_TYPE), debug)
	OBJDIR 			:= $(OBJDIR_DEBUG)
	BINDIR 			:= $(BINDIR_DEBUG)
else
	OBJDIR 			:= $(OBJDIR_RELEASE)
	BINDIR 			:= $(BINDIR_RELEASE)
endif

# Parametros del compilador
CC 					:= "$(COMPILER_DIR)g++" -B"$(COMPILER_DIR)" 

CFLAGS 				:= -Wall -Wextra -Wl,--no-undefined -std=c++17 
ifeq ($(BUILD_TYPE), debug)
	CFLAGS 			+= -g -O0
else
	CFLAGS 			+= -O2
endif

INCLUDES 			:= -I"$(COMPILER_DIR)include"
LDFLAGS 			:= -L"$(COMPILER_DIR)lib" -static-libstdc++ -static-libgcc 

################################
# Comandos
ifeq ($(OS), Windows_NT)
    RMDIR 			:= rmdir /s /q
    COPY 			:= xcopy /-I /y 
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

################################
# Comandos
.PHONY: all debug release clean info

# Main Tasks
all: release
debug: release
release: $(OBJDIR) $(BINDIR) $(SFML_DLLS) $(BINDIR)/$(TARGET)

# Create directories
$(OBJDIR) $(BINDIR):
	@mkdir "$@"

# Copy dlls (tested on windows, could be better)
$(SFML_DLLS):
	@$(COPY) "$(subst /,\,$(SFML_BIN)/$@)" "$(subst /,\,$(BINDIR)/$@)"

### CREATE EXECUTABLE - Link object files (with -L linker)
$(BINDIR)/$(TARGET): $(OBJS) $(BINDIR)
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
	@IF EXIST "obj" $(RMDIR) "obj"
	@echo ------ Clean complete!

info:
	@echo # BUILD_TYPE: $(BUILD_TYPE)
	@echo # RESOURCES: $(RESOURCES)
	@echo # OBJS: $(OBJS)
	@echo # INCLUDES: $(INCLUDES)
	@echo # LDFLAGS: $(LDFLAGS)
	@echo # 
	@echo # SFML_INCLUDE: $(SFML_INCLUDE)
	@echo # SFML_LDFLAGS: $(SFML_LDFLAGS)
	@echo # SFML_DLLS: $(SFML_DLLS)
