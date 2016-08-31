/** Minimal Oculus VR OpenGL API inclusion by Morgan McGuire at Williams College. 
    This code is in the public domain, except as copyrighted by Oculus VR from their public API. */
#ifndef williamsoculus_h
#define williamsoculus_h

#include <OVR_CAPI_GL.h>
#include <Extras/OVR_Math.h>
#include <Kernel/OVR_System.h>

#ifdef _MSC_VER
#   pragma comment(lib, "LibOVR.lib")
#   ifdef _DEBUG
#       pragma comment(lib, "LibOVRKernel_x64d.lib")
#   else
#       pragma comment(lib, "LibOVRKernel_x64.lib")
#   endif
#endif

/** Oculus SDK Sample OpenGL Depth Texture Abstraction */
struct ovrDepthBuffer {
    GLuint        texId;

    ovrDepthBuffer(ovrSizei size, int sampleCount) {
        OVR_ASSERT(sampleCount <= 1); // The code doesn't currently handle MSAA textures.

        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        GLenum internalFormat = GL_DEPTH_COMPONENT24;
        GLenum type = GL_UNSIGNED_INT;
#       ifdef GL_ARB_depth_buffer_float
        internalFormat = GL_DEPTH_COMPONENT32F;
        type = GL_FLOAT;
#       endif // GL_ARB_depth_buffer_float

        glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, size.w, size.h, 0, GL_DEPTH_COMPONENT, type, NULL);
    }
};


/** Oclus SDK Sample OpenGL Texture Abstraction. Note that The Oculus API includes a separate ovrTexture [no "Buffer"] class as well. */
struct ovrTextureBuffer {
    ovrSwapTextureSet* TextureSet;
    GLuint        texId;
    GLuint        fboId;
    ovrSizei      texSize;

    ovrTextureBuffer(ovrHmd hmd, bool rendertarget, bool displayableOnHmd, ovrSizei size, int mipLevels, unsigned char* data, int sampleCount) {
        OVR_ASSERT(sampleCount <= 1); // The code doesn't currently handle MSAA textures.

        texSize = size;

        if (displayableOnHmd) {
            // This texture isn't necessarily going to be a rendertarget, but it usually is.
            OVR_ASSERT(hmd);
            OVR_ASSERT(sampleCount == 1); // ovrHmd_CreateSwapTextureSetD3D11 doesn't support MSAA.

            ovrHmd_CreateSwapTextureSetGL(hmd, GL_RGBA, size.w, size.h, &TextureSet);
            for (int i = 0; i < TextureSet->TextureCount; ++i) {
                ovrGLTexture* tex = (ovrGLTexture*)&TextureSet->Textures[i];
                glBindTexture(GL_TEXTURE_2D, tex->OGL.TexId);

                if (rendertarget) {
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                }
                else {
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
                }
            }
        }
        else {
            glGenTextures(1, &texId);
            glBindTexture(GL_TEXTURE_2D, texId);

            if (rendertarget) {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            }
            else {
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
            }

            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSize.w, texSize.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        }

        if (mipLevels > 1) {
            glGenerateMipmap(GL_TEXTURE_2D);
        }

        glGenFramebuffers(1, &fboId);
    }

    ovrSizei GetSize() const {
        return texSize;
    }

    void SetAndClearRenderSurface(struct ovrDepthBuffer* dbuffer) {
        ovrGLTexture* tex = (ovrGLTexture*)&TextureSet->Textures[TextureSet->CurrentIndex];

        glBindFramebuffer(GL_FRAMEBUFFER, fboId);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex->OGL.TexId, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, dbuffer->texId, 0);

        glViewport(0, 0, texSize.w, texSize.h);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void UnsetRenderSurface() {
        glBindFramebuffer(GL_FRAMEBUFFER, fboId);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
    }
};


/** Data needed for any VR app */
struct ovrState {
    ovrHmd              HMD;
    ovrEyeRenderDesc    eyeRenderDesc[2];
    ovrTextureBuffer*   eyeRenderTexture[2];
    ovrDepthBuffer*     eyeDepthBuffer[2];

    /** If true, create a "mirror" FBO for showing the post-compositing data
        that is sent to the Oculus HMD on a normal monitor for debugging. */
    const bool          debugMirrorHMDToScreen;

    /** Only used if debugMirrorHMDToScreen  == true */
    GLuint              debugMirrorFBO;

    /* debugMirrorHMDToScreen  == true */
    ovrTexture*         debugMirrorTexture;

    ovrState(bool debugMirrorHMDToScreen, int logMask = OVR::LogMask_All) : 
        debugMirrorHMDToScreen(debugMirrorHMDToScreen), debugMirrorFBO(GL_NONE), debugMirrorTexture(NULL) {
        eyeRenderTexture[0] = eyeRenderTexture[1] = NULL;
        eyeDepthBuffer[0] = eyeDepthBuffer[1] = NULL;

        OVR::System::Init(OVR::Log::ConfigureDefaultLog(logMask));
    }
   

    /** Call before initializing OpenGL. Returns 0 on success, throws a string on error. */
    void init() {
        // Initialise rift
        if (ovr_Initialize(nullptr) != ovrSuccess) { throw "Unable to initialize libOVR."; }

        ovrResult result = ovrHmd_Create(0, &HMD);
        if (result != ovrSuccess) { result = ovrHmd_CreateDebug(ovrHmd_DK2, &HMD); }
        if (result != ovrSuccess) { ovr_Shutdown(); throw "Oculus Rift not detected."; }
        if (HMD->ProductName[0] == '\0') { throw "Rift detected, display not enabled."; }

        eyeRenderDesc[0] = ovrHmd_GetRenderDesc(HMD, ovrEye_Left, HMD->DefaultEyeFov[0]);
        eyeRenderDesc[1] = ovrHmd_GetRenderDesc(HMD, ovrEye_Right, HMD->DefaultEyeFov[1]);

        ovrHmd_SetEnabledCaps(HMD, ovrHmdCap_LowPersistence | ovrHmdCap_DynamicPrediction);

        // Start the sensor
        ovrHmd_ConfigureTracking(HMD, ovrTrackingCap_Orientation | ovrTrackingCap_MagYawCorrection | ovrTrackingCap_Position, 0);
    }

