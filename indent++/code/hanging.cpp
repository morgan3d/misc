//******************************************************************************
// Copyright 1996-2003,2005 by Thomas E. Dickey                                *
// All Rights Reserved.                                                        *
//                                                                             *
// Permission to use, copy, modify, and distribute this software and its       *
// documentation for any purpose and without fee is hereby granted, provided   *
// that the above copyright notice appear in all copies and that both that     *
// copyright notice and this permission notice appear in supporting            *
// documentation, and that the name of the above listed copyright holder(s)    *
// not be used in advertising or publicity pertaining to distribution of the   *
// software without specific, written prior permission. THE ABOVE LISTED       *
// COPYRIGHT HOLDER(S) DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,   *
// INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO      *
// EVENT SHALL THE ABOVE LISTED COPYRIGHT HOLDER(S) BE LIABLE FOR ANY SPECIAL, *
// INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM  *
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE  *
// OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR   *
// PERFORMANCE OF THIS SOFTWARE.                                               *
//******************************************************************************
// $Id: hanging.cpp,v 1.19 2005/08/19 23:25:43 tom Exp $
// Compute hanging-indent for most multiline statements.

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "bcpp.h"

static int endOfKeyword(const char *name, int first)
{
    int next = first;
    while (isName(name[next + 1]))
        ++next;
    return next;
}

static char* parseKeyword(const char *name, int &next)
{
    int first = next;

    next = endOfKeyword(name, next);

    unsigned len = next + 1 - first;
    char* string = new char[len + 1];
    strncpy(string, name + first, len)[len] = 0;

    return string;
}

// Determine if the current OutputStruct should be indented for hanging
// indent of a multi-line statement.  Generally, we indent all lines after
// the first for a statement, except when other conditions prevail:
//
//      a.  we encounter curly-braces (which have their own rules)
//      b.  we encounter a keyword that has its own indention rules

void
HangStruct::ScanState(const char *code, const char *state)
{
    if (code != 0)
    {
        for (int n = 0; code[n] != NULLC; n++)
        {
            if (state[n] == Normal)
            {
                int c = code[n];

                if (isName(c)
                 && (n == 0 || !isName(code[n-1])))
                {
                    char *name = parseKeyword(code, n);
                    int findWord = LookupKeyword(name);

                    TRACE(("lookup '%s' ->%d\n", name, findWord));
                    do_aggreg = False;
                    if (findWord >= 0)
                    {
                        indent = 0;
                        until_parn = 1;
                        if (pIndentWords[findWord].code == oneLine)
                            stmt_level++;
                        else
                            stmt_level = 0;
                    }
                    else
                    {
                        if (!strcmp(name, "enum"))
                            until_curl = 1;

                        if (parn_level == 0)
                            until_parn = 0;
                        indent = 1;
                    }
                    delete[] name;
                }
                else if (!isspace(code[n]))
                {
                    if (do_aggreg && code[n] != L_CURL)
                        do_aggreg = False;

                    switch (code[n])
                    {
                        case '=':
                            if (parn_level == 0)
                                do_aggreg = True;
                            break;
                        case L_CURL:
                            curl_level++;
                            indent = 0;
                            stmt_level = 0;
                            until_parn = 0;
                            if (do_aggreg)
                                in_aggreg = curl_level;
                            break;
                        case R_CURL:
                            curl_level--;
                            indent = 0;
                            stmt_level = 0;
                            until_curl = 0;
                            break;
                        case ':':
                            // "::" means something different entirely
                            if (code[n+1] == ':')
                            {
                                n++;
                            }
                            else
                            {
                                indent = 0;
                                stmt_level = 0;
                                until_parn = 0;
                            }
                            break;
                        case SEMICOLON:
                            if (parn_level == 0)
                            {
                                indent = 0;
                                stmt_level = 0;
                                until_parn = 0;
                                until_curl = 0;
                                if (in_aggreg > curl_level)
                                    in_aggreg = 0;
                            }
                            break;
                        case L_PAREN:
                            parn_level++;
                            indent = 1;
                            break;
                        case R_PAREN:
                            parn_level--;
                            if (until_parn && !parn_level)
                                indent = 0;
                            else
                                indent = 1;
                            break;
                        case ESCAPE:
                            break;
                        default:
                            indent = 1;
                            break;
                    }
                }
            }
        }
    }
}

void
HangStruct::IndentHanging(OutputStruct *pOut)
{
#ifdef DEBUG
    TRACE(("--------------------------------------------------------------\n"));
    TRACE_OUTPUT(pOut);
    TRACE(("state:%d/%d, parn:%d/%d, curl:%d, agg:%d/%d\n",
        indent,
        stmt_level,
        until_parn,
        parn_level,
        curl_level,
        do_aggreg,
        in_aggreg));
#endif

    if (indent != 0
     && curl_level != 0
     && (until_parn == 0 || parn_level != 0)
     && until_curl == 0
     && in_aggreg < curl_level
     && !emptyString(pOut -> pCode)
     && !emptyString(pOut -> pCFlag)
     && (pOut -> pCFlag[0] == Normal || !ContinuedQuote(pOut)))
    {
        pOut -> indentHangs = indent;
        if (stmt_level && !until_parn)
            pOut -> indentHangs += stmt_level;
        TRACE(("HANG:%d\n", pOut -> indentHangs));
    }

    if (pOut -> pType != PreP)
    {
        ScanState(pOut -> pCode,  pOut -> pCFlag);
        ScanState(pOut -> pBrace, pOut -> pBFlag);
    }
}
