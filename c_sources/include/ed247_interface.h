/*
 * Copyright 2020 The MathWorks, Inc.
 */

#ifndef __ED247INTERFACE__
#define __ED247INTERFACE__

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "ed247.h"
#include "ed247_cmd_xml.h"
#include "tools.h"

#define MAX_SIGNALS 1000
#define MAX_STREAMS 100
#define MAX_DIMENSIONS 10

#define WAIT_FRAME_TIMEOUT_US 1000

#if !defined(MATLAB_MEX_FILE) && !defined(BUILTIN_TYPEID_TYPES)

	typedef enum {
		SS_DOUBLE	= 0,
		SS_SINGLE	= 1,
		SS_INT8		= 2,
		SS_UINT8	= 3,
		SS_INT16	= 4,
		SS_UINT16	= 5,
		SS_INT32	= 6,
		SS_UINT32	= 7,
		SS_BOOLEAN	= 8,
		SS_INT64	= 90, /* NOTE : Type does not exist in r2016b but appears in 2019a (see https://www.mathworks.com/help/simulink/release-notes.html?rntext=int64) */
		SS_UINT64	= 91, /* NOTE : Type does not exist in r2016b but appears in 2019a (see https://www.mathworks.com/help/simulink/release-notes.html?rntext=uint64) */
		SS_INVALID	= 99,
	} BuiltInDTypeId ;

	#include <stdio.h>

#else

	#include "simstruc.h"
	#include "sl_types_def.h"

	/* NOTE : Type does not exist in r2016b but appears in 2019a (see https://www.mathworks.com/help/simulink/release-notes.html?rntext=int64) */
	#define SS_INT64	90
	#define SS_UINT64	91
	#define SS_INVALID	99

#endif

typedef char 				INT8_t;
typedef unsigned char		UINT8_t;
typedef short 				INT16_t;
typedef unsigned short 		UINT16_t;
typedef int 				INT32_t;
typedef unsigned int 		UINT32_t;
typedef long long			INT64_t;
typedef unsigned long long	UINT64_t;
typedef float				FLOAT_t;
typedef double				DOUBLE_t;

typedef enum {
	CONFIGURATION_SUCCESS = 0,
	INVALID_FILE,
	LOAD_FAILURE,
	FIND_STREAMS_FAILURE,
	STREAM_GET_INFO_FAILURE,
	STREAM_GET_ASSISTANT_FAILURE,
	FIND_STREAM_SIGNALS_FAILURE,
	SIGNAL_ALLOCATE_SAMPLE_FAILURE,
	SIGNAL_GET_INFO_FAILURE,
	SIGNAL_LIST_FREE_FAILURE,
	STREAM_LIST_FREE_FAILURE,
	STREAM_REACH_ARRAY_LIMIT,
	INVALID_DIRECTION,
	INVALID_TYPE
} configuration_status_t;

typedef enum {
	SEND_OK = 0,
	NO_DATA_TO_SEND,
	STREAM_ASSISTANT_WRITE_SIGNAL_FAILURE,
	STREAM_ASSISTANT_PUSH_SAMPLE_FAILURE,
	STREAM_PUSH_SAMPLE_FAILURE,
	UNKNOWN_STREAM_TYPE,
	SEND_PUSHED_SAMPLES_FAILURE,
	SEND_A825_SKIP
} send_status_t;

typedef enum {
	RECEIVE_OK = 0,
	NO_DATA_TO_RECEIVE,
	STREAM_ASSISTANT_READ_SIGNAL_FAILURE,
	STREAM_POP_SAMPLE_FAILURE,
	NO_DATA_BEFORE_TIMEOUT,
	WAIT_FRAME_FAILURE,
	UNKNOWN_RECEIVE_STREAM_TYPE,
	RECEIVE_A825_SKIP
} receive_status_t;

