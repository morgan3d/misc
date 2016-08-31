/** 
  \file Terrain.h
  \author Morgan McGuire, http://cs.williams.edu/~morgan
*/
#ifndef Terrain_h
#define Terrain_h

#include <G3D/G3DAll.h>

/** \brief A Terrain */
class Terrain : public ReferenceCountedObject {
public:
    static const int NUM_ELEVATION_ZONES = 5;

    enum Visualization {
        NONE,
        TESSELLATION,
        TEXTURE_PARAMETERIZATION
    };

    class Specification {
    public:

        typedef String MaterialName;

        float           metersPerHeightfieldTexel;
    
        float           minElevation;
        float           maxElevation;

        String          heightfieldFilename;

        /** Distance in XZ before the VerticalBiome texture coordinates repeat. */
        float           metersPerMaterialTile;

        /** Increase to see farther to the horizon. */
        int             numMeshLODLevels;

        /** The highest level of detail of the mesh always contains one grid cell
            per heightfield texel. This indicates the width in texels before 
            the mesh resolution drops. It must be a power of two.*/
        int             meshBaseLODExtentHeightfieldTexels;

        String          lowFrequencyTextureFilename;

        /** Maps material names to filenames */
        Table<MaterialName, String> materialTable;

        /** Vertically-deliminated biome-like zone */
        class ElevationZone {
        public:
            /** The starting elevation of the lowest biome is forced to -finf() */
            float           startElevation;
            MaterialName    steep;
            MaterialName    flat;

            ElevationZone();
            ElevationZone(const Any& any);
        };

        ElevationZone      elevationZone[NUM_ELEVATION_ZONES];

        Specification();
        Specification(const Any& a);
    };

protected:

    enum RenderMode {
        BLACK = 1,
        TEXTURE_PARAM = 2,
        NEON = 3,
        SHADE = 4,
        GBUFFER = 5
    };

    Specification               m_specification;

    shared_ptr<Texture>         m_heightfield;

    /** RGB = ambient, A = sun visibility */
    shared_ptr<Texture>         m_precomputedLighting;

    AttributeArray              m_gridVertex;
    IndexStream                 m_gridIndex;

    /** The texture, as a 2D texture array */
    shared_ptr<Texture>         m_diffuse;

    /** Prepended onto shaders */
    String                      m_elevationZoneDefinition;

    /** Precomputed table based on (weight.y, rawElevation,) for the average
        value of m_diffuse texture layer. */
    shared_ptr<Texture>         m_distantDiffuse;

    shared_ptr<Texture>         m_lowFrequencyTexture;

    Terrain(const Specification& specification, const LightingEnvironment& lighting);

    void initElevation(const String& filename);
    void initMesh();
    void initPrecomputedLighting(const LightingEnvironment& lighting);

    /** Called from initMesh */
    void buildMesh(Array<int>& index, Array<Point3>& vertex);

    static void loadIFS(const String& filename, Array<int>& index, Array<Point3>& vertex);
    static void saveIFS(const String& filename, const Array<int>& index, const Array<Point3>& vertex);

    /** \param colorRect Region inside the depth guard band; do not compute shading outside of this. */
    void render(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<Camera>& camera, RenderMode mode, float verticalOffset, const Rect2D& colorRect);

public:

    ~Terrain();

    /** Assumes that the brightest light is the sun */
    static shared_ptr<Terrain> create(const Specification& specification, const LightingEnvironment& lighting);

    void reloadMaterials();
    void renderWireframe(RenderDevice* rd, const LightingEnvironment& lightingEnvironment, const shared_ptr<Camera>& camera);

    /** Assumes that the brightest light and environment maps have not changed since the terrain was created. */
    void render(RenderDevice* rd, const LightingEnvironment& lighting, const shared_ptr<Camera>& camera, Visualization v = NONE);
    void renderIntoGBuffer(RenderDevice* rd, const LightingEnvironment& lighting, const shared_ptr<GBuffer>& gbuffer);
};

#endif
