# Nombre del ejecutable
TARGET = program.exe
VERSION = 0.1
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
CFLAGS = -Wall -Wextra 
LDFLAGS = -L"$(COMPILER_DIR)lib"

# Parametros de linker SFML para librerías dinámicas
SFML_CFLAGS 					:= -I$(wildcard dependencies/SFML*/SFML*/include)
SFML_LIB 						:= $(wildcard dependencies/SFML*/SFML*/lib)
SFML_RELEASE_DYNAMIC_LDFLAGS 	:= -L$(SFML_LIB) -lsfml-window 		-lsfml-graphics 	-lsfml-system 	-lsfml-audio 	-lsfml-network
SFML_DEBUG_DYNAMIC_LDFLAGS 		:= -L$(SFML_LIB) -lsfml-window-d 	-lsfml-graphics-d 	-lsfml-system-d -lsfml-audio-d 	-lsfml-network-d

# Comandos
# Check for Windows
ifeq ($(OS), Windows_NT)
    RMDIR = rmdir /s /q
else
    RMDIR = rm -rf
endif

# Archivos de código (Carpeta /src)
SOURCES := $(wildcard $(SRCDIR)/*.cpp)
HEADERS := $(wildcard $(SRCDIR)/*.h*)

# Objetos
OBJS_RELEASE := $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR_RELEASE)/%.o)
OBJS_DEBUG := $(SOURCES:$(SRCDIR)/%.cpp=$(OBJDIR_DEBUG)/%.o)

# Compilador de recursos
RC = "$(COMPILER_DIR)windres"

# Archivos de recursos (Carpeta /res)
RESOURCES := $(wildcard $(RESDIR)/*.rc)
RELEASE_RES_OBJECTS := $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR_RELEASE)/%.res.o)
DEBUG_RES_OBJECTS := $(RESOURCES:$(RESDIR)/%.rc=$(OBJDIR_DEBUG)/%.res.o)

################################
# Comandos
.PHONY: all clean debug release info

# Main Tasks
all: release

release: $(OBJDIR_RELEASE) $(BINDIR_RELEASE) $(BINDIR_RELEASE)/$(TARGET)

debug: CFLAGS += -g -O0
debug: $(OBJDIR_DEBUG) $(BINDIR_DEBUG) $(BINDIR_DEBUG)/$(TARGET)

# Create directories
$(OBJDIR_RELEASE) $(BINDIR_RELEASE) $(OBJDIR_DEBUG) $(BINDIR_DEBUG):
	@mkdir "$@"

# Link the object files to create the executable
$(BINDIR_RELEASE)/$(TARGET): $(OBJS_RELEASE) $(RELEASE_RES_OBJECTS)
	@echo ------ Compiling started: $(TARGET) ------
	$(CC) $(OBJS_RELEASE) $(RELEASE_RES_OBJECTS) -o $@ $(LDFLAGS) $(SFML_RELEASE_DYNAMIC_LDFLAGS) -DVERSION=\"$(VERSION)\" -DCOPYRIGHT=\"$(COPYRIGHT)\"
	@echo --- Compilation complete!

$(BINDIR_DEBUG)/$(TARGET): $(OBJS_DEBUG) $(DEBUG_RES_OBJECTS)
	@echo ------ Compiling started: $(TARGET) ------
	$(CC) $(OBJS_DEBUG) $(DEBUG_RES_OBJECTS) -o $@ $(LDFLAGS) $(SFML_DEBUG_DYNAMIC_LDFLAGS) -DVERSION=\"$(VERSION)\" -DCOPYRIGHT=\"$(COPYRIGHT)\"
	@echo --- Debug compilation complete!

# Compile each .cpp file to an object file
$(OBJDIR_RELEASE)/%.o: $(SRCDIR)/%.cpp | $(HEADERS)
	@echo Compiling $@...
	$(CC) -c $< -o $@ $(SFML_CFLAGS) $(CFLAGS) 

$(OBJDIR_DEBUG)/%.o: $(SRCDIR)/%.cpp | $(HEADERS)
	@echo Compiling $@...
	$(CC) -c $< -o $@ $(SFML_CFLAGS) $(CFLAGS)

# Compile the resource files
$(OBJDIR_RELEASE)/%.res.o: $(RESDIR)/%.rc
	@echo Compiling release res file $@...
	$(RC) $< -o $@

$(OBJDIR_DEBUG)/%.res.o: $(RESDIR)/%.rc
	@echo Compiling debug res file $@...
	$(RC) $< -o $@

# Clean up generated files
clean:
	@IF EXIST $(OBJDIR) $(RMDIR) $(OBJDIR)
	@IF EXIST $(BINDIR_DEBUG) $(RMDIR) $(BINDIR_DEBUG)
	@echo Clean complete!

info:
	@echo # SFML_CFLAGS: $(SFML_CFLAGS)
	@echo # SFML_RELEASE_STATIC_LDFLAGS: $(SFML_RELEASE_STATIC_LDFLAGS)
	@echo # SFML_DEBUG_DYNAMIC_LDFLAGS: $(SFML_DEBUG_DYNAMIC_LDFLAGS)
	@echo # SFML_DEBUG_STATIC_LDFLAGS: $(SFML_DEBUG_STATIC_LDFLAGS)
	@echo # SFML_RELEASE_DYNAMIC_LDFLAGS: $(SFML_RELEASE_DYNAMIC_LDFLAGS)
