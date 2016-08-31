/** 
 \file convertToOBJ.cpp
 \author Morgan McGuire, http://graphics.cs.williams.edu

 Convert any file format supported by G3D (e.g., OBJ, IFS, PLY, PLY2) to an
 optimized OBJ file.

 Uses the http://g3d.sf.net G3D Innovation Engine.
*/
#include <G3D/G3DAll.h>

/** Dumps the geometry and texture coordinates (no materials) to a
    file.  Does not deal with nested parts */
void convertToOBJFile(const std::string& srcFilename) {
    const std::string dstFilename = FilePath::base(srcFilename) + ".obj";

    FILE* file = FileSystem::fopen(dstFilename.c_str(), "wt");

    ArticulatedModel2::Ref m = ArticulatedModel2::fromFile(srcFilename);

    {
        int tri, vert;
        m->countTrianglesAndVertices(tri, vert);
        debugPrintf("%d triangles, %d vertices\nGenerating OBJ...\n", tri, vert);
    }

    fprintf(file, "# %s\n\n", m->name.c_str());
    for (int p = 0; p < m->rootArray().size(); ++p) {
        const ArticulatedModel2::Part* part = m->rootArray()[p];

        const CFrame& cframe = part->cframe;
        
        // Number of vertices
        const int N = part->cpuVertexArray.size();

        // Construct a legal part name
        std::string name = "";
        for (int i = 0; i < (int)part->name.size(); ++i) {
            const char c = part->name[i];
            if (isDigit(c) || isLetter(c)) {
                name += c;
            } else {
                name += "_";
            }
        }

        if (name == "") {
            name = format("UnnamedPart%d", p);
        }

        // Part name
        fprintf(file, "\ng %s \n", name.c_str());

        // Write geometry.  Compress the data by only writing
        // unique values in each of the v, vt, vn arrays,
        // and using %g for output.
        fprintf(file, "\n");
            
        Table<Point3, int> vertexToVertexIndex;
        Table<int, int> vertexIndexToVertexIndex;
        int numVertices = 0;
        for (int v = 0; v < N; ++v) {
            const Point3& vertex = part->cpuVertexArray.vertex[v].position;
            bool created = false;
            int& vertexIndex = vertexToVertexIndex.getCreate(vertex, created);
            if (created) {
                const Point3& transformed = cframe.pointToWorldSpace(vertex);
                fprintf(file, "v %g %g %g\n", transformed.x, transformed.y, transformed.z);
                vertexIndex = numVertices; 
                ++numVertices;
            }
            vertexIndexToVertexIndex.set(v, vertexIndex);
        }
                        
        bool hasTexCoords = part->hasTexCoord0();
        Table<Point2, int> texCoordToTexCoordIndex;
        Table<int, int> texCoordIndexToTexCoordIndex;
        int numTexCoords = 0;
        if (hasTexCoords) {
            // Make sure there really are useful (nonzero) texture coordinates
            hasTexCoords = false;
            for (int v = 0; v < N; ++v) {
                if (! part->cpuVertexArray.vertex[v].texCoord0.isZero()) {
                    hasTexCoords = true;
                    break;
                }
            }

            fprintf(file, "\n");
            for (int v = 0; v < N; ++v) {
                const Point2& texCoord = part->cpuVertexArray.vertex[v].texCoord0;
                bool created = false;
                int& texCoordIndex = texCoordToTexCoordIndex.getCreate(texCoord, created);
                if (created) {
                    // G3D's texture coordinate convention is upside down of OBJ's
                    fprintf(file, "vt %g %g\n", texCoord.x, 1.0f - texCoord.y);
                    texCoordIndex = numTexCoords;
                    ++numTexCoords;
                }
                texCoordIndexToTexCoordIndex.set(v, texCoordIndex);
            }
        }

        fprintf(file, "\n");
        Table<Vector3, int> normalToNormalIndex;
        Table<int, int> normalIndexToNormalIndex;
        int numNormals = 0;
        for (int v = 0; v < N; ++v) {
            const Vector3& normal = part->cpuVertexArray.vertex[v].normal;
            bool created = false;
            int& normalIndex = normalToNormalIndex.getCreate(normal, created);
            if (created) {
                const Vector3& transformed = cframe.vectorToWorldSpace(normal);
                fprintf(file, "vn %g %g %g\n", transformed.x, transformed.y, transformed.z);
                normalIndex = numNormals;
                ++numNormals;
            }
            normalIndexToNormalIndex.set(v, normalIndex);
        }

        // Triangle list
        fprintf(file, "\n");
        for (int t = 0; t < part->meshArray().size(); ++t) {
            const ArticulatedModel2::Mesh* mesh = part->meshArray()[t];
            alwaysAssertM(mesh->primitive == PrimitiveType::TRIANGLES, "Only triangle lists supported");
            for (int i = 0; i < mesh->cpuIndexArray.size(); i += 3) {
                fprintf(file, "f");
                for (int j = 0; j < 3; ++j) {
                    // Vertex index in the original mesh
                    const int index = mesh->cpuIndexArray[i + j];

                    // Indices are 1-based; negative values
                    // reference relative to the last vertex
                    // added.

                    if (hasTexCoords) {
                        fprintf(file, " %d/%d/%d", 
                                vertexIndexToVertexIndex[index] - numVertices, 
                                texCoordIndexToTexCoordIndex[index] - numTexCoords, 
                                normalIndexToNormalIndex[index] - numNormals);
                    } else {
                        fprintf(file, " %d//%d",
                                vertexIndexToVertexIndex[index] - numVertices, 
                                normalIndexToNormalIndex[index] - numNormals);
                    }
                }
                fprintf(file, "\n");
            }
        }
    }
    
    FileSystem::fclose(file);
}
