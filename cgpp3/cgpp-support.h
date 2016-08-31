/**
  This is a tiny support code base that gives you enough
  infrastructure to write a "setPixel"-based renderer without any
  boilerplate in your own code.

  It defines Vector3, Vector2, Color3, Ray, Triangle, and Image
  classes.  Image can save to a PPM or display on the screen.  It
  works on Windows, Linux, and OS X.  Images are gamma-corrected and
  exposure-adjusted both on disk and on screen.

  This implementation uses a few pieces of some freely available
  cross-platform libraries.  You need to link to the non-OpenGL part
  of G3D (for the geometry classes), OpenGL, GLUT, and GLEW.  If you
  don't like to depend on libraries with "GL" in the name, then change
  the USE_OPENGL macro definition and the preprocessor will remove
  Image::display().  If you don't like the G3D dependency either, then
  download the alternative stripped-down version of the geometry
  clases and you will have zero external dependencies.

  Consider using the G3D library's GApp framework instead of this
  minimal base.  Doing so requires learning a little more C++ and a
  new API.  In return for that investment, G3D provides cross-platform
  GUI support, model loading, in-engine debugging tools, and an
  extensive set of utility routines (some of which a professor may
  choose to outlaw in a graphics course).

  Created by Morgan McGuire in 2012
  Released into the public domain
 */
#ifndef supportclasses_h
#define supportclasses_h

#include <G3D/platform.h>
#include <G3D/Vector2.h>
#include <G3D/Vector3.h>
#include <G3D/Color3.h>
#include <G3D/Ray.h>
#include <G3D/Triangle.h>

// Make Microsoft Windows programs start from the main() entry point
G3D_START_AT_MAIN();

// If set to false, removes the Image::display() method and the GLUT,
// GLEW, and OpenGL dependencies.
#define USE_OPENGL true

using G3D::Vector2;
using G3D::Vector3;
using G3D::Color3;
using G3D::Ray;

#ifdef INFINITY
#undef INFINITY
#endif

#ifdef PI
#undef PI
#endif

#define INFINITY (std::numeric_limits<float>::infinity())
#define PI (3.1415926536f)

/** The scattering distribution function */
class BSDF {
public:
    /** This is a probability */
    Color3 lambertian;
    Color3 glossy;
    float  glossySharpness;
    
    BSDF() {}
    BSDF(const Color3& lamb, const Color3& glos = Color3::zero(), float sharp = 100.0f) : 
        lambertian(lamb),
        glossy(glos),
        glossySharpness(sharp) {}

    /** Returns L_o / L_i = f * w_i.dot(n) */
    Color3 evaluateCos(const Vector3& w_i, const Vector3& w_o, const Vector3& n) const {
        const Vector3& w_h = (w_i + w_o).direction();
        return 
            (lambertian +
             glossy * ((glossySharpness + 8.0f) * 
                       powf(std::max(0.0f, w_h.dot(n)), glossySharpness) / 
                       (8.0f * PI))) *
            std::max(0.0f, w_i.dot(n));
    }
};

class Camera {
public:
    float zNear;
    float zFar;
    float fieldOfViewX;

    Camera() : zNear(-0.1f), zFar(-100.0f), fieldOfViewX(PI / 2.0f) {}
};

class Triangle {
private:
    Vector3  m_vertex[3];
    Vector3  m_normal[3];
    BSDF     m_bsdf;

public:

    Triangle() {}

    Triangle(const Vector3& v0, const Vector3& v1, const Vector3& v2,
             const Vector3& n0, const Vector3& n1, const Vector3& n2,
             const BSDF& bsdf) : m_bsdf(bsdf) {
        m_vertex[0] = v0;  m_normal[0] = n0;
        m_vertex[1] = v1;  m_normal[1] = n1;
        m_vertex[2] = v2;  m_normal[2] = n2;
    }

    const Vector3& vertex(int i) const {
        return m_vertex[i];
    }

    const Vector3& normal(int i) const {
        return m_normal[i];
    }

    const BSDF& bsdf() const {
        return m_bsdf;
    }
};

class Image {
private:
    int                 m_width;
    int                 m_height;
    std::vector<Color3> m_data;

    /** \param displayConstant Radiance is scaled by this value, which should be chosen to
        scale the brightest values to about 1.0.*/
    int PPMGammaCorrect(float radiance, float displayConstant) const;

public:

    Image(int width, int height, const Color3& init = Color3::black()) :
        m_width(width), m_height(height), m_data(width * height, init) {}

    int width() const { return m_width; }

    int height() const { return m_height; }

    void set(int x, int y, const Color3& value) {
        m_data[x + y * m_width] = value;
    }

    const Color3& get(int x, int y) const {
        return m_data[x + y * m_width];
    }

    void save(const std::string& filename, float displayConstant = 15.0f) const;

#   if USE_OPENGL
    /** Does not return */
    void display(float displayConstant = 15.0f, float deviceGamma = 2.0f) const;
#   endif
};


class Light {
public:
    Vector3   position;

    /** Over the entire sphere. */
    Color3    power;
};

class Scene {
public:
    std::vector<Triangle> triangleArray;
    std::vector<Light>    lightArray;

    /** Load an IFS format model and add it to the scene.
        
        \param origin Object position in meters
        \param y Yaw rotation in degrees
        \param p Pitch rotation in degrees
        \param r Roll rotation in degrees
     */
    void addModel
    (const std::string& filename, 
     const BSDF& bsdf = Color3::white() * 0.9f,
     float scale = 1.0f,
     const Vector3& origin = Vector3::zero(),
     float y = 0, float p = 0, float r = 0);
};

#endif