    /** Call after OpenGL is initialized. windowWidth and windowHeight are the size of the mirror screen display,
    and are independent of the HMD resolution.  These are only needed if debugMirrorHMDToScreen == true */
    void initRenderBuffers(int windowWidth, int windowHeight) {
        // Make eye render buffers
        for (int i = 0; i < 2; ++i) {
            ovrSizei idealTextureSize = ovrHmd_GetFovTextureSize(HMD, (ovrEyeType)i, HMD->DefaultEyeFov[i], 1);
            eyeRenderTexture[i] = new ovrTextureBuffer(HMD, true, true, idealTextureSize, 1, NULL, 1);
            eyeDepthBuffer[i] = new ovrDepthBuffer(eyeRenderTexture[i]->GetSize(), 0);
        }

        if (debugMirrorHMDToScreen) {
            // Create mirror texture and an FBO used to copy mirror texture to back buffer
            ovrHmd_CreateMirrorTextureGL(HMD, GL_RGBA, windowWidth, windowHeight, &debugMirrorTexture);

            // Configure the mirror read buffer. This is only for debugging and can be application-specific
            glGenFramebuffers(1, &debugMirrorFBO);
            glBindFramebuffer(GL_READ_FRAMEBUFFER, debugMirrorFBO);
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, reinterpret_cast<ovrGLTexture*>(debugMirrorTexture)->OGL.TexId, 0);
            glFramebufferRenderbuffer(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
            glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
        }
    }

    /** Call at application end, before OpenGL is shut down */
    void cleanup() {
        // Cleanup
        if (debugMirrorHMDToScreen) {
            glDeleteFramebuffers(1, &debugMirrorFBO);
            debugMirrorFBO = GL_NONE;
            ovrHmd_DestroyMirrorTexture(HMD, debugMirrorTexture);
            debugMirrorTexture = NULL;
        }

        ovrHmd_DestroySwapTextureSet(HMD, eyeRenderTexture[0]->TextureSet);
        ovrHmd_DestroySwapTextureSet(HMD, eyeRenderTexture[1]->TextureSet);
    }


    /** Call after OpenGL is shut down */
    ~ovrState() {
        ovrHmd_Destroy(HMD);
        ovr_Shutdown();
        OVR::System::Destroy();
    }


    static void quaternionToMatrix(const float* quat, float* mat) {
        mat[0] = 1.0f - 2.0f * quat[1] * quat[1] - 2.0f * quat[2] * quat[2];
        mat[4] = 2.0f * quat[0] * quat[1] + 2.0f * quat[3] * quat[2];
        mat[8] = 2.0f * quat[2] * quat[0] - 2.0f * quat[3] * quat[1];
        mat[12] = 0.0f;

        mat[1] = 2.0f * quat[0] * quat[1] - 2.0f * quat[3] * quat[2];
        mat[5] = 1.0f - 2.0f * quat[0] * quat[0] - 2.0f * quat[2] * quat[2];
        mat[9] = 2.0f * quat[1] * quat[2] + 2.0f * quat[3] * quat[0];
        mat[13] = 0.0f;

        mat[2] = 2.0f * quat[2] * quat[0] + 2.0f * quat[3] * quat[1];
        mat[6] = 2.0f * quat[1] * quat[2] - 2.0f * quat[3] * quat[0];
        mat[10] = 1.0f - 2.0f * quat[0] * quat[0] - 2.0f * quat[1] * quat[1];
        mat[14] = 0.0f;

        mat[3] = mat[7] = mat[11] = 0.0f;
        mat[15] = 1.0f;
    }

    /** Returns the OpenGL GL_MODELVIEW matrix for the specified eye and head, relative to the calibration-center head position. 
        
        Use ovrHmd_GetFloat(oculusHMD.HMD, OVR_KEY_EYE_HEIGHT, OVR_DEFAULT_EYE_HEIGHT), 0.0f) to get the vertical (y-axis) default
        eye height.

        Use ovrMatrix4f_Projection to get the projection matrix.
        */
    void getEyeMatrix(const ovrPosef& eyeRenderPose, int eye, float* matrix) const {
        quaternionToMatrix(&eyeRenderPose.Orientation.x, matrix);

        // Directly apply the HmdToEyeViewOffset
        const float* eyeOffsetVector = &eyeRenderDesc[eye].HmdToEyeViewOffset.x;
        for (int r = 0; r < 3; ++r) {
            matrix[4 * 3 + r] = eyeOffsetVector[r];
        }

        // Multiply the rotation matrix by the head translation matrix
        const float* headOffsetVector = &eyeRenderPose.Position.x;
        for (int r = 0; r < 3; ++r) {
            // Matrix-vector product. We only need the upper 3x3 rotation times the vector.
            // Since we're computing the INVERSE of the camera matrix, we use the negative
            // vector.
            for (int c = 0; c < 3; ++c) {
                matrix[4 * 3 + r] += matrix[4 * c + r] * -headOffsetVector[c];
            }
        }

    }
};

#endif
