/******************************************************************************
 * Copyright 1996-2005,2009 by Thomas E. Dickey                               *
 * All Rights Reserved.                                                       *
 *                                                                            *
 * Permission to use, copy, modify, and distribute this software and its      *
 * documentation for any purpose and without fee is hereby granted, provided  *
 * that the above copyright notice appear in all copies and that both that    *
 * copyright notice and this permission notice appear in supporting           *
 * documentation, and that the name of the above listed copyright holder(s)   *
 * not be used in advertising or publicity pertaining to distribution of the  *
 * software without specific, written prior permission. THE ABOVE LISTED      *
 * COPYRIGHT HOLDER(S) DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,  *
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO     *
 * EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY         *
 * SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER       *
 * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF       *
 * CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN        *
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                   *
 ******************************************************************************/
// $Id: bcpp.h,v 1.47 2009/06/28 19:21:16 tom Exp $

#ifndef _BCPP_HEADER
#define _BCPP_HEADER

#include <string.h>
#include <sys/types.h>

#ifdef HAVE_CONFIG_H
#include "autoconf.h"
#endif

#include "config.h"
#include "anyobj.h"            // Use ANYOBJECT base class
#include "baseq.h"             // QueueList class to store Output structures
#include "stacklis.h"          // StackList class to store indentStruct

// Common/miscellaneous definitions for BCPP

#define TABLESIZE(n) (sizeof(n)/sizeof(n[0]))

#ifndef VERSION
#define VERSION ""
#endif

#ifdef DEBUG
#define TRACE(p) trace p
#else
#define TRACE(p) /*nothing*/
#endif

#if defined(sun) && !defined(__SVR4)    // SunOS
extern "C" {
    extern char *strcat(char *, const char *);
    extern char *strncpy(const char *, const char *, size_t);
    extern char *strstr(const char *, const char *);
    extern int strncmp(const char *, const char *, size_t);
};
#endif

#ifdef __GNUC__
#define HAVE_UNISTD_H 1
#else
#define bool int        // FIXME
#endif

//-----------------------------------------------------------------------------
// Character-state, chosen to allow storing as a null-terminated char-string
enum CharState {
    NullC   = 0,
    Blank   = ' ',      // whitespace not in other categories
    PreProc = '#',      // preprocessor (first chunk, with '#')
    Normal  = '.',      // code
    DQuoted = '"',      // "string"
    SQuoted = '\'',     // 'c'
    Comment = 'c',      // C comment
    Ignore  = 'C'       // C++ comment
    };

// ----------------------------------------------------------------------------
enum  DataTypes { NoType = 0, CCom = 1,   CppCom = 2, Code  = 3,
                  OBrace = 4, CBrace = 5, PreP = 6, ELine = 7
                };

// ----------------------------------------------------------------------------
enum IndentAttr { noIndent=0, oneLine=1, multiLine=2, blockLine=3 };

// ----------------------------------------------------------------------------
typedef struct {
    const char *name;
    IndentAttr code;
} IndentwordStruct;

extern const IndentwordStruct pIndentWords[];

// ----------------------------------------------------------------------------
// This structure is used to store line data that is de-constructed from the
// user's input file.

#define MY_DEFAULT \
        dataType(NoType), \
        comWcode(False), \
        offset(0), \
        pData(), \
        pState()

class InputStruct : public ANYOBJECT
{
    public:

        DataTypes dataType;   // i.e "/*" or "*/"                  (CCom)
                              //     "//"                          (CppCom)
                              //     Code (a = 5; , if (a == b) .. (Code)
                              //     "{"                           (OBrace)
                              //     "}"                           (CBrace)
                              //     #define                       (PreP)
                              //     SPACES (nothing, blank line)  (ELine)

        Boolean comWcode;
                              //       -1 : True,  comment with code (for comment dataType)
                              //        0 : False, comment with no Code

        int offset;           // offset within original line's text
        char* pData;          // pointer to queue data !
        char* pState;         // pointer to corresponding parse-state

