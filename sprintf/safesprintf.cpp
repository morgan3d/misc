/*
Here's a safe version of sprintf called format.  Unlike sprintf, it
won't produce buffer overflows and doesn't require the caller to
allocate and deallocate the output buffer.  The return value is an
std::string that will be deallocated automatically when the last
reference to it is dropped.  The function is optimized for short
strings but will work correctly for strings up to 1e6 bytes in length.

Example usage:
  int month = 7, day = 10, year = 85;
  std::string name = "Birthday";
  std::string result = format("%s = %d-%02d-%02d\n", f.c_str(), month, day, year);


Morgan McGuire
*/

#include <string>
#include <stdio.h>
#include <cstdarg>
#ifdef _WIN32
    #include <windows.h>
#else
    #include <varargs.h>
#endif

std::string __cdecl format(const char* fmt ...) {
	va_list argList;
    va_start(argList, fmt);
    std::string result = vformat(fmt, argList);
    va_end(argList);

    return result;
}


std::string vformat(const char *fmt, va_list argPtr) {
    // We draw the line at a 1MB string.
    const int maxSize = 1000000;

    // If the string is less than 161 characters,
    // allocate it on the stack because this saves
    // the malloc/free time.
    const int bufSize = 161;
	char stackBuffer[bufSize];

    int attemptedSize = bufSize - 1;

    int numChars = vsnprintf(stackBuffer, attemptedSize, fmt, argPtr);

    if (numChars >= 0) {
        // Got it on the first try.
        return std::string(stackBuffer);
    }

    // Now use the heap.
    char* heapBuffer = NULL;

    while ((numChars == -1) && (attemptedSize < maxSize)) {
        // Try a bigger size
        attemptedSize *= 2;
        heapBuffer = (char*)realloc(heapBuffer, attemptedSize + 1);
        numChars = vsnprintf(heapBuffer, attemptedSize, fmt, argPtr);
    }

    std::string result = std::string(heapBuffer);

    free(heapBuffer);

    return result;

}
