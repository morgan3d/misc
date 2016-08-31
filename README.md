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
- oculusSample - Oculus SDK OpenGL Sample. Windows Visual Studio project for initializing and rendering to a DK2 or later HMD using OpenGL. June 2015.
- terrain - Continuous detail GPU Terrain, with multi-scale texturing and a hardware optimized variant of the geo clipmap. April 2014 http://casual-effects.blogspot.com/2014/04/fast-terrain-rendering-with-continuous.html

C++
==================================================================
- sort - Elegant C++ reference implementations of heapSort, insertionSort, mergeSort, and quickSort. (now maintained in [The Graphics Codex](http://graphicscodex.com)). December 2012

<!--
- tachyonVR - Unity 5.4 VR Starter Project. August 2016.
<li><a href="python/python-oit.zip">Python implementation of Blended Order Independent Transparency</a> contributed by Nicolas P. Rougier, based on the paper by Louis Bavoil and Morgan McGuire</li>
 <li><a href="C++/glToScreen.cpp">glToScreen.cpp</a> - Reverse OpenGL projection (see also my <a href="http://www.flipcode.com/archives/Object_To_Screen_Space.shtml">flipcode article</a>)
 <li><a href="C++/glProject.cpp">glProject.cpp</a> - Forward OpenGL projection (see also my <a href="http://www.flipcode.com/archives/Projecting_3D_Points.shtml">flipcode article</a>)
 <li><a href="C++/2DOBB.h">2DOBB.h</a> - 2D oriented bounding box collision test (see also my <a href="http://www.flipcode.com/archives/2D_OBB_Intersection.shtml">flipcode article</a>)
 <li><a href="C++/normal2bump.cpp">normal2bump.cpp</a> - Compute bump map (height field/displacment) from a normal map (for G3D 8.x)</li>
 <li><a href="C++/normal2bump-G3D10.cpp">normal2bump-G3D10.cpp</a> - Compute bump map (height field/displacment) from a normal map (for G3D 9.x and 10.x)</li>
 <li><a href="C++/convertToOBJ.cpp">convertToOBJ.cpp</a> - Convert various 3D model formats to OBJ, e.g., IFS, PLY, PLY3, 3DS.</li>
 <li><a href="C++/cgpp-support.h">cgpp-support.h</a>, <a href="C++/cgpp-support.cpp">cgpp-support.cpp</a> - Minimal graphics support routines from Computer Graphics: Principles and Practice for loading a 3D model and image, and displaying and saving images.</li>
</ul>
</div>

<p class="heading">
JavaScript
</p>
<div class="info">
  <ul><li><a href="http://codeheartjs.com">codeheart.js</a> - JavaScript framework for learning to program web and mobile game apps</li>
    <li><a href="http://casual-effects.com/markdeep">Markdeep</a> - An extension of Markdown that works client side in a browser without a plugin and supports diagrams, titles, and LaTeX math</li>
<li><a href="TreeList/TreeListDemo.html">TreeList.js</a> - Lightweight selectable and scrollable tree list UI</li>
<li><a href="relay/relay/relay.js">relay.js</a> - Node.js based relay server and <a href="relay/clientserver/index.html">index.html</a> sample application demonstrating its use.</li>
<li><a href="cardgen/cardgen.zip">cardgen.zip</a> - HTML5/Javascript/CSS playing card template for creating custom decks.</li>
</ul>
</div>

<p class="heading">
Java
</p>
<div class="info">
<ul>
 <li><a href="java/Sandbox.java">Sandbox.java</a> - ClassLoader for dynamic class reloading, useful for plugins.
 <li><a href="RedBlack/RedBlack.java">RedBlack.java</a>, <a href="RedBlack/Demo.java">Demo.java</a> - Simple Red-Black tree demo.
 <li><a href="Splay">Splay Tree</a> applet and source code
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
