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
// $Id: tabs.cpp,v 1.24 2005/04/11 00:20:18 tom Exp $
// Tab conversion & first-pass scanning

#include <ctype.h>
#include <string.h>            // strlen(), strstr(), strchr(), strcpy(), strcmp()

#include "bcpp.h"

// ----------------------------------------------------------------------------
// Function takes a unsigned char and converts it to a C type string that
// contains the char's value, but in octal (i.e "\000" = null char).
//
// Parameters:
// value     : The value that wishes to be converted
//
// Return Values:
// char*     : Returns a pointer to the string that was converted.
// Memory is allocated via the new command, and once string has been used,
// memory should be returned to the system.
//
static char* ConvertCharToOctal (unsigned char value)
{
    const char octalVals[] = "01234567";

    char* pOctalValue = new char[5]; // \000 digits plus null terminator

    if (pOctalValue != NULL)
    {
        int last = 1;
        switch (value)
        {
            case '\a':  pOctalValue[1] = 'a';   break;
            case '\b':  pOctalValue[1] = 'b';   break;
            case '\f':  pOctalValue[1] = 'f';   break;
            case '\n':  pOctalValue[1] = 'n';   break;
            case '\r':  pOctalValue[1] = 'r';   break;
            case '\t':  pOctalValue[1] = 't';   break;
            default:
                last = 3;
                for (int pos = last; pos >= 1; pos--)
                {
                    pOctalValue[pos] = octalVals[(value & 7)];
                    value >>= 3; // left shift to next three bits
                }
        }
        pOctalValue[0] = ESCAPE;
        pOctalValue[last+1] = NULLC;
    }

    return pOctalValue;
}

// ----------------------------------------------------------------------------
// Compute the number of characters in an escape
static int skipEscape(char *String)
{
    int it = 1;
    int n = 1;

    if (isdigit(String[n]))
    {
        while (n <= 3)
        {
            if (isdigit(String[n++]))
                it = n-1;
            else
                break;
        }
    }
    else if (String[n] == 'x')
    {
        while (n <= 3)
        {
            if (isxdigit(String[++n]))
                it = n-1;
            else
                break;
        }
    }
    return it;
}

// ----------------------------------------------------------------------------
#ifdef DEBUG
static const char *showCharState(CharState theState)
{
    const char *it;
    switch (theState)
    {
        default:
        case Blank:     it = "Blank";   break;
        case PreProc:   it = "PreProc"; break;
        case Normal:    it = "Normal";  break;
        case Comment:   it = "Comment"; break;
        case Ignore:    it = "Ignore";  break;
        case DQuoted:   it = "DQuoted"; break;
        case SQuoted:   it = "SQuoted"; break;
    }
    return it;
}
#endif

// ----------------------------------------------------------------------------
// Compute the state after this character is processed
static void nextCharState(char * &String, CharState &theState, int &skip)
{
    if (skip-- <= 0)
    {
        skip = 0;
        if (theState == Blank)
        {
            if (!isspace(String[0]))
                theState = Normal;
        }
        if (theState == Normal)
        {
            switch (String[0])
            {
                case ESCAPE:
                    skip = skipEscape(String);
                    break;
                case DQUOTE:
                    theState = DQuoted;
                    break;
                case SQUOTE:
                    theState = SQuoted;
                    break;
                case '/':
                    switch (String[1])
                    {
                    case '*':
                        theState = Comment;
                        skip = 1;
                        break;
                    case '/':
                        theState = Ignore;
                        break;
                    default:
                        break;
                    }
                    break;
                case SPACE:
                case TAB:
                    theState = Blank;
                    break;
                default:
                    break;
            }
        }
        else if (theState == Comment)
        {
            if (String[0] == '*'
             && String[1] == '/')
            {
                theState = Normal;
                skip = 1;
            }
        }
        else if (theState == SQuoted)
        {
            switch (String[0])
            {
                case SQUOTE:
                    theState = Normal;
                    break;
                case ESCAPE:
                    skip = skipEscape(String);
                    break;
                default:
                    break;
            }
        }
        else if (theState == DQuoted)
        {
            switch (String[0])
            {
                case DQUOTE:
                    theState = Normal;
                    break;
                case ESCAPE:
                    skip = skipEscape(String);
                    break;
                default:
                    break;
            }
        }
    }
}

// ----------------------------------------------------------------------------
// Check for non-printable characters, which we'll either quote or remove,
// depending on whether they're in strings or not.
static int NonPrintable(char c, int mode)
{
    int it = False;
    unsigned char check = static_cast<unsigned char>(c);

    // remove chars below a space, but not if char is a TAB.
    if (check < SPACE && check != TAB) {
        it = True;
    } else if (mode == 1) {
        it = (check >= 127);                    /* non 7-bit ASCII? */
    } else if (mode == 3) {
        it = (check >= 127) && (check < 160);   /* ISO C1 character? */
    }
    return it;
}

