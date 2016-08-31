This repository contains miscellaneous code from throughout my career.

I do not support this code through github--use it at your own risk, and please don't send
feature requests or ask for help with it. Some of it was written while I was an undergraduate
and may not compile on modern machines.

Some additional open source projects that I _do_ actively support are hosted elsewhere due to
github's file size and other restrictions. These are:

- [The G3D Innovation Engine](http://g3d.cs.williams.edu) C++ 3D graphics library
- [codeheart.js](http://codeheartjs.com) Javascript 2D game library
- [Markdeep](https://casual-effects.com/markdeep) Document beautification tool
- [iCompile](http://g3d.cs.williams.edu/g3d/G3D10/build/manual/icompile-manual.html) Zero-configuration build system

The code in this repository is organized by topic.

Graphics
==================================================================
- **oculusSample** - Oculus SDK OpenGL Sample. Windows Visual Studio project for initializing and rendering to a DK2 or later HMD using OpenGL. June 2015.
- **terrain** - Continuous detail GPU Terrain, with multi-scale texturing and a hardware optimized variant of the geo clipmap. April 2014 http://casual-effects.blogspot.com/2014/04/fast-terrain-rendering-with-continuous.html
- **normal2bump** - Compute bump map (height field/displacment) from a normal map. 2014.
- **convertToOBJ** - Convert various 3D model formats to OBJ, e.g., IFS, PLY, PLY3, 3DS. 2013
- **cgpp3** - Minimal graphics support routines from Computer Graphics: Principles and Practice 3rd edition for loading a 3D model and image, and displaying and saving images. 2012.
- **glToScreen** - Reverse OpenGL projection from my [flipcode article](http://www.flipcode.com/archives/Object_To_Screen_Space.shtml). Pre-2005.
- **glProject** - Forward OpenGL projection from my [flipcode article](http://www.flipcode.com/archives/Projecting_3D_Points.shtml). Pre-2005.
- **2DOBB** - 2D oriented bounding box collision test from my [flipcode article](http://www.flipcode.com/archives/2D_OBB_Intersection.shtml). Pre-2005.

C++
==================================================================
- **sort** - Elegant C++ reference implementations of heapSort, insertionSort, mergeSort, and quickSort. (now maintained in [The Graphics Codex](http://graphicscodex.com)). December 2012
- **indent++** - Pretty-printer for indenting existing C++ files (handy for printing assignments when grading). 2012.
- **getip** - Obtain the current machine's IP address. Pre-2005.
- **kbhit** - Linux/OS X implementation of Windows console `kbhit()`. Pre-2005.
- **sprintf** - Safe `sprintf` (now maintained in [G3D](http://g3d.cs.williams.edu) as `format()`). Pre-2005.

JavaScript
==================================================================
- **cardgen** - HTML5/Javascript/CSS playing card template for creating custom decks. May 2015.
- **relay** - Node.js based relay server and sample application demonstrating its use. 2013
- **treeList** - Lightweight selectable and scrollable tree list UI. 2012.


Java
==================================================================

- **redblack** - Red-black Tree implementation and demo. 2008.
- **splay** - Splay Tree applet and source code. 2003.

<!--
- tachyonVR - Unity 5.4 VR Starter Project. August 2016.
<li><a href="python/python-oit.zip">Python implementation of Blended Order Independent Transparency</a> contributed by Nicolas P. Rougier, based on the paper by Louis Bavoil and Morgan McGuire</li>

Java
</p>
<div class="info">
<ul>
 <li><a href="java/Sandbox.java">Sandbox.java</a> - ClassLoader for dynamic class reloading, useful for plugins.
 <li><a href="RedBlack/RedBlack.java">RedBlack.java</a>, <a href="RedBlack/Demo.java">Demo.java</a> - Simple Red-Black tree demo.
 <li><a href="http://cs.williams.edu/~morgan/cs136-s08/darwin2.0/">Darwin 2.0</a> - AI programming game with isometric 3D graphics using concurrency
 <li><a href="http://cs.williams.edu/~morgan/darwin/">Darwin 2.1</a> - AI programming game with isometric 3D graphics using coroutines (no explicit synchronization needed!)
</ul>
</div>

<p class="heading">
Scheme
</p>
<div class="info">
<ul><li><a href="Scheme/infix.scm">infix.scm</a> - Recursive descent infix parser and macro for Scheme</li>
</ul>
</div>

C/C++
===========================================================================
<li><a href="C++/indent++.zip">indent++</a> Platform-independent command-line program to auto-indent C++ and JavaScript code (similar to the Unix indent program for C), with precompiled OS X binary.</li>
<li><a href="C++/getip.cpp">getip.cpp</a> Get IP address, subnet mask, broadcast address, and MAC address of the network adapter(s) on Unix-based systems.</li>
<li><a href="C++/kbhit.cpp">_kbhit.cpp</a> _kbhit for Linux/POSIX without using Curses (see also my <a href="http://www.flipcode.com/archives/_kbhit_for_Linux.shtml">flipcode article</a>)
<li><a href="C++/safesprintf.cpp">safesprintf.cpp</a> - An sprintf implementation that prevents buffer overflows (a newer version appears as the "format" function in the G3D library. See also my <a href="http://www.flipcode.com/archives/Safe_sprintf.shtml">flipcode article</a>)

-->
