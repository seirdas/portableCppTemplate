################################ SFML ################################
SFML_VERSION 				:= 3.0
BUILD_TYPE 					?= release	# if not defined, default is release

######### Includes
SFML_INCLUDE 				:= -I$(wildcard dependencies/SFML*/SFML*/include)

######### Libs (linker)

# directories
SFML_LIB_PATH				:= $(wildcard dependencies/SFML*/SFML*/lib)
SFML_LINKS 					+= $(foreach path, $(SFML_LIB_PATH), -L$(path))

# libs
SFML_LIBS					:= sfml-system sfml-window sfml-graphics sfml-audio sfml-network

ifeq ($(findstring static, $(LIBS)), static)
	SFML_LIBS				:= $(foreach lib,$(SFML_LIBS),$(lib)-s)
	SFML_LINKS				:= -DSFML_STATIC
endif
ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	SFML_LIBS				:= $(foreach lib,$(SFML_LIBS),$(lib)-d)
endif

SFML_LINKS					+= $(foreach lib,$(SFML_LIBS),-l$(lib))

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

INCLUDES 			+= $(SFML_INCLUDE)
LINKS 				+= $(SFML_LINKS)		# -L(PATH) -l(libs), for static will be -l(libs)-s
DLLS 				+= $(SFML_DLLS)

# for sfml dynamic linking, the program will need stdc++-6.dll, gcc_s_dw2-1.dll and libwinpthread-1.dll
# add them to the dlls list
ifeq ($(findstring dynamic, $(LIBS)), dynamic)
	DLLS	 			+= libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll
	DLLS				:= $(strip $(sort $(DLLS)))
endif



################################

# use in main makefile:
# $(SFML_INCLUDE) 		- Include path
# $(SFML_DLLS)			- dlls to copy to bin folder
# $(SFML_BIN)			- path to dlls