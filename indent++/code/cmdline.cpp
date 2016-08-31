#ifndef _CMDLINE_CODE
#define _CMDLINE_CODE

// $Id: cmdline.cpp,v 1.24 2009/06/26 00:52:53 tom Exp $
// Program C(++) Beautifier Written By Steven De Toni ACBC 11 12/94
// Revised 1999 - Thomas Dickey
//
// This module contains methods to parse the command line.

#include <stdlib.h>   // atoi()
#include <ctype.h>
#include <string.h>   // strcmp()

#include "bcpp.h"
#include "cmdline.h"  // prototypes

// Function converts a lower case string into upper case, any special
// characters remain the same (i.e "$", "%" ...)
void StrUpr (char* pUpCase)
{
     while (*pUpCase != '\0')
     {
          if (isalpha(*pUpCase) && islower(*pUpCase))
                  *pUpCase = toupper(*pUpCase);
          pUpCase++;
     }
}

// This function displays brief command line help to the user.
// Parameters:
// char* argv[]     : Pointer to command line parameter pointer array
//
void PrintProgramHelp (void)
{
    static const char *help[] = {
        "C(++) Beautifier     " VERSION,
        "",
        "Program Was Written By Steven De Toni, December 1995",
        "Modified/revised by Thomas E. Dickey 1996-2003,2004",
        "All Parts Of This Program Are Freely Distributable.",
        "",
        "Usage: bcpp [Parameters] [Input File Name] [Output File Name]",
        "",
        "Options:",
        "",
        "[-bcl] [-bnl] [-cc <num>] [-f <num>] [-fi <string>] [-fnc <string>]",
        "[-fo <string>] [-h] [-i <num>] [-lg]",
        "[-na] [-nb] [-nbbi] [-nbi] [-nc] [-nkcwc] [-nlcnc] [-no] [-nq]",
        "[-qb] [-s] [-t]",
        "[-ya] [-yb] [-ybbi] [-ybi] [-ykcwc] [-ylcnc] [-yo] [-yq]",
        "[<string>] [<string>]",
        "",
        "[] = Optional <> = Parameter Requirement",
        "",
        "* Support For I/O Redirection Is Provided *",
    };
    unsigned n;
    for (n = 0; n < TABLESIZE(help); n++)
        verbose("%s\n", help[n]);

    if (prompt("More Detail"))
    {
        static const char *details[] = {
            "-bcl          : Open braces on code line",
            "-bnl          : Open braces on new line",
            "-cc  <num>    : Column to align comments with code",
            "-f   <num>    : Function line spacing",
            "-fi <string>  : Input file name",
            "-fnc <string> : Load custom configuration file",
            "-fo <string>  : Output file name",
            "-h    or   -? : This help message",
            "-i   <num>    : Indent space length",
            "-lg           : Leave graphic chars",
            "-nc  <num>    : Column to align comments with no code",
            "-qb  <num>    : Define internal queue buffer size",
            "-s            : Use spaces in indenting",
            "-t            : Use tabs in indenting",
            "-tbcl         : Top-level open braces on code line",
            "-tbnl         : Top-level open braces on new line",
            "",
            "Options beginning with -n or -y disable/enable functions:",
            "  a           : Remove non-ASCII chars",
            "  b           : Backup input file with .bac extension",
            "  bbi         : Indent both braces of a block",
            "  bi          : Indent trailing brace of block",
            "  kcwc        : Keep comments with Code",
            "  lcnc        : Leave comments with NoCode",
            "  o           : Program output",
            "  q           : Change non-ASCII chars in quotes to octal",
        };
        for (n = 0; n < TABLESIZE(details); n++)
            verbose("%s\n", details[n]);
    }
}

// integer assignment
static void intOption (int& cmdCount, int argc, char* argv[], int &result )
{
    if (cmdCount++ <= (argc-1))
    {
        result = atoi (argv[cmdCount]);
    }
    else
    {
        warning ("Expected Another Integer Parameter For Command Directive %s\n", argv[cmdCount]);
        PrintProgramHelp ();
    }
}

