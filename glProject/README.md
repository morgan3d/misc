It is occasionally necessary to project points from 3D to 2D in software. A sample application
is the rendering HUD effects like targeting boxes and character names in a game. The following
code transforms and projects a 3D point or vector by the current OpenGL matrices and returns a
2D vector with associated depth value. The 2D vector is in the screen coordinate frame, where y
increases from 0 at the top of the screen to height - 1 at the bottom and x increases from 0 at
the left to width - 1 at the right. 

Morgan McGuire, pre-2005
