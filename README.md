This repository contains miscellaneous code from throughout my career.

I regularly add to this repo but do not support this code through github--use it at your own risk, and please don't send
feature requests or ask for help with it. Some of it was written while I was an undergraduate
and may not compile on modern machines.

Some additional open source projects that I _do_ actively support are hosted elsewhere due to
github's file size and other restrictions. These are:

- [The G3D Innovation Engine](https://casual-effects.com/g3d) C++ 3D graphics library
- [codeheart.js](http://casual-effects.com/codeheart) Javascript 2D game library
- [Markdeep](https://casual-effects.com/markdeep) Document beautification tool
- [iCompile](https://casual-effects.com/g3d/G3D10/build/manual/icompile-manual.html) Zero-configuration build system
- [include.js](https://morgan3d.github.io/include.js/) Cross-domain, cross-browser HTML include tag

The code in this repository is organized by topic.

Unity
==================================================================
- tachyon - Unity 5.4 starter project for a Pong-like 3D game. Particle systems, events, gamepad, logic, physics, etc. August 2016.
- tachyonVR - Unity 5.4 VR starter project for a Pong-like 3D game. Teleporting, fast rendering, Vive controllers, etc. August 2016.


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
- **sprintf** - Safe `sprintf` (now maintained in [G3D](https://casual-effects.com/g3d) as `format()`). Pre-2005.

JavaScript
==================================================================
- **cardgen** - HTML5/Javascript/CSS playing card template for creating custom decks. May 2015.
- **relay** - Node.js based relay server and sample application demonstrating its use. 2013.
- **treeList** - Lightweight selectable and scrollable tree list UI. 2012.
- **jsmaze** - Recursive perfect maze generator, with wrapping and imperfect options. 2018.
- **jsvectorify** - Vector operations and operator overloading. 2018.
- **jsmenu** - Lightweight library for dropdown menus. 2018.
- **jsloadmanager** - Caching and post-processing for recursive resource loading via XMLHttpRequest/fetch. 2018.


Java
==================================================================
- **javasandbox** - ClassLoader for dynamic class reloading, useful for plugins. Executes arbitrary Java code in a protected sandbox. 2008.
- **redblack** - Red-black Tree implementation and demo. 2008.
- **javadoom** - Simple Doom-style ray caster written for a data structures course. 2008.
- **javarasterizer** - Simple rasterizer written for a data structures course. 2008.
- **splay** - Splay Tree applet and source code. 2003.


Lua/PICO-8
==================================================================
- **platformer** - Full featured character simulation for a 2D platformer. 2017.
- **p8particle** - Very fast single-pixel particle system for PICO-8. 2017.
- **p8sort** - Very fast PICO-8 sort. 2017.
- **p8escape** - Allow lowercase characters in printed PICO-8 strings. This is actually a web utility, not PICO-8 code itself. 2017
- **p8controller** - Minimal-memory PICO-8 controller image for instruction screens. 2017.
- **p8pathfinder** - Fully general PICO-8 A* (A-star) and Dijkstra pathfinding in a single function. 2017.
- **p8scale** - Enhanced HQx 2x, 3x, 4x scaling with transparency and better curves

Scheme
==================================================================
- **infix** - Recursive descent infix parser and macro for Scheme. 2003.

Other
==================================================================
- **xenon** - 16-bit Windows 3.1 video game written in Visual Basic. 1995.

<!--
TODO:

 <li><a href="http://cs.williams.edu/~morgan/cs136-s08/darwin2.0/">Darwin 2.0</a> - AI programming game with isometric 3D graphics using concurrency
 <li><a href="http://cs.williams.edu/~morgan/darwin/">Darwin 2.1</a> - AI programming game with isometric 3D graphics using coroutines (no explicit synchronization needed!)



-->
