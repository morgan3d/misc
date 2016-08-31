/**
  \file Terrain.h
  \author Morgan McGuire, http://cs.williams.edu/~morgan
*/
#include "Terrain.h"

shared_ptr<Terrain> Terrain::create(const Specification& specification, const LightingEnvironment& lighting) {
    return shared_ptr<Terrain>(new Terrain(specification, lighting)); 
}


Terrain::Terrain(const Specification& specification, const LightingEnvironment& lighting) :
    m_specification(specification) {

    m_specification.elevationZone[0].startElevation = -1e9;

    initElevation(specification.heightfieldFilename);
    initMesh();
    initPrecomputedLighting(lighting);
    reloadMaterials();
}


Terrain::~Terrain() {}


void Terrain::initElevation(const String& filename) {
    shared_ptr<Framebuffer> framebuffer = Framebuffer::create("MIP");
    RenderDevice* rd = RenderDevice::current;

    // Load the texture
    Texture::Specification s;
    s.filename = filename;
    s.assumeSRGBSpaceForAuto = false;
    shared_ptr<Texture> raw = Texture::create(s);

    Texture::Encoding encoding(ImageFormat::RGBA8(), FrameName::NONE, 
        Color4(Color3(2.0f), m_specification.maxElevation - m_specification.minElevation), 
        Color4(Color3(-1.0f), m_specification.minElevation));

    m_heightfield = Texture::createEmpty("Terrain::m_heightfield", raw->width(), raw->height(), encoding, Texture::DIM_2D, true);

    // Create MIP 0
    framebuffer->set(Framebuffer::COLOR0, m_heightfield, CubeFace::POS_X, 0);
    rd->push2D(framebuffer); {
        rd->setAlphaWrite(true);
        rd->setAlphaTest(RenderDevice::ALPHA_ALWAYS_PASS, 0.0f);
        Args args;
        args.setUniform("sourceMultiplyFirst", m_specification.maxElevation - m_specification.minElevation);
        args.setUniform("sourceAddSecond",     m_specification.minElevation);
        args.setUniform("metersPerHeightfieldTexel", m_specification.metersPerHeightfieldTexel);
        args.setUniform("source", raw, Sampler::buffer());
        args.setUniform("writeMultiplyFirst", m_heightfield->encoding().writeMultiplyFirst());
        args.setUniform("writeAddSecond", m_heightfield->encoding().writeAddSecond());
        args.setRect(framebuffer->rect2DBounds());

        LAUNCH_SHADER("Terrain_generateHeightfield.*", args);
    } rd->pop2D();

    // Discard the originally loaded buffer
    raw.reset();

    // Generate the other MIP levels
    for (int L = 1; L < log2(min(m_heightfield->width(), m_heightfield->height())); ++L) {
        framebuffer->set(Framebuffer::COLOR0, m_heightfield, CubeFace::POS_X, L);
        rd->push2D(framebuffer); {
            rd->setAlphaWrite(true);
            rd->setAlphaTest(RenderDevice::ALPHA_ALWAYS_PASS, 0.0f);
            Args args;
            args.setUniform("source", m_heightfield, Sampler::buffer());
            args.setUniform("sourceLevel", L - 1);
            args.setRect(framebuffer->rect2DBounds());

            LAUNCH_SHADER("Terrain_generateMIP.*", args);
        } rd->pop2D();
    }
}


static shared_ptr<Light> findSun(const Array<shared_ptr<Light>>& lightArray) {
    float brightest = 0;
    shared_ptr<Light> sun;
    for (int i = 0; i < lightArray.size(); ++i) {
        if (lightArray[i]->bulbPower().sum() > brightest) {
            sun = lightArray[i];
        }
    }
    return sun;
}