// ----------------------------------------------------------------------------
// Function expands tabs to spaces; the number of spaces to expand to is
// dependent upon the tabSpaceSize parameter within user settings, and
// tab column positions.
//
// Parameters:
//      pString     : Pointer to the string to process !
//      tabLen      : How much a tab is worth in spaces.
//      deleteChars : mode to select non-printing characters for removal/quoting
//      quoteChars  : quote non-printing characters
//      curState    : character-state at beginning (end) of string
//      lineState   : character-states within string
//
//      curState and lineState are set as side-effects
//
void ExpandTabs (char* &pString,
    int tabLen,
    int deleteChars,
    Boolean quoteChars,
    CharState &curState, char * &lineState, Boolean &codeOnLine)
{
    int   col = 0;
    int   skip = 0;
    size_t last = 0;
    char* pSTab = pString;
    bool  expand = True;
    bool  my_pString = False;
    bool  had_print = False;
    CharState oldState = curState;

    lineState = new char[strlen (pString) + 1];
    if (lineState == 0)
        return;

    lineState[0] = NullC;

    //TRACE((" ExpandTabs(%s)%s\n", pString, codeOnLine ? " code" : ""))
    while (*pSTab != NULLC)
    {
        col++;

        if (isgraph(*pSTab))
            had_print = True;

        if (skip || !isspace(*pSTab))
            last = col + skip;

        if (*pSTab == TAB                       // calculate tab positions !
         && expand
         && skip == 0
         && !(had_print && (curState == Ignore || curState == Comment))
         && curState != SQuoted
         && curState != DQuoted)
        {
            int tabAmount = 0;

            // tab is first character !!!!
            if (col == 1)
                tabAmount = tabLen;
            else
                tabAmount = ((((col+tabLen-1) / tabLen)) * tabLen) - col + 1;

            //TRACE(("amount:%d, col:%d, state:%s (%d)\n", tabAmount, col, showCharState(curState), had_print))
            if (tabAmount > 0)
            {
                // create newString, remove tab !
                char* pNewString = new char[strlen (pString) + tabAmount + 1];
                char* pNewStates = new char[strlen (pString) + tabAmount + 1];

                if (pNewString == NULL
                 || pNewStates == NULL)
                {
                    if (my_pString)
                    {
                        delete[] pString;
                        pString = 0;
                    }
                    delete[] lineState;
                    return;
                }
                my_pString = True;

                strcpy (pNewStates, lineState);
                delete[] lineState;
                lineState = pNewStates;

                // copy first part
                strcpy (pNewString, pString);

                // add spaces
                char *pAddSpc = pNewString + col - 1;
                while (tabAmount-- > 0)
                    *pAddSpc++ = SPACE;

                // add original trailing spaces
                strcpy (pAddSpc, pSTab+1);
                delete[] pString;               // remove old string from memory
                pString = pNewString;
                pSTab   = pString + col - 1;    // point to the first blank
                //TRACE(("...%d:%s\n", col, pString))
            }
            else
                *pSTab = SPACE;

        }
        // SCCS ID contains a tab that we don't want to touch
        else if (*pSTab == '@' && !strncmp(pSTab+1, "(#)", 3))
        {
            expand = False;
        }
        else if (NonPrintable(*pSTab, deleteChars))
        {
            if (quoteChars
             && (curState == SQuoted
              || curState == DQuoted)) {
                char* pOctal = ConvertCharToOctal(*pSTab);
                char* pTemp = new char[strlen(pString)+strlen(pOctal)+1];
                if (pOctal == 0 || pTemp == 0)
                {
                    delete[] pOctal;
                    delete[] pTemp;
                    return;
                }
                *pSTab = NULLC;
                strcpy(pTemp, pString);
                strcat(pTemp, pOctal);
                strcat(pTemp, pSTab+1);
                pSTab   = pTemp + (pSTab - pString);

                delete[] pString;
                pString = pTemp;

                pTemp = new char[strlen(pString)+strlen(pOctal)+1];
                if (pTemp == 0)
                {
                    delete[] pOctal;
                    delete[] pTemp;
                    delete[] pString;
                    pString = NULL;
                    return;
                }
                strcpy(pTemp, lineState);

                delete[] lineState;
                lineState = pTemp;

                delete[] pOctal;
            }
            else    // simply remove the character
            {
                int n = 0;
                while ((pSTab[n] = pSTab[n+1]) != NULLC)
                    n++;
            }
            col--;
            //TRACE(("re-interpret col %d\n", col))
            continue;   // re-interpret character
        }

        if (skip == 0)
            oldState = curState;
        nextCharState(pSTab, curState, skip);

        // Set the saved-state based on whether we're transitioning from
        // something that's got quotes (which are part of it):
        lineState[col-1] = (curState == Normal)
                && ((oldState == DQuoted)
                 || (oldState == SQuoted)
                 || (oldState == Comment))
                   ? oldState
                   : curState;

        // Override the first '#' on a non-continued line to mark a
        // preprocessor-control.
        if (*pSTab == POUNDC
         && !codeOnLine
         && ispunct(curState))
        {
            lineState[col-1] = PreProc;
        }
        else if (ispunct(lineState[col-1]))
        {
            codeOnLine = True;
        }

        lineState[col] = NullC;

        pSTab++;
    }

    // Set up for the next time through this procedure
    if (curState == Ignore)
        curState = Normal;
    if (col == 0
     || pString[col-1] != ESCAPE)
    {
        codeOnLine = False;
    }

    if (skip == 0
     && (curState == DQuoted
      || curState == SQuoted))
        curState = Normal;    // recover from syntax error

    if (last < strlen(pString))
    {
        pString[last] = NULLC;      // trim trailing blanks
        lineState[last] = NullC;
    }

    TRACE((" Expanded  (%s)\n", pString));
    TRACE((" lineState (%s)\n", lineState));
    TRACE(("%s %d/%d %s\n", last > strlen(pString)+1 ? "FIXME" : "", last, strlen(pString), showCharState(curState)));
}

