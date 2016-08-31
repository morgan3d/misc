#ifndef _QUEUE_LIST_CODE
#define _QUEUE_LIST_CODE

// $Id: baseq.cpp,v 1.5 2005/04/10 18:29:14 tom Exp $
// Code written by Steven De Toni ACBC 11

// These class methods used to implement a object that holds other objects
// that are descendant of ANYOBJECT (i.e universal container).

#include "baseq.h"
#include <stdio.h>      // NULL CONSTANT


// ############################################################################
// #### QueueList Class ####
// #########################

// ############################ Protected Methods #############################

// Create new list item and place programmer's data within it,
// make new links with previous item if wished.
// returns a pointer to the new item, NULL if operation failed.
//
// Parameters:
//     pItem    : Pointer to the object to be stored.
//     LinkItem : Pointer to end of list where item to be added.
//
// Return Values:
//     LinkItem : returns pointer to newly added item in list,
//                NULL if operation failed. However items within list
//                before hand still exist.
LinkItem* QueueList::newItem (ANYOBJECT* pItem, LinkItem* pEndList)
{
    LinkItem*  pNewStruct = new LinkItem;

    if (pNewStruct != NULL)
    {
        pNewStruct->pLinkedItem    = pEndList;
        pNewStruct->pStoredItem    = pItem;
    }

    return pNewStruct;
}


// ############################## Public Methods ##############################
// ############################### Constructors ###############################
#define MY_DEFAULT \
   itemCount(0), \
   pEndPos(NULL), \
   spaceAvailable(0)

QueueList::QueueList (void)
    : MY_DEFAULT
{
}

// Parameters:
//     pItem    : Pointer to a object to be stored, must be descendant of
//                base class ANYOBJECT.
QueueList::QueueList (ANYOBJECT* pItem)
    : MY_DEFAULT
{
   putLast(pItem);
}

#undef MY_DEFAULT

// ########################### User Methods ###################################

// Place programmers object into list
//
// Parameters:
//     pItem    : Pointer to a object to be stored, must be descendant of
//                base class ANYOBJECT.
//
// Return Values:
//     int      : Returns a error code indicating whether operation was
//                successful.
//                Values:
//                    0 = No Worries
//                   -1 = Arrgh ... No memory
//
int QueueList::putLast (ANYOBJECT* pItem)
{
    LinkItem*   pNewItem = newItem (pItem, pEndPos);
    if (pNewItem != NULL)
    {
        pEndPos = pNewItem;
        itemCount++;
        return 0;
    }
    spaceAvailable = -1;
    return -1;          // could not add item to list!
}


// Take first item placed in Queue, out and return it.
// Type casting is required to return object back to its original
// state.
//
// Return Values:
//     ANYOBJECT* : Pointer to the object that was stored within queue.
//
ANYOBJECT* QueueList::takeNext (void)
{
    if (pEndPos != NULL)
    {
        LinkItem* pUpDateList = pEndPos;
        LinkItem* pStartPos   = pEndPos;

        // move down list until start has been reached
        while (pStartPos->pLinkedItem != NULL)
            pStartPos = pStartPos->pLinkedItem;

        if (pStartPos != pUpDateList) // if not the last item in list
        {
            // retrieve data and delete item from list
            while (pUpDateList->pLinkedItem != pStartPos)
            pUpDateList = pUpDateList->pLinkedItem;
        }
        else
        {
            pEndPos = NULL;     // start new list after all items gone
        }

        ANYOBJECT* pTemp = pStartPos->pStoredItem;  // copy value to user
        pUpDateList->pLinkedItem = NULL;            // make new start of list
        delete pStartPos;                           // delete object
        itemCount--;                                // one less
        if (spaceAvailable)                         // if no memory available before...
            spaceAvailable = 0; // there is now!
        return pTemp;
    }
    else
        return NULL;
}

// Returns the number of items contained within the queue.
//
// Returns Values:
//     int :    Num of items within queue.
//
int QueueList::status (void)        // return number of item in Queue
{
    return itemCount;
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
int QueueList::space (void)     // return Queue space left
{
    return spaceAvailable;      // return -1 if no space available
}

// Methods is used to peek within the queue at objects, and return their
// pointer without taking them out of the queue.
//
// Parameters:
//     NumFromNext : The object number to look at from the start of the
//                   queue. The start of the queue is 1, not 0.
//
// Return Values:
//     ANYOBJECT* : Pointer to the object that is stored within queue,
//                  at said position. Returns NULL if operation failed.
//
ANYOBJECT*   QueueList::peek (int numFromNext)
{
    if (pEndPos != NULL)
    {
        //if (numFromNext > itemCount) //error checking !
        //   return NULL;

        int count = itemCount - numFromNext;
        LinkItem* pStartPos   = pEndPos;

        if (count >= 0)
        {
            // move down list until start has been reached
            while (count > 0)
            {
                  pStartPos = pStartPos->pLinkedItem;
                  count--;
            }

            if (pStartPos != NULL)
                return pStartPos->pStoredItem;
        }
    }
    return NULL;
}



// ############################### Destructor ###############################
// Method will remove all list items from memory if they still exist,
// no garbage collection provided, or used.
//
QueueList::~QueueList (void)
{
    LinkItem* pTemp = pEndPos;

    while (pEndPos != NULL)
    {
        pEndPos = pEndPos->pLinkedItem;   // advance to next item
        delete    pTemp  ->pStoredItem;   // kill data contained
        delete    pTemp;                  // kill item
        pTemp   = pEndPos;
    }
}

#endif