typedef enum {
	IO_ALLOCATION_OK = 0,
	IO_MALLOC_FAILURE,
	INPUTS_MALLOC_FAILURE,
	OUTPUTS_MALLOC_FAILURE
} io_allocation_status_t;

typedef enum {
	IO_FREE_OK = 0,
	UNLOAD_FAILURE
} io_free_status_t;

typedef struct {
	char 						name[STRING_MAX_LENGTH];
	ed247_direction_t 			direction;
	BuiltInDTypeId 				type;
	int 						dimensions;
	int 						width;
	size_t 						size[MAX_DIMENSIONS];
	float 						sample_time;
	float 						validity_duration;
	void 						*valuePtr;
	ed247_stream_type_t 		stream_type;
	ed247_signal_type_t			signal_type;
	ed247_signal_t 				signal;
	void 						*sample;
	size_t 						sample_size;
	int							port_index;     // Placeholder for S-Function
	int							is_refresh; // [Send|Receive] Signal is associated with a refresh flag
	int							do_refresh; // [Send] Boolean value from inport associated with signal | [Receive] Boolean value if signal was written from ED247 read function
	int							refresh_index;  // Placeholder for S-Function
} signal_characteristics_t;

typedef struct {
	char 						name[STRING_MAX_LENGTH];
	char 						filename[STRING_MAX_LENGTH];
	ed247_direction_t 			direction;
	int 						nsignals;
	ed247_stream_type_t 		stream_type;
	ed247_stream_t 				stream;
	ed247_stream_assistant_t 	assistant; 				// Only for ANA, DIS, NAD, VNAD
	char 						icd[STRING_MAX_LENGTH]; // Only for A664, A429
	char 						bus[STRING_MAX_LENGTH]; // Only for A664, A429
	signal_characteristics_t*	signals[MAX_SIGNALS];
} stream_characteristics_t;

typedef struct {
	int nstreams;
	int nsignals;
	stream_characteristics_t streams[MAX_STREAMS];
	signal_characteristics_t signals[MAX_SIGNALS];
} data_characteristics_t;

typedef struct {
	ed247_context_t _context;
	data_characteristics_t *inputs;
	data_characteristics_t *outputs;
} IO_t;

namespace ed247simulink {

	class ED247Connector {

		private:
			IO_t*	_io;
			Tools*	_tools;

			const char* _filename;
			const char* _logfilename;

		public:
			ED247Connector();
			ED247Connector(const char* filename);
			ED247Connector(const char* filename,const char* logfilename);
			ED247Connector(const char* filename,Tools* tools);
			ED247Connector(const char* filename,const char* logfilename,Tools* tools);

		public:
			/*
			 * ACCESSORS
			 */
			data_characteristics_t* getInputs();
			data_characteristics_t* getOutputs();

			/*
			 * ED247 INTERFACE
			 */
			configuration_status_t readED247Configuration();
			send_status_t sendSimulinkToED247();
			receive_status_t receiveED247ToSimulink(int *n);

			/*
			 * DISPLAY
			 */
			void displayConfiguration();

			/*
			 * MEMORY MANAGEMENT
			 */
			io_allocation_status_t allocateMemory();
			io_free_status_t freeMemory();

		protected:
			 configuration_status_t localSignalsFromECIC(ed247_stream_t stream, const ed247_stream_info_t* stream_info);
			 configuration_status_t localSignalsFromICD(ed247_stream_t stream, const ed247_stream_info_t* stream_info, char* folder);

		private:
			/*
			 * DEBUG / HELPERS
			 */
			BuiltInDTypeId NAD2SimulinkDataType(ed247_nad_type_t type);
			char checkStatus(ed247_status_t status, const char* fcnname, int level);
			int sizeofNADDataType(ed247_nad_type_t type);

	/*
		#ifndef __MYPRINTFDEBUG__
		#define __MYPRINTFDEBUG__
		void myprintf(const char *fmt, ...);
		#endif
	*/
	};

}

#endif
