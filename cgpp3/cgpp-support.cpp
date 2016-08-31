/**
   Created by Morgan McGuire in 2012
   Released into the public domain
 */
#include <GLG3D/GLG3D.h>
#include <GL/glut.h>
#include "supportclasses.h"

int Image::PPMGammaCorrect(float radiance, float e) const {
    // Note that the PPM gamma is fixed at 2.2
    return int(pow(std::min(1.0f, std::max(0.0f, radiance * e)), 1.0f / 2.2f) * 255.0f);
}


void Image::save(const std::string& filename, float e) const {
    FILE* file = fopen(filename.c_str(), "wt");
    fprintf(file, "P3 %d %d 255\n", m_width, m_height);                                                    
    for (int y = 0; y < m_height; ++y) {
        fprintf(file, "\n# y = %d\n", y);                                                                  
        for (int x = 0; x < m_width; ++x) {
            const Color3& c(get(x, y));
            fprintf(file, "%d %d %d\n", 
                    PPMGammaCorrect(c.r, e), 
                    PPMGammaCorrect(c.g, e),
                    PPMGammaCorrect(c.b, e));
        }
    }
    fclose(file);
}


#if USE_OPENGL

static void quitOnEscape(unsigned char key, int x, int y) {
    if (key == 27) { ::exit(0); }
}


static void render() {
    glClear(GL_COLOR_BUFFER_BIT);
    // Draw a full-screen quad of the image
    glDrawArrays(GL_QUADS, 0, 4);
    glutSwapBuffers();
}


void Image::display(float exposureConstant, float deviceGamma) const {
    int argc = 0;
    
    // Initialize OpenGL
    glutInit(&argc, NULL);
    glutInitWindowSize(m_width, m_height);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutCreateWindow("Rendered result");
    glutKeyboardFunc(&quitOnEscape);
    glutDisplayFunc(&render);

    // Initialize OpenGL extensions
    glewInit();

    // Set the color scale applied as textures are uploaded to be the exposure constant
    glMatrixMode(GL_COLOR);
    glLoadIdentity();
    glScalef(exposureConstant, exposureConstant, exposureConstant);

    // Create a gamma correction color table for texture load
    std::vector<Color3> gammaTable(256);
    for (unsigned int i = 0; i < gammaTable.size(); ++i) {
        gammaTable[i] = (Color3::white() * i / (gammaTable.size() - 1.0f)).pow(1.0f / deviceGamma);
    }
    glColorTable(GL_POST_COLOR_MATRIX_COLOR_TABLE, GL_RGB, gammaTable.size(), GL_RGB, GL_FLOAT, &gammaTable[0]);
    glEnable(GL_POST_COLOR_MATRIX_COLOR_TABLE);
    
    // Create a texture, upload our image, and bind it (assume a
    // version of GL that supports NPOT textures)
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_width, m_height, 0, GL_RGB, GL_FLOAT, &m_data[0]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
    glEnable(GL_TEXTURE_2D);

    // The vertices of a 2D quad mesh containing a single CCW square
    static const Vector2 corner[] = {Vector2(0,0), Vector2(0,1), Vector2(1,1), Vector2(1,0)};

    // Bind the quad mesh as the active geometry
    glVertexPointer(2, GL_FLOAT, 0, corner);
    glTexCoordPointer(2, GL_FLOAT, 0, corner);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // Set orthographic projection that stretches the unit square to the
    // dimensions of the image
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, 1, 1, 0, 0, 2);
    glutMainLoop();
}

#endif

///////////////////////////////////////////////////////////////////////////////////

void Scene::addModel
(const std::string& filename, 
 const BSDF& bsdf,
 const float scale,
 const Vector3& origin,
 float y, float p, float r) {

    const G3D::CFrame& frame = G3D::CFrame::fromXYZYPRDegrees(origin.x, origin.y, origin.z, y, p, r);

    // (It is much easier to use G3D::ArticulatedModel to load a
    // model, however, that requires that OpenGL already be
    // initialized.  The following code works even without an OpenGL
    // context and spells out some of the details of the model loading
    // process.)
    G3D::Array<int>     index;
    G3D::Array<Vector3> vertex, wvertex;
    G3D::Array<Vector3> normal, wnormal;
    G3D::Array<Vector2> texCoord;
    std::string ignore;

    G3D::IFSModel::load(filename, ignore, index, vertex, texCoord);
    G3D::Welder::weld(vertex, texCoord, normal, index, G3D::Welder::Settings());

    // Transform to a new position
    for (int i = 0; i < vertex.size(); ++i) {
        vertex[i] *= scale;
    }
    frame.pointToWorldSpace(vertex, wvertex);
    frame.normalToWorldSpace(normal, wnormal);

    //index.resize(12);
    for (int i = 0; i < index.size(); i += 3) {
        int i0 = index[i + 0];
        int i1 = index[i + 1];
        int i2 = index[i + 2];
        triangleArray.push_back(Triangle(wvertex[i0], wvertex[i1], wvertex[i2],
                                         wnormal[i0], wnormal[i1], wnormal[i2],
                                         bsdf));
        /*
        G3D::debugPrintf("%s ", wvertex[i0].toString().c_str());
        G3D::debugPrintf("%s ", wvertex[i1].toString().c_str());
        G3D::debugPrintf("%s\n", wvertex[i2].toString().c_str());*/
    }
}