void Terrain::initPrecomputedLighting(const LightingEnvironment& lightingEnvironment) {
    const int BLUR_ITERATIONS = 3;

    // Reducing precision or compressing here has no impact on performance
    m_precomputedLighting = Texture::createEmpty("Terrain::m_precomputedLighting", m_heightfield->width(), m_heightfield->height(), ImageFormat::RGBA8(), Texture::DIM_2D, false);
    shared_ptr<Texture> temp = Texture::createEmpty("Terrain::m_precomputedLighting", m_heightfield->width(), m_heightfield->height(), m_precomputedLighting->encoding(), Texture::DIM_2D, false);
    shared_ptr<Framebuffer> framebuffer = Framebuffer::create(m_precomputedLighting);
    RenderDevice* rd = RenderDevice::current;

    rd->push2D(framebuffer); {
        rd->setAlphaWrite(true);
        rd->clear();
        Args args;

        m_heightfield->setShaderArgs(args, "heightfield_", Sampler::buffer());
        lightingEnvironment.setShaderArgs(args);
        args.setUniform("metersPerHeightfieldTexel", m_specification.metersPerHeightfieldTexel);
        args.setUniform("heightfieldTexelsPerMeter", 1.0f / m_specification.metersPerHeightfieldTexel);

        // Find the sun (the brightest light)
        
        shared_ptr<Light> sun = findSun(lightingEnvironment.lightArray);
        alwaysAssertM(notNull(sun), "Could not find the sun");
        args.setUniform("directionToSun", sun->frame().translation.direction());

        args.setRect(rd->viewport());

        LAUNCH_SHADER("Terrain_precomputeLighting.pix", args);
    } rd->pop2D();

    // Blur
    for (int i = 0; i < BLUR_ITERATIONS; ++i) {
        framebuffer->set(Framebuffer::COLOR0, temp);
        rd->push2D(framebuffer); {
            rd->setAlphaWrite(true);
            rd->clear();
            Args args;
            args.setUniform("source", m_precomputedLighting, Sampler::video());
            args.setRect(rd->viewport());
            LAUNCH_SHADER("Terrain_blurLighting.pix", args);
        } rd->pop2D();
        std::swap(temp, m_precomputedLighting);
    }

}


void Terrain::buildMesh(Array<int>& index, Array<Point3>& vertex) {
    MeshBuilder builder(false, false);

    // Store LOD in the Y coordinate, store XZ on the texel grid resolution
    for (int level = 0; level < m_specification.numMeshLODLevels; ++level) {
        const int step = (1 << level);
        const int prevStep = max(0, (1 << (level - 1)));
        const int halfStep = prevStep;

        const int g = m_specification.meshBaseLODExtentHeightfieldTexels / 2;
        const float L = float(level);

        // Move up one grid level; used when stitching
        const Vector3 nextLevel(0, 1, 0);

        // Pad by one element to hide the gap to the next level
        const int pad = 1;
        const int radius = step * (g + pad);
        for (int z = -radius; z < radius; z += step) {
            for (int x = -radius; x < radius; x += step) {
                if (max(abs(x + halfStep), abs(z + halfStep)) >= g * prevStep) {
                    // Cleared the cutout from the previous level. Tessellate the
                    // square.

                    //   A-----B-----C
                    //   | \   |   / |
                    //   |   \ | /   |
                    //   D-----E-----F
                    //   |   / | \   |
                    //   | /   |   \ |
                    //   G-----H-----I

                    const Point3 A(float(x), L, float(z));
                    const Point3 C(float(x + step), L, A.z);
                    const Point3 G(A.x, L, float(z + step));
                    const Point3 I(C.x, L, G.z);

                    const Point3& B = (A + C) * 0.5f;
                    const Point3& D = (A + G) * 0.5f;
                    const Point3& F = (C + I) * 0.5f;
                    const Point3& H = (G + I) * 0.5f;

                    const Point3& E = (A + I) * 0.5f;

                    // Stitch the border into the next level

                    if (x == -radius) {
                        //   A-----B-----C
                        //   | \   |   / |
                        //   |   \ | /   |
                        //   |     E-----F
                        //   |   / | \   |
                        //   | /   |   \ |
                        //   G-----H-----I
                        builder.addTriangle(E, A, G);
                    } else {
                        builder.addTriangle(E, A, D);
                        builder.addTriangle(E, D, G);
                    }

                    if (z == radius - 1) {
                        builder.addTriangle(E, G, I);
                    } else {
                        builder.addTriangle(E, G, H);
                        builder.addTriangle(E, H, I);
                    }

                    if (x == radius - 1) {
                        builder.addTriangle(E, I, C);
                    } else {
                        builder.addTriangle(E, I, F);
                        builder.addTriangle(E, F, C);
                    }

                    if (z == -radius) {
                        builder.addTriangle(E, C, A);
                    } else {
                        builder.addTriangle(E, C, B);
                        builder.addTriangle(E, B, A);
                    }
                } // if
            } // x
        } // z
    } // level

    String ignore;
    builder.commit(ignore, index, vertex);
}


