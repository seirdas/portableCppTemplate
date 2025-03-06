# Propiedades del ejecutable
TARGET = program.exe
VERSION = 0.2
COPYRIGHT = "Copyright (C)"

# Rutas del proyecto
COMPILER_DIR := $(dir $(MAKE))
SRCDIR = src
OBJDIR = obj
BINDIR = bin
RESDIR = res
OBJDIR_RELEASE = $(OBJDIR)/release
OBJDIR_DEBUG = $(OBJDIR)/debug
BINDIR_RELEASE = $(BINDIR)/release
BINDIR_DEBUG = $(BINDIR)/debug

# Parametros del compilador
CC = "$(COMPILER_DIR)g++" -B"$(COMPILER_DIR)"
CFLAGS = -Wall -Wextra -Wl,--no-undefined -std=c++17 -I"$(COMPILER_DIR)include"
LDFLAGS = -L"$(COMPILER_DIR)lib" -static-libstdc++ 

# Comandos
# Check for Windows
ifeq ($(OS), Windows_NT)
    RMDIR 	:= rmdir /s /q
    COPY 	:= xcopy /-I /y 
    MKDIR 	:= mkdir
else
    RMDIR 	:= rm -rf
    COPY 	:= cp
    MKDIR 	:= mkdir -p
endif

# Archivos de código (Carpeta /src) y objetos (Carpeta /obj)
SOURCES := $(wildcard $(SRCDIR)/*.cpp)
HEADERS := $(wildcard $(SRCDIR)/*.h*)
OBJS_RELEASE := $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR_RELEASE)/%.o)
OBJS_DEBUG := $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR_DEBUG)/%.o)

# Compilador de recursos (carpeta /res)
RC = "$(COMPILER_DIR)windres"
RESOURCES := $(wildcard $(RESDIR)/*.rc)
OBJS_RES_RELEASE := $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR_RELEASE)/%.res.o)
DEBUG_RES_OBJECTS := $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR_DEBUG)/%.res.o)

# Parametros de linker SFML para librerías dinámicas
SFML_INCLUDE 				:= -I$(wildcard dependencies/SFML*/SFML*/include)
SFML_LIB					:= $(wildcard dependencies/SFML*/SFML*/lib)

# SFML3_RELEASE_LIBS		:= System Window Graphics Audio Network
# SFML3_DEBUG_LIBS			:= $(foreach lib,$(SFML3_RELEASE_LIBS),$(lib)-d)
SFML2_RELEASE_LIBS			:= sfml-system sfml-window sfml-graphics sfml-audio sfml-network
SFML2_DEBUG_LIBS			:= $(foreach lib,$(SFML2_RELEASE_LIBS),$(lib)-d)

SFML2_RELEASE_LDFLAGS 		:= -L$(SFML_LIB) $(foreach lib,$(SFML2_RELEASE_LIBS),-l$(lib))
SFML2_DEBUG_LDFLAGS 		:= -L"$(SFML_LIB)" $(foreach lib,$(SFML2_DEBUG_LIBS),-l$(lib))

# SFML3_RELEASE_LDFLAGS 	:= -L$(SFML_LIB) $(foreach lib,$(SFML3_RELEASE_LIBS),-l$(lib))
# SFML3_DEBUG_LDFLAGS 		:= -L"$(SFML_LIB)" $(foreach lib,$(SFML3_DEBUG_LIBS),-l$(lib))

