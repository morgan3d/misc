The OpenGL pipeline automatically transforms object space vertices to homogeneous clip space
and then to screen space--pixel coordinates and a z-buffer value betwen 0 and 1. When
combining 2D and 3D rendering, you need to perform that transformation manually. Two example
applications are finding the 3D ray corresponding to a 2D mouse position and the location at
which to render 2D text over 3D vertices. The `glToScreen` function transforms an
object space point to screen space using the current `GL_MODELVIEW` and `GL_PROJECTION`
matrices. The resulting xy values are in pixels, the z value is on the glDepthRange scale,
which defaults to [0, 1]), and the w value contains rhw. The rhw value is -1/z for camera space
z (note that a true mathematical projection gives w = 1 instead.) The rhw value is useful for
scaling line and point size with perspective, which OpenGL does not do by default. Morgan
McGuire

Morgan McGuire pre-2005