// string assignment
static void strOption (int& cmdCount, int argc, char* argv[], char * &result)
{
    if (cmdCount++ <= (argc-1))
    {
        result = argv[cmdCount];
    }
    else
    {
        warning ("Expected Another String Parameter For Command Directive %s\n", argv[cmdCount]);
        PrintProgramHelp ();
    }
}

#define DecodeFlg(option, flag, value) \
            if (strcmp (option, cmdRead) == 0) \
            { \
                flag = value; \
                continue; \
            }

#define DecodeInt(option, flag) \
            if (strcmp (option, cmdRead) == 0) \
            { \
                intOption (cmdCount, argc, argv, flag); \
                continue; \
            }

#define DecodeStr(option, flag) \
            if (strcmp (option, cmdRead) == 0) \
            { \
                strOption (cmdCount, argc, argv, flag); \
                continue; \
            }

// Function processes command line parameters
int ProcessCommandLine (int argc, char* argv[], Config& settings,
                        char*& pInFile, char*& pOutFile, char*& pConfig)
{

    int   cmdCount = 0;
    char* cmdRead;

    while (cmdCount < argc-1)
    {
        // command line error
        if (cmdCount < 0)
           return cmdCount;

        // next command to process!
        cmdCount++;
        cmdRead = argv[cmdCount];

        // this is a command directive
        if (cmdRead[0] == '-')
        {
            // upcase the command parameter
            StrUpr (cmdRead);

            cmdRead++;

            // miscellaneous flags, "sort +1"
            DecodeFlg ("BCL",   settings.braceLoc,        False);
            DecodeFlg ("BNL",   settings.braceLoc,        True);
            DecodeInt ("CC",    settings.posOfCommentsWC);
            DecodeInt ("F",     settings.numOfLineFunc);
            DecodeStr ("FI",    pInFile);
            DecodeStr ("FNC",   pConfig);
            DecodeStr ("FO",    pOutFile);
            DecodeInt ("I",     settings.tabSpaceSize);
            DecodeFlg ("LG",    settings.deleteHighChars, 3);
            DecodeInt ("NC",    settings.posOfCommentsNC);
            DecodeInt ("QB",    settings.queueBuffer);
            DecodeFlg ("S",     settings.useTabs,         False);
            DecodeFlg ("T",     settings.useTabs,         True);
            DecodeFlg ("TBCL",  settings.topBraceLoc,     False);
            DecodeFlg ("TBNL",  settings.topBraceLoc,     True);

            // "No" flags
            DecodeFlg ("NA",    settings.deleteHighChars, 0);
            DecodeFlg ("NB",    settings.backUp,          False);
            DecodeFlg ("NBBI",  settings.braceIndent2,    False);
            DecodeFlg ("NBI",   settings.braceIndent,     False);
            DecodeFlg ("NLCNC", settings.leaveCommentsNC, False);
            DecodeFlg ("NO",    settings.output,          False);
            DecodeFlg ("NQ",    settings.quoteChars,      False);

            // "Yes" flags
            DecodeFlg ("YA",    settings.deleteHighChars, 1);
            DecodeFlg ("YB",    settings.backUp,          True);
            DecodeFlg ("YBBI",  settings.braceIndent2,    True);
            DecodeFlg ("YBI",   settings.braceIndent,     True);
            DecodeFlg ("YLCNC", settings.leaveCommentsNC, True);
            DecodeFlg ("YO",    settings.output,          True);
            DecodeFlg ("YQ",    settings.quoteChars,      True);

            // ### display help ###
            if( (strcmp ("?", cmdRead) == 0) ||
                (strcmp ("H", cmdRead) == 0) )
            {
                verbose ("*** Displaying Brief Help ***\n");
                PrintProgramHelp ();
                return -1;
            }

            warning ("Unknown Command Directive %s \n", cmdRead);
            PrintProgramHelp ();
            return -1;
        }
        else if (pInFile == NULL)
                pInFile  = argv [cmdCount];
        else if (pOutFile == NULL)
                pOutFile = argv [cmdCount];
        else
        {
            warning ("Command Line Error : Expected Command Directive, Not %s\n", argv[cmdCount]);
            PrintProgramHelp ();
            return -1;
        }
    }

    if (settings.queueBuffer < 2)
        settings.queueBuffer = 2;
    return 0;
}

#endif //_CMDLINE_CODE