void Terrain::initMesh() {

    Array<int> index;
    Array<Point3> vertex;

    // Cache the mesh between runs because it is expensive to generate
    const String& filename = format("Terrain-%d-%d.ifs", 
        m_specification.meshBaseLODExtentHeightfieldTexels, m_specification.numMeshLODLevels);

    if (FileSystem::exists(filename)) {
        loadIFS(filename, index, vertex);
    } else if (FileSystem::exists(FilePath::concat("cache.zip", filename))) {
        loadIFS(FilePath::concat("cache.zip", filename), index, vertex);
    } else {
        buildMesh(index, vertex);
        saveIFS(filename, index, vertex);
    }
    
    // Copy to GPU
    const shared_ptr<VertexBuffer>& vb = VertexBuffer::create(sizeof(vertex[0]) * vertex.size() + sizeof(index[0]) * index.size() + 2);

    m_gridIndex  = IndexStream(index, vb);
    m_gridVertex = AttributeArray(vertex, vb);
}


void Terrain::reloadMaterials() {

    // Assign a unique index to each material, and load it
    Table<Specification::MaterialName, int> materialIndex;
    Array<shared_ptr<Texture>> materialArray;
    Texture::Specification s;        
    // Reducing the precision or using compression here has no impact on performance
    s.encoding = ImageFormat::RGB8();

    for (Table<Specification::MaterialName, String>::Iterator it = m_specification.materialTable.begin(); it.hasMore(); ++it) {
        materialIndex.set(it.key(), materialArray.size());
        s.filename = it.value();
        materialArray.next() = Texture::create(s);
        alwaysAssertM(materialArray.last()->vector2Bounds() == materialArray[0]->vector2Bounds(),
            "All terrain materials must have the same resolution");
    }

    // Build the mapping string
    m_elevationZoneDefinition = "";
    for (int z = 0; z < NUM_ELEVATION_ZONES; ++z) {
        const Specification::ElevationZone& zone = m_specification.elevationZone[z];
        m_elevationZoneDefinition += format("const float startElevation%d = %g, flatIndex%d = %g, steepIndex%d = %g;\n", 
            z, zone.startElevation, 
            z, float(materialIndex[zone.flat]),
            z, float(materialIndex[zone.steep]));
    }
    {
        // Make the array able to go one past the end
        const Specification::ElevationZone& zone = m_specification.elevationZone[NUM_ELEVATION_ZONES - 1];
        m_elevationZoneDefinition += format("const float startElevation%d = %g, flatIndex%d = %g, steepIndex%d = %g;\n", 
            NUM_ELEVATION_ZONES, 1e9, 
            NUM_ELEVATION_ZONES, float(materialIndex[zone.flat]),
            NUM_ELEVATION_ZONES, float(materialIndex[zone.steep]));
    }
    //debugPrintf("%s\n", m_elevationZoneDefinition.c_str());

    const int size = materialArray[0]->width();

    // Allocate the packed texture array
    const int numMipLevels = iFloor(log2(size));

    m_diffuse = Texture::createEmpty("Terrain::m_diffuse", size, size, materialArray[0]->format(), Texture::DIM_2D_ARRAY, true, materialArray.size());
 
    glBindTexture(GL_TEXTURE_2D_ARRAY, m_diffuse->openGLID());
    glTexStorage3D(GL_TEXTURE_2D_ARRAY, numMipLevels, GL_RGBA8, size, size, materialArray.size());
    debugAssertGLOk();

    const int srcDepth = 1;
    for (int m = 0; m < materialArray.size(); ++m) {
        for (int level = 0; level < numMipLevels; ++level) {
            shared_ptr<GLPixelTransferBuffer> src = 
                dynamic_pointer_cast<GLPixelTransferBuffer>(materialArray[m]->toPixelTransferBuffer(materialArray[m]->format(), level));
            src->bindRead();
            if (src->format()->compressed) {
                debugAssertM(false, "not implemented");
                // Compressed sub images don't work with array textures--
                // these have to upload all of the data at once as glCompressedImage3D
                glCompressedTexSubImage3D(
                    m_diffuse->openGLTextureTarget(),
                    level, 
                    0, 0, m,
                    src->width(), src->height(), srcDepth,
                    src->format()->openGLFormat,
                    (GLsizei)src->size(),
                    0);
                debugAssertGLOk();
            } else {
                glTexSubImage3D(m_diffuse->openGLTextureTarget(), level, 0, 0, m, src->width(), src->height(), srcDepth, src->format()->openGLBaseFormat, GL_UNSIGNED_BYTE, 0);
            }
            src->unbindRead();
            debugAssertGLOk();
        }
    }
    glBindTexture(GL_TEXTURE_2D_ARRAY, GL_NONE);

    // Load the noise texture
    {
        Texture::Specification s;
        s.filename = m_specification.lowFrequencyTextureFilename;
        s.encoding = ImageFormat::R8();
        s.generateMipMaps = true;
        // We can't store in an SRGB format because it has only one channel, 
        // so adjust the gamma here. This isn't even used as a visible texture, 
        // but we want the character of the noise to match what was observed 
        // when it was authored.
        s.preprocess = Texture::Preprocess::gamma(2.1f);
        m_lowFrequencyTexture = Texture::create(s);
    }

    // Precompute the blended lowest-MIP values for m_diffuse for use on
    // distant surfaces.
    {
        RenderDevice* rd = RenderDevice::current;
        const int slopeSamples = 48, elevationSamples = 256;
        shared_ptr<Texture> temp = Texture::createEmpty("distantDiffuse temporary", slopeSamples, elevationSamples, ImageFormat::RGB32F());
        rd->push2D(Framebuffer::create(temp)); {
            rd->clear();
            Args args;
            m_diffuse->setShaderArgs(args, "diffuse_", Sampler::defaults());
            args.setMacro("NUM_ELEVATION_ZONES", NUM_ELEVATION_ZONES);
            args.appendToPreamble(m_elevationZoneDefinition);
            args.setUniform("heightfield_readMultiplyFirst", m_heightfield->encoding().readMultiplyFirst.a);
            args.setUniform("heightfield_readAddSecond", m_heightfield->encoding().readAddSecond.a);
            args.setRect(rd->viewport());
            LAUNCH_SHADER("Terrain_generateDistantDiffuse.pix", args);
        } rd->pop2D();

        m_distantDiffuse = Texture::fromPixelTransferBuffer("Terrain::m_distantDiffuse", temp->toPixelTransferBuffer(ImageFormat::RGB32F()), ImageFormat::RGB_DXT1());
    }
}


