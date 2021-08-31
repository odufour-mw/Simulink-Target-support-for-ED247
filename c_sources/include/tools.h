/******************************************************************************
 *
 * Copyright (c) 2021 The MathWorks Inc.
 *
 */
 
 #ifndef __ED247SLADAPTERTOOLS__
 #define __ED247SLADAPTERTOOLS__
 
 #include <stdlib.h>
 #include <string.h>
 #include <stdarg.h>
  
 #ifndef MATLAB_MEX_FILE
	#include <stdio.h>
 #else
	#include "simstruc.h"
 #endif
 
 #define STRING_MAX_LENGTH 		512
 
 #ifdef _WIN32
	#define FILESEP "\\"
 #else
	#define FILESEP "/" 
 #endif

namespace ed247simulink {

	class Tools {

		public:
			static void myprintf(const char *fmt, ...);
			static int fileexists(const char * filename);
			static void fileparts(const char* path, char* folder);

	};

}
/*
#ifdef __cplusplus
extern "C" {
#endif
 
 void myprintf(const char *fmt, ...); 
 int fileexists(const char * filename);
 void fileparts(const char* path, char* folder);
 
#ifdef __cplusplus
}
#endif
*/
#endif
