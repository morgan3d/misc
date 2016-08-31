//******************************************************************************
// Copyright 1999 by Thomas E. Dickey                                          *
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
// $Id: verbose.cpp,v 1.6 2002/05/18 17:46:58 tom Exp $
// verbose.cpp

#include "bcpp.h"

#include <stdarg.h>

#if HAVE_UNISTD_H
#include <unistd.h>
#else
#include <io.h>
#endif

#undef verbose      // in case we defined it to 'printf'

static int my_level = 1;

void verbose(const char *format, ...)
{
    if (my_level > 0) {
        va_list ap;
        va_start(ap, format);
        vprintf(format, ap);
        va_end(ap);
    }
}

void warning(const char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    vfprintf(stderr, format, ap);
    va_end(ap);
}

bool prompt(const char *format, ...)
{
    int code;

    if (isatty(fileno(stdin))
     && isatty(fileno(stdout))) {
        va_list ap;
        for(;;) {
            fprintf(stderr, "\n");
            va_start(ap, format);
            vfprintf(stderr, format, ap);
            va_end(ap);
            fprintf(stderr, " [y/n] ? ");
            fflush(stderr);
            code = getc(stdin);
            if (code == 'y' || code == 'Y')
                return True;
            if (code == 'n' || code == 'n')
                break;
        }
    }
    return False;
}