void Terrain::renderWireframe(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<Camera>& camera) {
    rd->pushState(); {
        rd->setBlendFunc(RenderDevice::BLEND_SRC_ALPHA, RenderDevice::BLEND_ONE_MINUS_SRC_ALPHA);
        rd->setRenderMode(RenderDevice::RENDER_WIREFRAME);
        render(rd, lightingEnvironment, camera, BLACK, 0.01f, rd->viewport());
    } rd->popState();
}


void Terrain::render(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<Camera>& camera, Visualization v) {
    switch (v) {
    case NONE:
        render(rd, lightingEnvironment, camera, SHADE, 0.0f, rd->viewport());
        break;

    case TESSELLATION:
        rd->pushState(); {
            render(rd, lightingEnvironment, camera, BLACK, 0.0f, rd->viewport());
            rd->setRenderMode(RenderDevice::RENDER_WIREFRAME);
            glEnable(GL_LINE_SMOOTH);
            glHint( GL_LINE_SMOOTH_HINT, GL_NICEST);
            rd->setBlendFunc(RenderDevice::BLEND_SRC_ALPHA, RenderDevice::BLEND_ONE_MINUS_SRC_ALPHA);
            render(rd, lightingEnvironment, camera, NEON, 0.01f, rd->viewport());
        } rd->popState();
        break;

    case TEXTURE_PARAM:
        render(rd, lightingEnvironment, camera, TEXTURE_PARAM, 0.0f, rd->viewport());
        break;
    }
}


