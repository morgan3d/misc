// $Id: stacklis.cpp,v 1.3 2005/04/10 18:31:34 tom Exp $
#ifndef _STACK_LIST_CODE
#define _STACK_LIST_CODE

// Code written by Steven De Toni ACBC 11
// This file contains the methods that were defined in stacklist.h
// header file (i.e container class that stores items in a linked list,
// in stack form)

#include "stacklis.h"
#include <stdio.h>          // NULL Constant

// ############################################################################
// #### StackList Class ####
// #########################

// ############################## Public Methods ##############################
// ############################### Constructors ###############################

#define MY_DEFAULT \
      pCurrentPos(NULL), \
      itemCount(0), \
      spaceAvailable(0)

// Initialise internal variables.
//
StackList::StackList (void)
    : MY_DEFAULT
{
}

// Initalise variables, and place item passed in a new list
//
// Parameters:
//     pItem    : Pointer to the object that is will to be stored.
//                Item must be of descendant ANYOBJECT.
//
StackList::StackList (ANYOBJECT* pItem)
    : MY_DEFAULT
{
    push (pItem);
}


// Places a new item in the list (i.e on the stack).
//
// Parameters:
//     pItem    : Pointer to the object that is will to be stored.
//                Item must be of descendant ANYOBJECT.
//
// Return Values:
//     int      : Returns a error code value to indicate whether operation
//                was successful or not.
//                Value:
//                0  =  No Worries, item stacked.
//               -1  =  Item not stacked, memory allocation failure
//
int StackList::push (ANYOBJECT* pItem)
{
    ListLink*    newItem = new ListLink;

    if (newItem)           // not NULL
    {
         // update contents of structure
         newItem->pItem       = pItem;
         newItem->pLinkedItem = NULL;

         if (pCurrentPos)  // not NULL
             newItem->pLinkedItem = pCurrentPos;

         // update start of stack pointer
         pCurrentPos = newItem;
         itemCount++;
         return spaceAvailable;
    }
    else
    {
        spaceAvailable = -1;
        return  spaceAvailable;
    }
}

// Removes a item from the list and returns the value contained within it
// back to the user. A NULL value is returns if there are no more items
// within the list.
//
// Return Values:
//     ANYOBJECT* : Pointer to the object last object that was placed
//                  on the stack. Returns NULL pointer if operation
//                  failed.
//
ANYOBJECT* StackList::pop (void)
{
    ListLink*    pBackUp = pCurrentPos;

    if (pCurrentPos) // not NULL
    {
         ANYOBJECT* pTemp = pCurrentPos->pItem;
         pCurrentPos      = pCurrentPos->pLinkedItem;
         delete pBackUp;
         itemCount--;
         return pTemp;
    }
    else
        return NULL;
}

// Peeks at items within the linked list without removing
// them from the list.
//
// Parameters:
//    int item :     item number in list.
//
// Return Values:
//   ANYOBJECT*  : Returns NULL if operation failed, else
//                 pointer to the object contained at list
//                 number selected!
//
ANYOBJECT* StackList::peek (int item)
{
    ListLink*   pPeekPos = pCurrentPos;

    // invalid range !
    if ( ((item < 1) || (item > itemCount)) || (pPeekPos == NULL) )
              return NULL;

    while (item > 1)
    {
        pPeekPos = pPeekPos -> pLinkedItem;
        item--;
    }

    return pPeekPos -> pItem;
}

// Method returns whether last operation failed due to memory allocation
// failure.
//
// Return Values:
//     int  : Returns 1 of two values ...
//            Values:
//              0  =  memory available
//             -1  =  Last memory allocation failed.
//
int  StackList::space (void)
{
    return spaceAvailable;
}


// Returns the number of items current being stacked.
//
// Returns Values:
//     int :    Num of items within queue.
//
int  StackList::status (void)
{
    return itemCount;
}

// ############################### Destructor ###############################
// Method will remove all list items from memory if they still exist,
// no garbage collection provided, or used.
//
StackList::~StackList  (void)
{
    ANYOBJECT* pTest = pop();

    while (pTest != NULL)
    {
        delete pTest;
        pTest = pop();
    }
}

#endif
