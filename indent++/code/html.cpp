//******************************************************************************
// Copyright 1999-2002,2003 by Thomas E. Dickey                                          *
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
// $Id: html.cpp,v 1.5 2003/04/22 22:58:57 tom Exp $

#include "bcpp.h"
#include "cmdline.h"

#include <ctype.h>
#include <string.h>

static char *
UpperCase(const char *text)
{
    while (isspace(*text))
        text++;
    char *temp = new char[strlen(text)+1];
    strcpy(temp, text);
    for (int n = strlen(temp); n > 0; n--)
        if (isspace(temp[n-1]))
            temp[--n] = 0;
    StrUpr(temp);
    return temp;
}

static bool
BeginScript(const char *text)
{
    char *temp = UpperCase (text);
    bool code = !strcmp("<SERVER>", temp) || !strcmp("<SCRIPT>", temp);
    delete[] temp;
    return code;
}

static bool
EndScript(const char *text)
{
    char *temp = UpperCase (text);
    bool code = !strcmp("</SERVER>", temp) || !strcmp("</SCRIPT>", temp);
    delete[] temp;
    return code;
}

bool
HtmlStruct::Active(const char *pLineData)
{
    bool match = False;
    int n;

    switch (state)
    {
        case 0:
            for (n = 0; pLineData[n] != 0; n++) {
                if (!isspace(pLineData[n])) {
                    if (pLineData[n] == '<') {
                        state = 1;
                    } else {
                        state = -1;
                    }
                    break;
                }
            }
            // FALLTHRU
        case 1:
            if (BeginScript(pLineData)) {
                state = 2;
                match = True;
            }
            break;
        case 2:
            if (EndScript(pLineData)) {
                state = 1;
                match = True;
            }
            break;
        default:
            // We've decided it is not HTML + JavaScript
            break;
    }
    return ((state == 1) || match);
}
