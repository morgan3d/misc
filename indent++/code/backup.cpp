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
// $Id: backup.cpp,v 1.8 2002/05/18 17:46:05 tom Exp $

#include "bcpp.h"

#include <string.h>

inline const char *endOf(const char *s)
{
    return (s + strlen(s));
}

inline char *endOf(char *s)
{
    return (s + strlen(s));
}

inline bool isPathDelim(char ch)
{
    return ((ch == '\\') || (ch == '/'));
}

static char *FileSuffix(char *name)
{
    char * suffix = endOf(name);

    while ( ((*suffix != '.') && (suffix > name)) && !isPathDelim(*suffix) )
         suffix--;

    if ((suffix <= name) || isPathDelim(*suffix))
        suffix = endOf(name);

    return suffix;
}

// Function creates a backup of oldFilename, by renaming it to either
// a ".orig" or ".bac" extension.  Thereafter, the program will read
// from the backup file, and write to the orignal filename.
//
int BackupFile (char*& oldFilename, char*& newFilename)
{
    const char* suffix = ".bac";

    newFilename        = oldFilename;
    oldFilename        = new char[strlen(newFilename)+6];

    if (oldFilename == NULL)
       return -1;

    strcpy(oldFilename, newFilename);

    char * pLook = FileSuffix(oldFilename);

    strcat(oldFilename, ".orig");
    if (rename(newFilename, oldFilename) != 0)
    {
        FILE *fp = fopen(oldFilename, "r");
        if (fp != 0)
        {
            warning("backup already exists: %s\n", oldFilename);
            fclose(fp);
            return -1;
        }
        strcpy (pLook, suffix);
        if (rename(newFilename, oldFilename) != 0)
        {
            warning("cannot rename %s\n", newFilename);
            return -1;
        }
    }

    return 0;
}

void RestoreIfUnchanged(char *oldFilename, char *newFilename)
{
    FILE *newFp = fopen(newFilename, "r");
    FILE *oldFp = fopen(oldFilename, "r");
    bool changed = False;
    int newCh = EOF;
    int oldCh = EOF;

    if (newFp != 0
     && oldFp != 0)
    {
        do
        {
            newCh = fgetc(newFp);
            oldCh = fgetc(oldFp);
            if (newCh != oldCh)
                break;
        }
        while (newCh != EOF
          &&   oldCh != EOF);
        changed = (newCh != oldCh);
    }

    if (newFp != 0)
        fclose(newFp);

    if (oldFp != 0)
        fclose(oldFp);

    if (!changed)
    {
        if (remove(newFilename) != 0)
            warning("cannot remove %s\n", newFilename);
        else if (rename(oldFilename, newFilename) != 0)
            warning("cannot rename %s\n", oldFilename);
    }
}
