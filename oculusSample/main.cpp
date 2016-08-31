/* Very simple OculusSDK OpenGL usage example updated to the Oculus SDK 0.6.0 and OpenGL 4.
*
* This program assumes that you have GLEW and GLFW's include and lib directories in your respective
* include and library paths (set this from the Property Manager in Visual Studio). 
*
* The sample assumes that you have an environment variable OVRSDKROOT that is the root of the SDK.
*
* Running this program should initialize a DK2 in direct-to-rift mode, display the Oculus
* health and safety warning, and show a simple 3D scene with full head tracking and per-user
* accomodation parameters.
*
* Uses GLFW (http://www.glfw.org/) and GLEW (http://glew.sourceforge.net/) for
* OpenGL intialization and window management. Camera movement is sketched out but not
* implemented.
*
* By Morgan McGuire and Sam Donow <sad3@williams.edu> at 
* Williams College, http://graphics.cs.williams.edu
* This code is released into the public domain. No support or warranty is provided.
*
* Based on public domain code by John Tsiombikas <nuclear@member.fsf.org>
* http://nuclear.mutantstargoat.com/hg/oculus2/file/64089dd45d50
* https://codelab.wordpress.com/2014/09/07/oculusvr-sdk-and-simple-oculus-rift-dk2-opengl-test-program/
*
* Updated  2015-06-04 with reduced dependencies
* Updated  2015-06-02 with cleaner abstractions and debug binaries by Morgan McGuire
* Updated  2015-05-28 for SDK 0.6 by Morgan McGuire
* Updated  2015-05-01 for SDK 0.5 by Sam Donow
* Released 2015-01-26 for SDK 0.4 by Morgan McGuire
*/

// Standard OpenGL headers via GLFW and GLEW
#include <GL/glew.h>
#ifdef _MSC_VER
#   include "GL/wglew.h"
#   pragma comment(lib, "opengl32")
#   pragma comment(lib, "glew_x64")
#   pragma comment(lib, "glfw_x64")
#endif
#include <GLFW/glfw3.h>

// Minimal inclusion of Oculus SDK
#include "williamsoculus.h"

ovrState* oculusHMD = NULL;
GLFWwindow* window;

void display();
void draw_scene();


int main() {

    // Must call before initializating OpenGL
    oculusHMD = new ovrState(true);

    try {
        oculusHMD->init();
    } catch (const char* error) {
        MessageBoxA(NULL, error, "", MB_OK); 
        exit(1);
    }

    // Setup Window and Graphics
    // Note: the mirror window can be any size, for this sample we use 1/2 the HMD resolution
    const int windowWidth = oculusHMD->HMD->Resolution.w / 2;
    const int windowHeight = oculusHMD->HMD->Resolution.h / 2;

    glfwInit();
    window = glfwCreateWindow(windowWidth, windowHeight, "Williams Oculus Sample", NULL, NULL);
    glfwMakeContextCurrent(window);
    glewInit();

    // Must call after initializing OpenGL
    oculusHMD->initRenderBuffers(windowWidth, windowHeight);

    // Turn off vsync (since the Rift has its own synchronization)
    wglSwapIntervalEXT(0);

    // Main loop
    while (! glfwWindowShouldClose(window)) {
        display();
        glfwPollEvents();
    }

    oculusHMD->cleanup();

    // Shut down OpenGL
    glfwTerminate();

    delete oculusHMD;
    oculusHMD = NULL;

    return 0;
}


