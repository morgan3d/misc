// $Id: stacklis.h,v 1.3 2005/04/10 18:31:14 tom Exp $
#ifndef _STACK_LIST_HEADER
#define _STACK_LIST_HEADER

// Code written by Steven De Toni ACBC 11
// This header definition contains information of the construction,
// operation of a container class that holds data in linked list
// in stack form.

#include <stdio.h>              // NULL Constant
#include "anyobj.h"             // use Base class definition


// Structure definition used to link the items in the stack
struct ListLink
{
      ListLink*   pLinkedItem;  // linker (pointer to next item in the list)
      ANYOBJECT*  pItem;        // variable used to contain the data
};

class StackList : public ANYOBJECT
{
    protected:
        ListLink*     pCurrentPos;        // pointer to the end of the list
        int           itemCount;          // number of items in list
        int           spaceAvailable;     // used to test if memory
                                            // is still available
    public:
        //#### Constructors

        // Initialise internal variables.
        //
        StackList       (void);

        // Initialise variables, and place item passed in a new list
        //
        // Parameters:
        //     pItem    : Pointer to the object that is will to be stored.
        //                Item must be of descendant ANYOBJECT.
        //
        StackList       (ANYOBJECT* pItem);

        // use the defaults here:
        StackList(const StackList&);
        StackList& operator=(const StackList&);

        //#### Access Methods
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
        int        push            (ANYOBJECT* pItem);

        // Removes a item from the list and returns the value contained within it
        // back to the user. A NULL value is returns if there are no more items
        // within the list.
        //
        // Return Values:
        //     ANYOBJECT* : Pointer to the object last object that was placed
        //                  on the stack. Returns NULL pointer if operation
        //                  failed.
        //
        ANYOBJECT* pop             (void);

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
        ANYOBJECT* peek (int item);

        // Returns the number of items current being stacked.
        //
        // Returns Values:
        //     int :    Num of items within queue.
        //
        int        status          (void);

        // Method returns whether last operation failed due to memory allocation
        // failure.
        //
        // Return Values:
        //     int  : Returns 1 of two values ...
        //            Values:
        //              0  =  memory available
        //             -1  =  Last memory allocation failed.
        //
        int        space           (void);

        //#### Destructor
        // Method will remove all list items from memory if they still exist,
        // no garbage collection provided, or used.
        //
        ~StackList                 (void);
};

#endif
