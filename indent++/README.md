-- $Id: README,v 1.2 2002/11/23 13:51:29 tom Exp $
-- This is the original README - see CHANGES for a current history -TD
-------------------------------------------------------------------------------
History
-------

Version 0.9
-----------
Heaps of bugs, should never been released.

Version 1.0
-----------
Heaps of bug fixes, have tested the program heaps, and tried to
extract 98% of the errors, any bugs found while using this
program are to be considered as undocumented features.

Future Versions will include most of the limitations of version 1
fixed. I haven't fixed these yet as I'd rather have a program
that works happily instead of one that is giving me eternal
hassles (plus project dead lines). The next updated version will
be released within early December.

Version 1.5
-----------
       - Couple more bug fixes, and some code optimisation.
       
       - Unlimited (ram limited) amount of line decoding so even
         the most tangled code can be decoded (uses recursion).
         
       - Unlimited amount of single code indenting is provided 
         (fixed from last version (uses recursion))
         
       - Options for program can entered via command line, or    

         configuration file.
         
       - Operating system I/O redirection is fully support within
         the program.

       - User definable line buffer size.
       
I have tried to test this program rigorously to see that I have
no rouge pointers lying within ... (fingers crossed). Anyways it
ran fine under Qemm, and Windows (i.e. no exception errors due to
incorrect memory access). Using Qemm V7.0, the program uses DPMI
memory allocation so you the program allocate memory exceeding
640 k in MS-DOS memory model. This is done by processing large
files (i.e. 1 meg+), and using a very large buffer (i.e. 10000).
Large buffers above 10 are not really require and will slow
processing because of extensive searching (plus my Queue object
isn't the fastest of designs ever).

Version 1.55
------------

       - The only real update is working the code so that it     

         functions/compiles under Unix. 
         
       - Removed all segmentation violations.
       
       - Fixed a couple of little things ... I forget.
       
       - Input redirection under DOS fails, but works under Unix.

Version 1.6 (Final)
-------------------
This will be the final release from me of this software. This
version fixes a few more bugs, some small, some large, but I
think this time the program is about as stable as I'm going to
get it. The code will still be able to compile under both Unix,
and MS-DOS. 

     - Added a backup file feature.
     
     - Added a time feature just for the hell of it.

     - Fixed a decoding problem with quotes

     - Fixed a decoding/construction problem with tabs. The      

       current method will expand all tabs to spaces that are    

       ready via the input data stream.

Version 1.61 (User Update)
--------------------------
A Canadian programmer (Justin Slootsky) introduced a new feature
into this program that allows code that has no accompanied code
to be indented as per normal code. Although just a few lines of
code, this new feature is very effective.

Version 1.629 (Bug Update)
---------------------------
Fixed a couple of minor bugs that would cause a little havock.
Added preprocessor handling, so that any preprocessor commands are always
place at position 1;

Version 1.7 (Bug Update)
------------------------
Fixed C comment process bugs.
fixed locating configuration file (i.e uses argv[0] now) unless -fnc
switch is used.

Version 1.75 (Bug Update)
-------------------------
Fixed single statement formating over multiple lines (i.e. if, while type
statements)
Fixed a couple of simple errors that Manuel T. Petit pointed out in my
code.

Version 1.8 (Bug Of A Bug Update)
----------------------------------
This bug was created becuase of Unix's perdantic checking of memory (i.e. MNU).
I haven't checked all the conditions of a certain section of code, this caused
an 'if' statement within case structure to prematurely be trashed. The result
of which is the indent structure is removed and the code output doesn't align
correctly.




        
Util
----
Text Conversion:
I've provided a program than when compiled will convert MS-DOS
text input UNIX text using standard output, or Unix text to
MS-DOS text (OS dependant). Use this program to convert my source
so that it can be compiled without worries of carriage returns.


Compiling
---------
The only OS type system that this program has been fully tested
on is MS-DOS, so I give no guarantees that this program will
function under any other OS other then DOS. It's up to you to fix
any possible conflicts between compilers/operating systems. This
software is provided on the "As Is Where Is" bases.

Compiled using the following compilers ...

       Borland Turbo C   V1.0
       Borland Turbo C   V3.0
       GNU           G++ V1.05 (DOS)
       GNU           G++ V2.62 (UNIX)

       
Feed Back
---------     

Thanks to the few people that sent me mail pointing out my
deliberate mistakes :-) within my code/documentation. If people
use this program for other projects, I wouldn't mind hearing
about it, see DOCs for addresses.


Notices
-------
Thanks to:

        Pink Floyd (some of the best music ever written to program to)
        
        Black Jack, 8forty8, Knight Shade, Cold Shock ...
        (Some of the best heavy rock/metal bands in Hamilton/N.Z)
        
        GNU        (For producing a brilliant compiler)
        Borland    (Brilliant programming environment)
