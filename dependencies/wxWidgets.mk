################################ wxWidgets ################################
WX_VERSION 				:= 3.2.6
BUILD_TYPE 				?= release

# you can add any wxWidgets component you want to use:
# 	! u_gcc		: Required for all apps (core non-GUI) (REQUIRED)
# 	! core 		: Any GUI application (REQUIRED)
# 	adv 		: Using advanced controls 					(wxPropertyGrid), (wxCalendarCtrl), (wxTaskBarIcon)
# 	aui 		: When using dockable panels 				(wxAuiManager)
# 	gl 			: OpenGL integration 						(wxGLCanvas)
# 	html 		: For HTML rendering, simple web views 		(wxHtmlWindow)
# 	media 		: Multimedia playback 						(wxMediaCtrl)
# 	net 		: Networking: wxSocket, HTTP/FTP classes 	(wxSocketClient, wxSocketServer)
# 	propgrid 	: Advanced property grids 					(wxPropertyGrid)
# 	ribbon 		: Office-style ribbon UI 					(wxRibbonBar)
# 	richtext 	: Rich text formatting 						(wxRichTextCtrl)
# 	stc 		: Syntax highlighting control 				(wxStyledTextCtrl)
# 	webview 	: Embedded web browser control 				(wxWebView)							
# 	xml 		: XML parsing 								(wxXmlDocument)
# 	xrc 		: Loading XML resource files 				(wxXmlResource)

WX_COMPONENTS 			:= u_gcc core		# don't modify this line, it is required for all wxWidgets applications
# add any other components you want to use here:
WX_COMPONENTS 			+= aui net media



######### Includes
WX_INCLUDE 				:= -I$(wildcard dependencies/wx*headers/include)

######### Libs (linker)

# directories
WX_LIB_PATH 			:= $(wildcard dependencies/wx*dev/lib/*)
WX_LINKS				:= $(foreach path,$(WX_LIB_PATH),-L$(path))


# TODO: LINKING LIBS


######### dlls
ifeq ($(findstring debug, $(BUILD_TYPE)), debug)
	WX_DLLS_PATH 			:= $(wildcard dependencies/wx*Dev*/lib/gcc*/)
else
	WX_DLLS_PATH 			:= $(wildcard dependencies/wx*ReleaseDLL*/lib/gcc*/)
endif
WX_ALL_DLLS 			:= $(wildcard $(WX_DLLS_PATH)*.dll)
WX_DLLS					:= $(strip \
							$(foreach dll, $(WX_ALL_DLLS),\
								$(foreach filter, $(WX_COMPONENTS), \
									$(if $(findstring $(filter), $(dll)),\
										$(dll), \
									)\
								)\
							)\
						)
WX_DLLS 				:= $(strip $(foreach dll, $(WX_DLLS), $(notdir $(dll)) ) )
$(info # WX_DLLS: $(WX_DLLS))

################################

INCLUDES 				+= $(WX_INCLUDE)
LINKS 					+= $(WX_LINKS)		# -L(PATH) -l(libs), for static will be -l(libs)-s
DLLS 					+= $(WX_DLLS)

# for wx dynamic linking, the program will need stdc++-6.dll, gcc_s_dw2-1.dll and libwinpthread-1.dll
# add them to the dlls list
ifeq ($(findstring dynamic, $(LIBS)), dynamic)
	DLLS	 			+= libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll
	DLLS				:= $(strip $(sort $(DLLS)))
endif