void Terrain::render(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<Camera>& camera, RenderMode mode, float verticalOffset, const Rect2D& colorRect) {
    rd->pushState(); {
        Args args;

        args.appendToPreamble(m_elevationZoneDefinition);

        args.setAttributeArray("g3d_Vertex", m_gridVertex);
        args.setIndexArray(m_gridIndex);
        args.setPrimitiveType(PrimitiveType::TRIANGLES);
        args.setMacro("NUM_ELEVATION_ZONES", NUM_ELEVATION_ZONES);

        Sampler sampler = Sampler::defaultClamp();
        // For explicit trilinear interpolation
        sampler.interpolateMode = InterpolateMode::LINEAR_MIPMAP_NEAREST;
        m_heightfield->setShaderArgs(args, "heightfield_", sampler);
        args.setUniform("heightfield_invReadMultiplyFirst", 1.0f / m_heightfield->encoding().readMultiplyFirst.a);
        args.setUniform("heightfieldTexelsPerMeter", 1.0f / m_specification.metersPerHeightfieldTexel);
        args.setUniform("metersPerHeightfieldTexel", m_specification.metersPerHeightfieldTexel);

        args.setUniform("verticalOffset", verticalOffset);

        shared_ptr<Light> sun = findSun(lightingEnvironment.lightArray);
        args.setUniform("directionToSun", sun->frame().translation.direction());
        args.setUniform("baseGridSizeTexels", float(m_specification.meshBaseLODExtentHeightfieldTexels));
        args.setUniform("invBaseGridSizeTexels", 1.0f / float(m_specification.meshBaseLODExtentHeightfieldTexels));
        
        m_lowFrequencyTexture->setShaderArgs(args, "lowFrequencyTexture_", Sampler::defaults());
        m_precomputedLighting->setShaderArgs(args, "precomputedLighting_", Sampler::video());

        m_distantDiffuse->setShaderArgs(args, "distantDiffuse_", Sampler::defaultClamp());
        m_diffuse->setShaderArgs(args, "diffuse_", Sampler::defaults());

        args.setUniform("lowerCoord", colorRect.x0y0());
        args.setUniform("upperCoord", colorRect.x1y1());
        args.setUniform("materialTilesPerMeter", 1.0f / m_specification.metersPerMaterialTile);

        rd->setObjectToWorldMatrix(CFrame());
        rd->setProjectionAndCameraMatrix(camera->projection(), camera->frame());
        {
            CFrame previousFrame;
            
            const CFrame& previousObjectToCameraMatrix = camera->previousFrame().inverse() * previousFrame;
            args.setUniform("PreviousObjectToCameraMatrix", previousObjectToCameraMatrix, true);

            const CFrame& expressivePreviousObjectToCameraMatrix = camera->expressivePreviousFrame().inverse() * previousFrame;
            args.setUniform("ExpressivePreviousObjectToCameraMatrix", expressivePreviousObjectToCameraMatrix, true);

            // Map (-1, 1) normalized device coordinates to actual pixel positions
            const Matrix4& screenSize =
                Matrix4(rd->width() / 2.0f, 0.0f,                0.0f, rd->width() / 2.0f,
                        0.0f,               rd->height() / 2.0f, 0.0f, rd->height() / 2.0f,
                        0.0f,               0.0f,                1.0f, 0.0f,
                        0.0f,               0.0f,                0.0f, 1.0f);
            args.setUniform("ProjectToScreenMatrix", screenSize * rd->invertYMatrix() * rd->projectionMatrix(), true);
        }

        args.setMacro("MODE", int(mode));
        LAUNCH_SHADER("Terrain_render.*", args);       
    } rd->popState();
}


void Terrain::renderIntoGBuffer(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<GBuffer>& gbuffer) {
    debugAssertM(notNull(gbuffer->texture(GBuffer::Field::EMISSIVE)), 
        "Terrain uses precomputed lighting and requires a GBuffer with an EMISSIVE field");

    rd->pushState(gbuffer->framebuffer()); {
        render(rd, lightingEnvironment, gbuffer->camera(), GBUFFER, 0.0f, gbuffer->colorRect()); 
    } rd->popState();
}


