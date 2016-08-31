/** \file App.cpp */
#include "App.h"
#include "Terrain.h"

// Tells C++ to invoke command-line main() function even on OS X and Win32.
G3D_START_AT_MAIN();

int main(int argc, const char* argv[]) {
    (void)argc; (void)argv;
    GApp::Settings settings(argc, argv);
    
    settings.window.defaultIconFilename = "icon.png";
    settings.window.caption     = "Terrain";
//    settings.window.width       = 1280;     settings.window.height      = 720;
    settings.window.width       = 1600;     settings.window.height      = 1000;
    settings.screenshotDirectory = "journal";
    settings.colorGuardBandThickness = Vector2int16(0,0);
    settings.depthGuardBandThickness = Vector2int16(0,0);

    return App(settings).run();
}


App::App(const GApp::Settings& settings) : 
    GApp(settings),
    m_visualization(Terrain::NONE), 
    m_wireframe(false),
    m_deferred(false) {

    renderDevice->setColorClearValue(Color3::white());
}


void App::onInit() {
    GApp::onInit();

    m_gbufferSpecification.encoding[GBuffer::Field::CS_FACE_NORMAL].format = NULL;
    m_gbufferSpecification.encoding[GBuffer::Field::CS_NORMAL] = Texture::Encoding(ImageFormat::RGB10A2(), FrameName::CAMERA, 2.0f, -1.0f);

    m_gbufferSpecification.encoding[GBuffer::Field::SS_EXPRESSIVE_MOTION]    = 
        Texture::Encoding(GLCaps::supportsTexture(ImageFormat::RG8()) ? ImageFormat::RG8() : ImageFormat::RGBA8(),
        FrameName::SCREEN, 128.0f, -64.0f);

    m_gbufferSpecification.encoding[GBuffer::Field::EMISSIVE]           = Texture::Encoding(ImageFormat::R11G11B10F()); 

    m_gbufferSpecification.encoding[GBuffer::Field::LAMBERTIAN]         = ImageFormat::RGB8();
    m_gbufferSpecification.encoding[GBuffer::Field::GLOSSY]             = ImageFormat::RGBA8();
    m_gbufferSpecification.encoding[GBuffer::Field::DEPTH_AND_STENCIL]  = ImageFormat::DEPTH32F();
    m_gbufferSpecification.depthEncoding = DepthEncoding::HYPERBOLIC;

    // Update the actual m_gbuffer before makeGUI creates the buffer visualizer
    m_gbuffer->setSpecification(m_gbufferSpecification);
    m_gbuffer->resize(renderDevice->width() + m_settings.depthGuardBandThickness.x * 2, renderDevice->height() + m_settings.depthGuardBandThickness.y * 2);

    m_lightingEnvironment.lightArray.append(Light::point("Sun", Point3(15000, 6000, 15000), Power3(1e6)));
    m_lightingEnvironment.environmentMapArray.append(Texture::fromFile(System::findDataFile("cubemap/desert/desert_*.jpg")));
    m_lightingEnvironment.environmentMapWeightArray.append(1.0f);

    {
        Terrain::Specification spec(Any::fromFile(
            "default.Terrain.Any"
            //"tiny.Terrain.Any"
            ));
        m_terrain = Terrain::create(spec, m_lightingEnvironment);
    }

    debugPane->addCheckBox("Show wireframe", &m_wireframe);
    debugPane->addCheckBox("Deferred shading", &m_deferred);
    debugPane->addRadioButton("NONE", Terrain::NONE, &m_visualization);
    debugPane->addRadioButton("TESSELLATION", Terrain::TESSELLATION, &m_visualization);
    debugPane->addRadioButton("TEXTURE_PARAMETERIZATION", Terrain::TEXTURE_PARAMETERIZATION, &m_visualization);

    // Turn on the developer HUD
    createDeveloperHUD();
    debugWindow->setVisible(false);
    developerWindow->setVisible(true);
    developerWindow->cameraControlWindow->setVisible(false);
    developerWindow->sceneEditorWindow->setVisible(false);
    showRenderingStats = false;
    activeCamera()->setFrame(CFrame::fromXYZYPRDegrees( 1845.9f,  335.8f,  1705.6f, -116.2f, -18.2f,   0.0f));
    activeCamera()->setFarPlaneZ(-finf());
    activeCamera()->filmSettings().setAntialiasingEnabled(false);
}


bool App::onEvent(const GEvent& e) {
    if (GApp::onEvent(e)) {
        return true;
    }
    //
    // For example,
    // if ((e.type == GEventType::GUI_ACTION) && (e.gui.control == m_button)) { ... return true;}
    if ((e.type == GEventType::KEY_DOWN) && (e.key.keysym.sym == 'r')) { 
        m_terrain->reloadMaterials();
        return true; 
    }

    return false;
}


void App::onGraphics3D(RenderDevice* rd, Array<shared_ptr<Surface> >& surface3D) {
    rd->pushState(m_framebuffer); {
        rd->setProjectionAndCameraMatrix(activeCamera()->projection(), activeCamera()->frame());
        rd->setColorClearValue(Color3::black());
        rd->clear();
    
        if (m_deferred) {
            m_gbuffer->prepare(rd, activeCamera(), 0, -(float)previousSimTimeStep(), m_settings.depthGuardBandThickness, m_settings.colorGuardBandThickness);
            m_terrain->renderIntoGBuffer(rd, m_lightingEnvironment, m_gbuffer);
        } else {
            m_terrain->render(rd, m_lightingEnvironment, activeCamera(), m_visualization);

            if (m_visualization == Terrain::NONE) {
                Draw::skyBox(rd, m_lightingEnvironment.environmentMapArray[0]);
            }
        }

        if (m_wireframe && (m_visualization != Terrain::TESSELLATION)) {
            m_terrain->renderWireframe(rd, m_lightingEnvironment, activeCamera());
        }
    
        // Call to make the GApp show the output of debugDraw
        drawDebugShapes();
    } rd->popState();

    swapBuffers();
    rd->clear();
    m_film->exposeAndRender(rd, m_debugCamera->filmSettings(), m_framebuffer->texture(0), 1);
}


void App::onGraphics2D(RenderDevice* rd, Array<Surface2D::Ref>& posed2D) {
    // Render 2D objects like Widgets.  These do not receive tone mapping or gamma correction
    Surface2D::sortAndRender(rd, posed2D);
}
