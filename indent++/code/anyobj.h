#ifndef _ANYOBJECT_HEADER
#define _ANYOBJECT_HEADER

// Program code written by Steven De Toni ACBC 11

// This header contains a base class definition with a virtual destructor
// so that existing objects that inherit from it use their proper destructor
// no matter what type they are when being deleted.

// ###############################################################################
// #### ANYOBJECT Class ####
// #########################
// Class used within container (TWOWAYLL) to store objects.
// This is the base class for every other object to use.
class ANYOBJECT
{
      public:
      virtual ~ANYOBJECT (void);
};
#endif
