################################ SFML ################################
SFML_VERSION 				:= 2.5.1
BUILD_TYPE 					?= release	# if not defined, default is release

######### Includes
SFML_INCLUDE 				:= -I$(wildcard dependencies/SFML*/SFML*/include)

######### Libs (linker)
SFML_LIBS				:= sfml-system sfml-window sfml-graphics sfml-audio sfml-network
ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	SFML_LIBS				:= $(foreach lib,$(SFML_LIBS),$(lib)-d)
endif

SFML_LIB_PATH				:= $(wildcard dependencies/SFML*/SFML*/lib)
SFML_LDFLAGS 				:= -L"$(SFML_LIB_PATH)" $(foreach lib,$(SFML_LIBS),-l$(lib))

######### dlls
SFML_BIN					:= $(wildcard dependencies/SFML*/SFML*/bin)
SFML_ALL_DLLS_PATH			:= $(wildcard $(SFML_BIN)/*.dll)

ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	SFML_DLLS_PATH			:= $(foreach file, $(SFML_ALL_DLLS_PATH), $(if $(findstring -d-, $(file)), $(file)))
	SFML_DLLS_PATH			+= $(foreach file, $(SFML_ALL_DLLS_PATH), $(if $(findstring sfml, $(file)),, $(file)))  # openal32.dll
else
	SFML_DLLS_PATH			:= $(foreach file, $(SFML_ALL_DLLS_PATH), $(if $(findstring -d-, $(file)),, $(file)))
endif

SFML_DLLS 					:= $(notdir $(SFML_DLLS_PATH))


################################

# use:
# $(SFML_INCLUDE) 		- Include path
# $(SFML_LDFLAGS) 		- Libs to link
# $(SFML_DLLS)			- dlls to copy