void display() {    
    // Get eye poses, feeding in correct IPD offset
    ovrVector3f      ViewOffset[2] = { oculusHMD->eyeRenderDesc[0].HmdToEyeViewOffset, oculusHMD->eyeRenderDesc[1].HmdToEyeViewOffset };
    ovrPosef         EyeRenderPose[2];

    ovrFrameTiming   ftiming = ovrHmd_GetFrameTiming(oculusHMD->HMD, 0);
    ovrTrackingState hmdState = ovrHmd_GetTrackingState(oculusHMD->HMD, ftiming.DisplayMidpointSeconds);

    ovr_CalcEyePoses(hmdState.HeadPose.ThePose, ViewOffset, EyeRenderPose);

    for (int eye = 0; eye < 2; ++eye) {
        // Increment to use next texture, just before writing
        oculusHMD->eyeRenderTexture[eye]->TextureSet->CurrentIndex = (oculusHMD->eyeRenderTexture[eye]->TextureSet->CurrentIndex + 1) % oculusHMD->eyeRenderTexture[eye]->TextureSet->TextureCount;

        // Switch to eye render target
        oculusHMD->eyeRenderTexture[eye]->SetAndClearRenderSurface(oculusHMD->eyeDepthBuffer[eye]);

        // Configure full-eye screen rendering
        const ovrSizei size = oculusHMD->eyeRenderTexture[eye]->GetSize();
        glViewport(0, 0, size.w, size.h);

        // Load the Oculus-computed projection matrix for the eye
        const float zNear = 0.5f;
        const float zFar = 500.0f;
        const ovrMatrix4f proj = ovrMatrix4f_Projection(oculusHMD->HMD->DefaultEyeFov[eye], zNear, zFar, ovrProjection_RightHanded);
        glMatrixMode(GL_PROJECTION);
        glLoadTransposeMatrixf(proj.M[0]);

        glMatrixMode(GL_MODELVIEW);
       
        float matrix[16];
        oculusHMD->getEyeMatrix(EyeRenderPose[eye], eye, matrix);
        glLoadMatrixf(matrix);

        // Move the camera to the eye level of the user (assuming a standing player)
        glTranslatef(0.0f, -ovrHmd_GetFloat(oculusHMD->HMD, OVR_KEY_EYE_HEIGHT, OVR_DEFAULT_EYE_HEIGHT), 0.0f);

        // Draw the scene for this eye
        draw_scene();

        oculusHMD->eyeRenderTexture[eye]->UnsetRenderSurface();
    }

    glBindFramebuffer(GL_FRAMEBUFFER, GL_NONE);

    // Do distortion rendering, Present and flush/sync

    // Set up positional data.
    ovrViewScaleDesc viewScaleDesc;
    viewScaleDesc.HmdSpaceToWorldScaleInMeters = 1.0f;
    viewScaleDesc.HmdToEyeViewOffset[0] = ViewOffset[0];
    viewScaleDesc.HmdToEyeViewOffset[1] = ViewOffset[1];

    ovrLayerEyeFov eyeLayer;
    eyeLayer.Header.Type = ovrLayerType_EyeFov;
    // OpenGL convention
    eyeLayer.Header.Flags = ovrLayerFlag_TextureOriginAtBottomLeft;

    for (int eye = 0; eye < 2; ++eye) {
        eyeLayer.ColorTexture[eye] = oculusHMD->eyeRenderTexture[eye]->TextureSet;
        eyeLayer.Viewport[eye]     = OVR::Recti(oculusHMD->eyeRenderTexture[eye]->GetSize());
        eyeLayer.Fov[eye]          = oculusHMD->HMD->DefaultEyeFov[eye];
        eyeLayer.RenderPose[eye]   = EyeRenderPose[eye];
    }

    ovrLayerHeader*  layerPtrList = &eyeLayer.Header;
    static const int layerCount = 1;
    ovrResult        result = ovrHmd_SubmitFrame(oculusHMD->HMD, 0, &viewScaleDesc, &layerPtrList, layerCount);

    if (oculusHMD->debugMirrorHMDToScreen) {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Blit mirror texture to back buffer
        glBindFramebuffer(GL_READ_FRAMEBUFFER, oculusHMD->debugMirrorFBO);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, GL_NONE);
        const GLint w = reinterpret_cast<ovrGLTexture*>(oculusHMD->debugMirrorTexture)->OGL.Header.TextureSize.w;
        const GLint h = reinterpret_cast<ovrGLTexture*>(oculusHMD->debugMirrorTexture)->OGL.Header.TextureSize.h;
        glBlitFramebuffer(0, h, w, 0, 0, 0, w, h, GL_COLOR_BUFFER_BIT, GL_NEAREST);
        glBindFramebuffer(GL_READ_FRAMEBUFFER, GL_NONE);

        // Swapping buffers is only needed for the on-screen debugging display.
        // The Rift renders directly from the textures above
        glfwSwapBuffers(window);
    }
    
    assert(glGetError() == GL_NO_ERROR);
}


//////////////////////////////////////////////////////////

// Application-specific

unsigned int next_pow2(unsigned int x) {
    x -= 1;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1;
}


