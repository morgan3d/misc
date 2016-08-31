#ifndef _CMDLINE_HEADER
#define _CMDLINE_HEADER

// $Id: cmdline.h,v 1.2 2003/04/24 00:24:11 tom Exp $

#include "config.h"                 // Config structure

// ******* Define Prototypes ********

// Function converts a lower case string into upper case, any special 
// characters remain the same (i.e "$", "%" ...)
void StrUpr (char* pUpCase);

// This function displays brief command line help to the user.
// Parameters:
// char* argv[]     : Pointer to command line parameter pointer array
//
void PrintProgramHelp (void);

// integer assignment
int intAssign (int& cmdCount, int argc, char* argv[] );

// string assignment
char* strAssign (int& cmdCount, int argc, char* argv[]);

// Function processes command line parameters
int ProcessCommandLine (int argc, char* argv[],
                        Config& settings, char*& pInFile, char*& pOutFile, char*& pConfig);
#endif