// ----------------------------------------------------------------------------
// This function is used to allocate memory for indentation within function
// OutputToOutFile(). Once the memory needed is allocated, it fills the memory
// with spaces, or tabs depending upon the fill mode.
//
// Parameters:
// Mode         : Defines the fill mode of the memory that it allocate
//             1 = tabs only
//             2 = spaces only
//             3 = both
// len       : Number of bytes needed to be allocated
// spaceIndent:Number of memory locations a tab character take up
//
// Return Values:
// char*     : Returns a pointer to the memory/string that was allocated
//
char* TabSpacing (int mode, int col, int len, int spaceIndent)
{
    char* pOutTab = NULL;
    char* pOutSpc = NULL;

    if ((mode & 1) == 1)
    {
        int numOfTabs = 0;

        // bypass exception error
        if (spaceIndent > 0)
        {
           numOfTabs = ((len+col) / spaceIndent) - (col / spaceIndent);
           if (len != 0)
               len = (len + col) % spaceIndent;
        }

        pOutTab = new char[numOfTabs + 1];
        if (pOutTab != NULL)
        {
            for (int fillTabs = 0; fillTabs < numOfTabs; fillTabs++)
                    pOutTab[fillTabs] = TAB;
            pOutTab[numOfTabs] = NULLC;
        }
        else
            return NULL; // memory allocation failed

        // If not in both tab, and space concatenation.
        if ((mode & 2) == 0)
              return pOutTab;
    }//bit 0 set !

    if ((mode & 2) == 2)
    {
        if (pOutTab == NULL) //##### normal space allocation !
        {
            pOutSpc = new char[len+1];
            if (pOutSpc != NULL)
            {
                for (int fillSpcs = 0; fillSpcs < len; fillSpcs++)
                    pOutSpc[fillSpcs] = SPACE;
                pOutSpc[len] = NULLC;
                return pOutSpc;   //##### return end product
            }
            else
                return NULL;    // memory allocation failed
        }
        else  // else a mix of spaces & tabs
        {
            int numOfSpcs = 0;

            if (spaceIndent > 0)
               numOfSpcs = len % spaceIndent;

            pOutSpc = new char[numOfSpcs+1];
            if (pOutSpc != NULL)
            {
                for (int fillSpcs = 0; fillSpcs < numOfSpcs; fillSpcs++)
                    pOutSpc[fillSpcs] = SPACE;
                pOutSpc[numOfSpcs] = NULLC;
            }
            else
                return NULL; // memory allocation failed
        }
    }// bit 1 set

    //##### Concatenate tabs & spaces
    if ( ((mode & 1) == 1) && ((mode & 2) == 2) )
    {
        char* pConCat = new char[(strlen (pOutTab) + strlen (pOutSpc) + 1)];
        // #### Check memory allocation
        if (pConCat == NULL)
        {
            delete[] pOutTab;
            delete[] pOutSpc;
            return NULL;
        }
        strcpy (pConCat, pOutTab);
        strcpy (pConCat + strlen (pConCat), pOutSpc);
        delete[] pOutTab;
        delete[] pOutSpc;
        return pConCat;
    }

    return NULL; //##### illegal mode passed !
}