        inline InputStruct (DataTypes theType, int theOffset)
            : MY_DEFAULT
        {
            dataType = theType;
            offset = theOffset;
            comWcode = False;
            pState = 0;       // only non-null for code
        }

        // use defaults here:
        InputStruct(const InputStruct&);
        InputStruct& operator=(const InputStruct&);
};

#undef MY_DEFAULT

#if defined(DEBUG) || defined(DEBUG2)
extern int   totalTokens;            // token count, for debugging
#endif

// ----------------------------------------------------------------------------
// The output structure is used to hold an entire output line. The structure is
// expanded with its real tabs/spaces within the output function of the program.

#if defined(DEBUG) || defined(DEBUG2)
#define DBG_DEFAULT , thisToken(totalTokens++)
#else
#define DBG_DEFAULT
#endif

#define MY_DEFAULT \
           pType(ELine), \
           offset(0), \
           bracesLevel(0), \
           preproLevel(0), \
           indentSpace(0), \
           indentHangs(0), \
           splitElseIf(False), \
           pCode(NULL), \
           pCFlag(NULL), \
           pBrace(NULL), \
           pBFlag(NULL), \
           filler(0), \
           pComment(NULL) DBG_DEFAULT

class OutputStruct : public ANYOBJECT
{
    public:
        DataTypes pType;
        int   offset;        // offset within original line's text
        int   bracesLevel;   // curly-brace level at beginning of line
        int   preproLevel;   // curly-brace level for preprocessor lines
        int   indentSpace;   // num of spaces
        int   indentHangs;   // num of indents for continuation
        bool  splitElseIf;   // special case for aligning else/if
        char* pCode;
        char* pCFlag;        // state-flags for pCode
        char* pBrace;        // "}" or "{", with possible code-fragment
        char* pBFlag;        // state-flags for pBrace
        int   filler;        // num of spaces
        char* pComment;
#if defined(DEBUG) || defined(DEBUG2)
        int   thisToken;     // current token number
#endif

    public:
        // Constructor
        // Automate initalisation
        inline OutputStruct (DataTypes theType)
            : MY_DEFAULT
        {
            pType          = theType;
        }

        inline OutputStruct (InputStruct* theIn)
            : MY_DEFAULT
        {
            pType          = theIn -> dataType;
            offset         = theIn -> offset;
        }

        inline OutputStruct (OutputStruct* theIn)
            : MY_DEFAULT
        {
            pType          = theIn -> pType;
            offset         = theIn -> offset;
        }

        // use defaults here
        OutputStruct(const OutputStruct &);
        OutputStruct& operator=(const OutputStruct&);

        // Destructor
        // Automate destruction
        inline ~OutputStruct (void)
        {
            delete[] pCode;
            delete[] pCFlag;
            delete[] pBrace;
            delete[] pBFlag;
            delete[] pComment;
        }
};

#undef MY_DEFAULT
#undef DBG_DEFAULT

// ----------------------------------------------------------------------------

#define MY_DEFAULT \
        stmt_level(0), \
        until_parn(0), \
        parn_level(0), \
        until_curl(0), \
        curl_level(0), \
        in_aggreg(0), \
        do_aggreg(False), \
        indent(0)

class HangStruct : public ANYOBJECT
{
    private:
        int  stmt_level;     // statement-level (from oneLine=0)

        int  until_parn;     // suppress hang until right-parenthesis
        int  parn_level;     // parentheses-level

        int  until_curl;     // suppress hang until R_CURL
        int  curl_level;     // curly-brace-level

        int  in_aggreg;      // in aggregate, curly-brace-level
        bool do_aggreg;

    public:
        int  indent;

        HangStruct()
            : MY_DEFAULT
        {
        }

        void IndentHanging (OutputStruct *pOut);

    private:
        void ScanState(const char *code, const char *state);
};

#undef MY_DEFAULT

