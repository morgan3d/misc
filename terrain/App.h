/**
  @file App.h

  The G3D 9.0 default starter app is configured for OpenGL 3.0 and relatively recent
  GPUs.  To support older GPUs you may want to disable the framebuffer and film
  classes and use G3D::Sky to handle the skybox.
 */
#ifndef App_h
#define App_h

#include <G3D/G3DAll.h>
#include "Terrain.h"


class App : public GApp {
public:
    
    Terrain::Visualization  m_visualization;
    shared_ptr<Terrain>     m_terrain;

    LightingEnvironment     m_lightingEnvironment;
    bool                    m_wireframe;
    bool                    m_deferred;

    App(const GApp::Settings& settings = GApp::Settings());

    virtual void onInit();
    virtual void onGraphics3D(RenderDevice* rd, Array< shared_ptr<Surface> >& surface);
    virtual void onGraphics2D(RenderDevice* rd, Array< shared_ptr<Surface2D> >& surface2D);

    virtual bool onEvent(const GEvent& e);
};

#endif