void Terrain::loadIFS(const String& filename, Array<int>& index, Array<Point3>& vertex) {
    BinaryInput bi(filename, G3D_LITTLE_ENDIAN);

    if (bi.getLength() == 0) {
        throw String("Failed to open " + filename);
    }
        
    const String& header = bi.readString32();
    if (strcmp(header.c_str(), "IFS") != 0) {
        throw String("File is not an IFS file");
    }

    const float32 ifsversion  = bi.readFloat32();
    if (ifsversion != 1.0f && ifsversion != 1.1f) {
        throw String("Bad IFS version, expecting 1.0 or 1.1");
    }
        
    String name = bi.readString32();

    while (bi.hasMore()) {
        String str = bi.readString32();
            
        if (str == "VERTICES") {
            debugAssertM(vertex.size() == 0, "Multiple vertex fields!");
            const uint32 num = bi.readUInt32();
                
            if ((num <= 0) || (num > 10000000)) {
                throw String("Bad number of vertices");
            }
            
            vertex.resize(num);
            if (bi.endian() == System::machineEndian()) {
                bi.readBytes(vertex.getCArray(), sizeof(vertex[0]) * vertex.length());
            } else {
                for (uint32 i = 0; i < num; ++i) {
                    vertex[i].deserialize(bi);
                }
            }
                
        } else if (str == "TRIANGLES") {
            debugAssertM(index.size() == 0,
                            "Multiple triangle fields!");
            const uint32 num = bi.readUInt32();
                
            if ((num <= 0) || (num > 100000000)) {
                throw String("Bad number of triangles");
            }
                
            index.resize(num * 3);
            if (bi.endian() == System::machineEndian()) {
                bi.readBytes(index.getCArray(), sizeof(index[0]) * index.length());
            } else {
                for (uint32 i = 0; i < (uint32)index.size(); ++i) {
                    index[i] = bi.readUInt32();
                }
            }
        } else if (str == "TEXTURECOORD") {
            debugAssertM(ifsversion == 1.1f, "IFS Version should be 1.1");
            const uint32 num = bi.readUInt32();
            bi.skip(num * sizeof(Point2));
        }
    } // while has more data
}


void Terrain::saveIFS(const String& filename, const Array<int>& index, const Array<Point3>& vertex) {
    BinaryOutput bo(filename, G3D_LITTLE_ENDIAN);

    bo.writeString32("IFS");
    bo.writeFloat32(1.1f);
    bo.writeString32(filename);        

    bo.writeString32("VERTICES");
    bo.writeUInt32(vertex.size());
    for (int i = 0; i < vertex.size(); ++i) {
        vertex[i].serialize(bo);
    }
                
    bo.writeString32("TRIANGLES");
    bo.writeUInt32(index.size() / 3);
    for (int i = 0; i < index.size(); ++i) {
        bo.writeUInt32(index[i]);
    }

    bo.commit();
}

///////////////////////////////////////////////////////////////////
Terrain::Specification::Specification() : 
    numMeshLODLevels(7),
    metersPerHeightfieldTexel(1.0f * units::meters()), 
    metersPerMaterialTile(4.0f * units::meters()),
    minElevation(-400.0f * units::meters()),
    maxElevation(1000.0f * units::meters()),
    meshBaseLODExtentHeightfieldTexels(128) {
}


Terrain::Specification::Specification(const Any& any) {
    *this = Specification();

    any.verifyName("Terrain::Specification");
    AnyTableReader reader(any);

    reader.getIfPresent("metersPerHeightfieldTexel",    metersPerHeightfieldTexel);
    reader.getIfPresent("minElevation",                 minElevation);
    reader.getIfPresent("maxElevation",                 maxElevation);
    reader.getFilenameIfPresent("heightfieldFilename",  heightfieldFilename);
    reader.getIfPresent("metersPerMaterialTile",        metersPerMaterialTile);
    reader.getFilenameIfPresent("lowFrequencyTextureFilename", lowFrequencyTextureFilename);

    Any table;
    if (reader.getIfPresent("materialTable", table)) {
        for (Table<String, Any>::Iterator it = table.table().begin(); it.hasMore(); ++it) {
            materialTable.set(it.key(), it.value().resolveStringAsFilename());
        }
    }

    Any elevationZoneArray;
    if (reader.getIfPresent("elevationZoneArray", elevationZoneArray)) {
        elevationZoneArray.verifyType(Any::ARRAY);
        elevationZoneArray.verifySize(NUM_ELEVATION_ZONES);
        for (int i = 0; i < NUM_ELEVATION_ZONES; ++i) {
            elevationZone[i] = elevationZoneArray[i];
        }
    }
    elevationZone[0].startElevation = -1e9;

    reader.getIfPresent("numMeshLODLevels",                   numMeshLODLevels);
    reader.getIfPresent("meshBaseLODExtentHeightfieldTexels", meshBaseLODExtentHeightfieldTexels);

    reader.verifyDone();
}


Terrain::Specification::ElevationZone::ElevationZone() {}


Terrain::Specification::ElevationZone::ElevationZone(const Any& any) {
    *this = ElevationZone();

    AnyTableReader reader(any);
    reader.getIfPresent("steep",    steep);
    reader.getIfPresent("flat",     flat);
    reader.getIfPresent("startElevation",   startElevation);
    
    reader.verifyDone();
}
