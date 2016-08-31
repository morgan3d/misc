/**
   \file sort.cpp

   Elegant reference implementations of some common sorting
   algorithms:

   - heapSort
   - insertionSort
   - mergeSort
   - quickSort

   Written in C++ with an eye towards portability to other languages
   such as C, Java, GLSL, CUDA, JavaScript, and Python.

   \author Morgan McGuire, morgan@cs.williams.edu. 

   http://graphics.cs.williams.edu
   http://cs.williams.edu/~morgan/code/

   License: BSD (see download page)

   Last modified 2012-12-26
 */

#include <stdlib.h>

typedef float Key;
class Element {
public:
    /** Sort key */
    Key key;
    
    /** Arbitrary data here ... */
    int data;

    Element(Key key = 0.0f) : key(key), data(0) {}
};


/** Sorts the array of n elements in place by Element::key from least
    to greatest. O(n log n) time, O(1) additional space. 

    This has the best performance of the methods that I profiled,
    beating insertionSort for N > 16.
*/
void heapSort(Element* element, const int N);

/** Sorts the array of n elements in place by Element::key from least
    to greatest. O(n^2) time, O(1) additional space. 

    This was the fastest sort for N <= 16 in practice, but was beaten
    significantly by heapSort for large N when the asymptotic behavior
    emerged.
*/
void insertionSort(Element* element, const int N);

/** Sorts the array of n elements in place by Element::key from least
    to greatest. O(n log n) time, O(n) additional space. Takes advantage
    of pointer arithmetic in C.*/
void quickSort(Element* element, const int N);

/** Sorts the array of n elements in place by Element::key from least
    to greatest. O(n log n) time, O(n) additional space. Does not use
    pointer arithmetic.  Better base for porting.*/
void quickSort2(Element* element, const int N);

/** Sorts the array of n elements in place by Element::key from least
    to greatest. O(n log n) time, O(n) additional space.

    This has the worst performance of the methods that I profiled,
    running in 3x the time of heapSort and 2x the time of quickSort.
*/
void mergeSort(Element* element, const int N);


///////////////////////////////////////////////////////////////////////////////

#define SWAP(a, b) {Element temp = element[a]; element[a] = element[b]; element[b] = temp; }

void insertionSort(Element* element, const int N) {

    // Treat elements [0, numSorted) as sorted and the rest to be a
    // bucket of values awaiting sorting.
    for (int numSorted = 1; numSorted < N; ++numSorted) {
        // Get the next element to be inserted
        const Element temp = element[numSorted];
        
        // Drag temp backwards
        int i;
        for (i = numSorted; (i > 0) && (temp.key < element[i - 1].key); --i) {
            element[i] = element[i - 1];
        }
        
        // Re-insert temp (possibly at the location where it started!)
        element[i] = temp;
    }
}

///////////////////////////////////////////////////////////////////////////////

/** Merge [low, mid] with [mid + 1, high] in place */
void merge(Element* element, int low, int mid, int high, Element* temp) {
    int i = low;
    int j = mid + 1;

    // Index into temp
    int t = low;

    // Merge same-length portions
    while ((i <= mid) && (j <= high)) 
        // Choose the smaller element
        if (element[i].key < element[j].key) 
            temp[t++] = element[i++];
        else 
            temp[t++] = element[j++];

    // Copy remaining elements from the low side
    while (i <= mid) temp[t++] = element[i++];

    // Copy remaining elements from the high side
    while (j <= high) temp[t++] = element[j++];

    // Copy everything back from temp to element
    for (t = t - 1; t >= low; --t)
        element[t] = temp[t];
}

/** High is inclusive */
void mergeSort2(Element* element, int low, int high, Element* temp) {
    if (low < high) {
        int mid = (low + high) / 2;
        mergeSort2(element, low, mid, temp);
        mergeSort2(element, mid + 1, high, temp);
        merge(element, low, mid, high, temp);
    }
}


void mergeSort(Element* element, const int N) {
    Element* temp = (Element*)malloc(sizeof(Element) * N);
    mergeSort2(element, 0, N - 1, temp);
    free(temp);
}

/////////////////////////////////////////////////////////////////////////////


