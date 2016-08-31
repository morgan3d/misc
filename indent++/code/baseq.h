// $Id: baseq.h,v 1.3 2005/04/10 18:30:25 tom Exp $
#ifndef _QUEUE_LIST_HEADER
#define _QUEUE_LIST_HEADER

// Code written by Steven De Toni ACBC 11
// this header definition contains a container class that stores data
// in a queued linked list.

#include "anyobj.h" // include base class

struct LinkItem
{
      LinkItem*   pLinkedItem; // linker (pointer to the next item in the list)
      ANYOBJECT*  pStoredItem; // data that is store within a list item
};

class QueueList
{
    protected:
        int           itemCount;
        LinkItem*     pEndPos;
        int           spaceAvailable; // set to 0 for space available,
                                            // -1 if no space available;

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
        LinkItem* newItem (ANYOBJECT* pItem, LinkItem* pEndList);

    public:
        // constructors
        QueueList       (void);

        // Parameters:
        //     pItem    : Pointer to a object to be stored, must be descendant of
        //                base class ANYOBJECT.
        QueueList       (ANYOBJECT* pItem);

        // use the defaults here
        QueueList(const QueueList&);
        QueueList& operator=(const QueueList&);

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
        int      putLast       (ANYOBJECT* pItem);

        // Take first item placed in Queue, out and return it.
        // Type casting is required to return object back to it's original
        // state.
        //
        // Return Values:
        //     ANYOBJECT* : Pointer to the object that was stored within queue.
        //
        ANYOBJECT* takeNext      (void);

        // Returns the number of items contained within the queue.
        //
        // Returns Values:
        //     int :    Num of items within queue.
        //
        int      status          (void);

        // Method returns whether last operation failed due to memory allocation
        // failure.
        //
        // Return Values:
        //     int  : Returns 1 of two values ...
        //            Values:
        //              0  =  memory available
        //             -1  =  Last memory allocation failed.
        //
        int      space           (void);     // return Queue space left

        // Methods is used to peek within the queue at objects, and return there
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
        ANYOBJECT*   peek (int numFromNext);

        // Method will remove all list items from memory if they still exist,
        // no garbage collection provided, or used.
        //
        ~QueueList      (void);
};
#endif