SFML_BIN					:= $(wildcard dependencies/SFML*/SFML*/bin)
SFML_DLLS					:= $(notdir $(wildcard $(SFML_BIN)/*.dll))
SFML_RELEASE_DLLS 			:= $(foreach file, $(SFML_DLLS), $(if $(findstring -d-, $(file)),, $(file)))
SFML_DEBUG_DLLS 			:= $(foreach file, $(SFML_DLLS), $(if $(findstring -d-, $(file)), $(file)))


################################
# Comandos
.PHONY: all debug release clean info

# Main Tasks
all: release clean

release: $(OBJDIR_RELEASE) $(BINDIR_RELEASE) $(SFML_RELEASE_DLLS) $(BINDIR_RELEASE)/$(TARGET)

debug: CFLAGS += -g -O0
debug: $(OBJDIR_DEBUG) $(BINDIR_DEBUG) $(SFML_DEBUG_DLLS) $(BINDIR_DEBUG)/$(TARGET)

# Create directories
$(OBJDIR_RELEASE) $(BINDIR_RELEASE) $(OBJDIR_DEBUG) $(BINDIR_DEBUG):
	@mkdir "$@"

# Copy dlls (tested on windows, could be better)
$(SFML_DEBUG_DLLS):
	@$(COPY) "$(subst /,\,$(SFML_BIN)/$@)" "$(subst /,\,$(BINDIR_DEBUG)/$@)"
$(SFML_RELEASE_DLLS):
	@$(COPY) "$(subst /,\,$(SFML_BIN)/$@)" "$(subst /,\,$(BINDIR_RELEASE)/$@)" 

# Link the object files to create the executable (with -L linker)
$(BINDIR_RELEASE)/$(TARGET): $(OBJS_RELEASE) $(OBJS_RES_RELEASE)
	@echo ------ Release compiling started: $(TARGET) ------
	$(CC) $(OBJS_RELEASE) $(OBJS_RES_RELEASE) $(LDFLAGS) $(SFML2_RELEASE_LDFLAGS) -o $@ \
		-DVERSION=\"$(VERSION)\" -DCOPYRIGHT=\"$(COPYRIGHT)\"
	@echo ------ Release compilation complete!

$(BINDIR_DEBUG)/$(TARGET): $(OBJS_DEBUG) $(DEBUG_RES_OBJECTS) $(SFML_DEBUG_DLLS)
	@echo ------ Debug compiling started: $(TARGET) ------
	$(CC) $(OBJS_DEBUG) $(DEBUG_RES_OBJECTS) $(LDFLAGS) $(SFML2_DEBUG_LDFLAGS) -o $@  \
		-DVERSION=\"$(VERSION)\" -DCOPYRIGHT=\"$(COPYRIGHT)\"
	@echo ------ Debug compilation complete! ------

# Compile each .cpp file to a .o object file ( with -I includes )
$(OBJDIR_RELEASE)/%.o: $(SRCDIR)/%.cpp | $(HEADERS)
	@echo ------ Compiling $< to $@...
	$(CC) -c $< -o $@ $(SFML_INCLUDE) $(CFLAGS)
$(OBJDIR_DEBUG)/%.o: $(SRCDIR)/%.cpp | $(HEADERS)
	@echo ------ Compiling $< to $@...
	$(CC) -c $< -o $@ $(SFML_INCLUDE) $(CFLAGS)

# Compile the resource files
$(OBJDIR_RELEASE)/%.res.o: $(RESDIR)/%.rc
	@echo ------ Compiling release res file $@...
	$(RC) $< -o $@
$(OBJDIR_DEBUG)/%.res.o: $(RESDIR)/%.rc
	@echo ------ Compiling debug res file $@...
	$(RC) $< -o $@

# Clean up generated files
clean:
	@IF EXIST $(OBJDIR) $(RMDIR) $(OBJDIR)
	@IF EXIST "$(BINDIR_DEBUG)" $(RMDIR) "$(BINDIR_DEBUG)"
	@echo ------ Clean complete!

info:
	@echo # OBJS_RELEASE: $(OBJS_RELEASE)
	@echo # OBJS_RES_RELEASE: $(OBJS_RES_RELEASE)
	@echo # 
	@echo # SFML_INCLUDE: $(SFML_INCLUDE)
	@echo # SFML_LIB: $(SFML_LIB)
	@echo # SFML_BIN: $(SFML_BIN)
	@echo # SFML2_RELEASE_LIBS: $(SFML2_RELEASE_LIBS)
	@echo # SFML2_DEBUG_LIBS: $(SFML2_DEBUG_LIBS)
	@echo # SFML_RELEASE_LDFLAGS: $(SFML_RELEASE_LDFLAGS)
	@echo # SFML_DEBUG_LDFLAGS: $(SFML_DEBUG_LDFLAGS)
	@echo # SFML_RELEASE_DLLS: $(SFML_RELEASE_DLLS)
	@echo # SFML_DEBUG_DLLS: $(SFML_DEBUG_DLLS)