void quickSort(Element* element, const int N) {
    if (N > 0) {
        // Partition elements
        const Element pivot = element[0]; // ...or choose randomly
        int i = 0;
        int j = N;
        
        while (true) {
            while ((element[++i].key < pivot.key) && (i < N));
            while (element[--j].key > pivot.key);
            
            if (i >= j) break;
            
            SWAP(i, j);
        }
        
        SWAP(i - 1, 0);
        
        quickSort(element, i - 1);
        quickSort(element + i, N - i);
    }
}

/////////////////////////////////////////////////////////////////////////////

void quickSort2Rec(Element* element, const int start, const int N) {
    if (N > 0) {
        // Partition elements
        const Element pivot = element[start]; // ...or choose randomly
        int i = start;
        int j = N + start;
        
        while (true) {
            while ((element[++i].key < pivot.key) && (i < N + start));
            while (element[--j].key > pivot.key);
            
            if (i >= j) break;
            
            SWAP(i, j);
        }
        
        SWAP(i - 1, start);
        
        quickSort2Rec(element, start, (i - start) - 1);
        quickSort2Rec(element, i, N - (i - start));
    }
}

void quickSort2(Element* element, const int N) {
    quickSort2Rec(element, 0, N);
}

/////////////////////////////////////////////////////////////////////////////

/** Sift element[parent] down the tree */
void siftDown(Element* element, int parent, int end) {

    const Element value = element[parent];

    int maxChild = parent * 2 + 1;
    while (maxChild <= end) {
        
        // See if the other child's index is larger
        if (maxChild < end) {
            int otherChild = maxChild + 1;
            maxChild = (element[otherChild].key > element[maxChild].key) ? otherChild : maxChild;
        } 
        
        // Stop when the parent is larger than the max child
        if (value.key >= element[maxChild].key) break;

        element[parent] = element[maxChild];
        
        parent = maxChild;
        maxChild = parent * 2 + 1;
    }
    
    element[parent] = value;
}


void heapSort(Element* element, const int N) {
    // Form a max heap

    for (int i = (N / 2); i >= 0; --i) 
        siftDown(element, i, N - 1);
 
    for (int i = N - 1; i >= 1; --i) {
        SWAP(0, i);
        siftDown(element, 0, i - 1);
    }
}
 

#undef SWAP


#if 0 // Sample profiling routines

#include <G3D/G3DAll.h>

/** For timing */
void noSort(Element* element, const int N) {}

void printArray(const Array<Element>& a) {
    for (int i = 0; i < a.size(); ++i) {
        printf("%g ", a[i].key);
    }
    printf("\n");
}


float timeRoutine(void (*sort)(Element*, const int), const int N) {
    static const int iterations = 1000000;

    Array<Element> data;
    Array<Element> src;
    Random rnd;

    for (int i = 0; i < N; ++i) {
        src.append(rnd.integer(0, 20));
    }
    data.resize(src.size());
    
    RealTime t0 = System::time();
    for (int i = 0; i < iterations; ++i) {
        // Restore
        System::memcpy(data.getCArray(), src.getCArray(), sizeof(Element) * src.size());
        sort(data.getCArray(), data.size());
    }
    
    return (System::time() - t0) / iterations;
}


int main(const int argc, const char* argv[]) {
    
    static const int N = 40;
    Array<Element> data;
    Array<Element> src;
    Random rnd;

    for (int i = 0; i < N; ++i) {
        data.append(rnd.integer(0, 30));
    }

    printf("Before: ");
    printArray(data);

    // Test:
    // insertionSort(data.getCArray(), data.size());
    // heapSort(data.getCArray(), data.size());
    // mergeSort(data.getCArray(), data.size());
    // quickSort(data.getCArray(), data.size());
    quickSort2(data.getCArray(), data.size());

    printf("After:  ");
    printArray(data);

    // Time test on small arrays
    const RealTime nt = timeRoutine(noSort, N);
    const RealTime mt = timeRoutine(mergeSort, N) - nt;
    const RealTime qt = timeRoutine(quickSort, N) - nt;
    const RealTime ht = timeRoutine(heapSort, N) - nt;
    const RealTime it = timeRoutine(insertionSort, N) - nt;

    printf("Time for %d elements:\n", N);
    printf(" insertionSort: %d ns\n", iRound(it / units::nanoseconds()));
    printf(" heapSort:      %d ns\n", iRound(ht / units::nanoseconds()));
    printf(" quickSort:     %d ns\n", iRound(qt / units::nanoseconds()));
    printf(" mergeSort:     %d ns\n", iRound(mt / units::nanoseconds()));

    return 0;
}
#endif