// ----------------------------------------------------------------------------
class HtmlStruct : public ANYOBJECT
{
        int state;
    public:
        HtmlStruct(void)
            : state(0)
        {
        }
        bool Active(const char *pLineData);
};

// ----------------------------------------------------------------------------

#define MY_DEFAULT \
        state(NotSQL), \
        level(0), \
        matched()

enum SqlState {
    NotSQL = 0,
    DeclSQL = 1,
    BeginSQL = 2,
    MoreSQL = 3
};

class SqlStruct : public ANYOBJECT
{
        SqlState state;
        int level;
        char matched[80];

    public:
        SqlStruct(void)
            : MY_DEFAULT
        {
            matched[0] = 0;
        }
        void IndentSQL(OutputStruct *pOut);

    private:
        int NextWord(int start, OutputStruct *pOut);
        int SkipWord(int start, OutputStruct *pOut);
        bool SqlVerb(const char *code);
};

#undef MY_DEFAULT

// ----------------------------------------------------------------------------
// This structure is used to hold indent data on non-brace code.
// This includes case statements, single line if's, while's, for statements...

#define MY_DEFAULT \
           attrib(noIndent), \
           pos(), \
           singleIndentLen()

class IndentStruct : public ANYOBJECT
{
    public:
           // attribute values ...
           // value 1 = indent code one position, until a ';' is found !
           //       2 = end on close brace, and at a position "pos"
           IndentAttr    attrib;
           int           pos;

           // Indent double the amount for multiline single if, while ...
           // statements.
           int           singleIndentLen;

    // constructor
    IndentStruct (void)
        : MY_DEFAULT
    {
        attrib          = noIndent;
        pos             = 0;
        singleIndentLen = 0; // number of spaces to indent !
    }
};

#undef MY_DEFAULT

//-----------------------------------------------------------------------------
// debug.cpp
extern void trace (const char *format, ...);
#ifdef DEBUG
extern void traceInput(const char *file, int line, InputStruct *pIn);
extern void traceIndent(const char *file, int line, IndentStruct *pIndent);
extern void traceOutput(const char *file, int line, OutputStruct *pOut);
#define TRACE_INPUT(pOut)  traceInput(__FILE__, __LINE__, pOut);
#define TRACE_INDENT(pOut) traceIndent(__FILE__, __LINE__, pOut);
#define TRACE_OUTPUT(pOut) traceOutput(__FILE__, __LINE__, pOut);
#else
#define TRACE_INPUT(pOut)  /* nothing */
#define TRACE_INDENT(pOut) /* nothing */
#define TRACE_OUTPUT(pOut) /* nothing */
#endif

inline bool emptyString(const char *s)
{
    return s == 0 || *s == 0;
}

//-----------------------------------------------------------------------------
// backup.cpp
extern int BackupFile (char*& oldFilename, char*& newFilename);
extern void RestoreIfUnchanged(char *oldFilename, char *newFilename);

// exec_sql.cpp
extern void IndentSQL (OutputStruct *pOut, int& state);

// hanging.cpp
extern void IndentHanging (OutputStruct *pOut, HangStruct& state);

// FIXME
extern int LookupKeyword(const char *tst);
extern bool ContinuedQuote(OutputStruct *pOut);

// strings.cpp
extern bool isName(char c);
extern bool CompareKeyword(const char *tst, const char *ref);
extern char *NewString (const char *src);
extern char *NewSubstring (const char *src, size_t len);
extern const char *SkipBlanks(const char *s);

// tabs.cpp
extern void ExpandTabs (char* &pString,
    int tabLen,
    int deleteChars,
    Boolean quoteChars,
    CharState &curState, char * &lineState, Boolean &codeOnLine);
extern char* TabSpacing (int mode, int col, int len, int spaceIndent);

// verbose.cpp
extern bool prompt (const char *format, ...);
extern void verbose (const char *format, ...);
extern void warning (const char *format, ...);

#endif // _BCPP_HEADER