void draw_box(float xsz, float ysz, float zsz, float norm_sign) {
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glScalef(xsz * 0.5f, ysz * 0.5f, zsz * 0.5f);

    if (norm_sign < 0.0f) {
        glFrontFace(GL_CW);
    }

    glBegin(GL_QUADS);
    glNormal3f(0, 0, 1 * norm_sign);
    glTexCoord2f(0, 0); glVertex3f(-1, -1, 1);
    glTexCoord2f(1, 0); glVertex3f(1, -1, 1);
    glTexCoord2f(1, 1); glVertex3f(1, 1, 1);
    glTexCoord2f(0, 1); glVertex3f(-1, 1, 1);
    glNormal3f(1 * norm_sign, 0, 0);
    glTexCoord2f(0, 0); glVertex3f(1, -1, 1);
    glTexCoord2f(1, 0); glVertex3f(1, -1, -1);
    glTexCoord2f(1, 1); glVertex3f(1, 1, -1);
    glTexCoord2f(0, 1); glVertex3f(1, 1, 1);
    glNormal3f(0, 0, -1 * norm_sign);
    glTexCoord2f(0, 0); glVertex3f(1, -1, -1);
    glTexCoord2f(1, 0); glVertex3f(-1, -1, -1);
    glTexCoord2f(1, 1); glVertex3f(-1, 1, -1);
    glTexCoord2f(0, 1); glVertex3f(1, 1, -1);
    glNormal3f(-1 * norm_sign, 0, 0);
    glTexCoord2f(0, 0); glVertex3f(-1, -1, -1);
    glTexCoord2f(1, 0); glVertex3f(-1, -1, 1);
    glTexCoord2f(1, 1); glVertex3f(-1, 1, 1);
    glTexCoord2f(0, 1); glVertex3f(-1, 1, -1);
    glEnd();
    glBegin(GL_TRIANGLE_FAN);
    glNormal3f(0, 1 * norm_sign, 0);
    glTexCoord2f(0.5, 0.5); glVertex3f(0, 1, 0);
    glTexCoord2f(0, 0); glVertex3f(-1, 1, 1);
    glTexCoord2f(1, 0); glVertex3f(1, 1, 1);
    glTexCoord2f(1, 1); glVertex3f(1, 1, -1);
    glTexCoord2f(0, 1); glVertex3f(-1, 1, -1);
    glTexCoord2f(0, 0); glVertex3f(-1, 1, 1);
    glEnd();
    glBegin(GL_TRIANGLE_FAN);
    glNormal3f(0, -1 * norm_sign, 0);
    glTexCoord2f(0.5, 0.5); glVertex3f(0, -1, 0);
    glTexCoord2f(0, 0); glVertex3f(-1, -1, -1);
    glTexCoord2f(1, 0); glVertex3f(1, -1, -1);
    glTexCoord2f(1, 1); glVertex3f(1, -1, 1);
    glTexCoord2f(0, 1); glVertex3f(-1, -1, 1);
    glTexCoord2f(0, 0); glVertex3f(-1, -1, -1);
    glEnd();

    glFrontFace(GL_CCW);
    glPopMatrix();
}


/* generate a chessboard texture with tiles colored (r0, g0, b0) and (r1, g1, b1) */
unsigned int gen_chess_tex(float r0, float g0, float b0, float r1, float g1, float b1) {
    int i, j;
    unsigned int tex;
    unsigned char img[8 * 8 * 3];
    unsigned char *pix = img;

    for (i = 0; i<8; i++) {
        for (j = 0; j<8; j++) {
            int black = (i & 1) == (j & 1);
            pix[0] = char((black ? r0 : r1) * 255);
            pix[1] = char((black ? g0 : g1) * 255);
            pix[2] = char((black ? b0 : b1) * 255);
            pix += 3;
        }
    }

    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 8, 8, 0, GL_RGB, GL_UNSIGNED_BYTE, img);

    return tex;
}


void draw_scene() {
    static unsigned int chess_tex = GL_NONE;
    if (chess_tex == GL_NONE) {
        chess_tex = gen_chess_tex(1.0f, 0.7f, 0.4f, 0.4f, 0.7f, 1.0f);
    }

    // Application-specific setup
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_LIGHT1);
    glEnable(GL_NORMALIZE);
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);


    int i;
    float grey[] = { 0.8f, 0.8f, 0.8f, 1 };
    float col[] = { 0, 0, 0, 1 };
    float lpos[][4] = {
        { -8, 2, 10, 1 },
        { 0, 15, 0, 1 }
    };

    float lcol[][4] = {
        { 0.8f, 0.8f, 0.8f, 1.0f },
        { 0.4f, 0.3f, 0.3f, 1.0f }
    };

    for (i = 0; i < 2; ++i) {
        glLightfv(GL_LIGHT0 + i, GL_POSITION, lpos[i]);
        glLightfv(GL_LIGHT0 + i, GL_DIFFUSE,  lcol[i]);
    }

    glMatrixMode(GL_MODELVIEW);

    glPushMatrix();
    glTranslatef(0, 10, 0);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, grey);
    glBindTexture(GL_TEXTURE_2D, chess_tex);
    glEnable(GL_TEXTURE_2D);
    draw_box(30, 20, 30, -1.0);
    glDisable(GL_TEXTURE_2D);
    glPopMatrix();

    for (i = 0; i < 4; ++i) {
        glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, grey);
        glPushMatrix();
        glTranslatef((i & 1) ? 5.0f : -5.0f, 1.0f, (i & 2) ? -5.0f : 5.0f);
        draw_box(0.5, 2, 0.5, 1.0);
        glPopMatrix();

        col[0] = (i & 1)  ? 1.0f : 0.3f;
        col[1] = (i == 0) ? 1.0f : 0.3f;
        col[2] = (i & 2)  ? 1.0f : 0.3f;
        glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, col);

        glPushMatrix();
        if (i & 1) {
            glTranslatef(0.0f, 0.25f, (i & 2) ? 2.0f : -2.0f);
        }
        else {
            glTranslatef((i & 2) ? 2.0f : -2.0f, 0.25f, 0.0f);
        }
        draw_box(0.5f, 0.5f, 0.5f, 1.0f);
        glPopMatrix();
    }

    col[0] = 1.0f;
    col[1] = 1.0f;
    col[2] = 0.4f;
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, col);
    draw_box(0.05f, 1.2f, 6.0f, 1.0f);
    draw_box(6.0f, 1.2f, 0.05f, 1.0f);
}

