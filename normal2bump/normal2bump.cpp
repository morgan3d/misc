/**
 Estimates a bump map from a normal map.

 Provide one or more filename specifications on the command line.

 by Morgan McGuire
 */
#include <G3D/G3DAll.h> // http://g3d.sf.net

// Tells C++ to invoke command-line main() function even on OS X and Win32.
G3D_START_AT_MAIN();

using namespace G3D::units;

/* Set the sign convention based on the coordinate system of your
   source normal map and texture coordinates. It will be fairly
   obvious if you choose the wrong one because the height map will be
   "inside out" along some dimension. */
static const float signConvention =
    // -1.0f; // G3D
    1.0f; // 3DS Max


// Not used by this program
static void bumpToNormal(const std::string& srcFilename, const std::string& dstFilename) {
    GImage src(srcFilename);
    GImage dst;
    GImage::computeNormalMap(src, dst);
    dst.save(dstFilename);
}

// Main routine
static void normalToBump(const std::string& srcFilename, const std::string& dstFilename) {
    printf("%s -> ", srcFilename.c_str());
    Image3::Ref normalMap = Image3::fromFile(srcFilename, WrapMode::TILE);

    const int w = normalMap->width();
    const int h = normalMap->height();

    // Compute the laplacian once; it never changes
    Image1::Ref laplacian = Image1::createEmpty(w, h, WrapMode::ERROR);

    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            float ddx = normalMap->get(x + 1, y).r - normalMap->get(x - 1, y).r;
            float ddy = normalMap->get(x, y + 1).g - normalMap->get(x, y - 1).g;
            laplacian->set(x, y, Color1(ddx + signConvention * ddy) / 2.0f);
        }
    }

    // Ping-pong buffers
    Image1::Ref src = Image1::createEmpty(w, h, WrapMode::TILE);
    Image1::Ref dst = Image1::createEmpty(w, h, WrapMode::TILE);

    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            dst->set(x, y, Color1(0.5));
        }
    }

    // Number of Poisson iterations
    const int N = 100;
    for (int i = 0; i < N; ++i) {
        // Swap buffers
        Image1::Ref tmp = src;
        src = dst;
        dst = tmp;

        for (int x = 0; x < w; ++x) {
            for (int y = 0; y < h; ++y) {
                dst->set(x, y,
                         Color1((src->get(x - 1, y).value + src->get(x, y - 1).value +
                                 src->get(x + 1, y).value + src->get(x, y + 1).value + 
                                 laplacian->get(x, y).value) * 0.25f));
            }
        }
    }

    float lo = inf(), hi = -inf();
    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            float v = dst->get(x, y).value;
            lo = min(lo, v);
            hi = max(hi, v);
        }
    }
    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            dst->set(x, y, Color1((dst->get(x, y).value - lo) / (hi - lo)));
        }
    }

    dst->save(dstFilename);
    printf("%s\n", dstFilename.c_str());
}


int convert(const int count, const char** fileSpecList) {
    Array<std::string> files;
    for (int i = 0; i < count; ++i) {
        const std::string& spec = fileSpecList[i];
        FileSystem::getFiles(spec, files);
    }

    for (int i = 0; i < files.size(); ++i) {
        const std::string& source = files[i];
        const std::string& dest = FilePath::base(files[i]) + "-bump" + ".png";
        normalToBump(source, dest);
    }

    return files.size();
}


int main(int argc, const char** argv) {

    (void)bumpToNormal;
    Stopwatch timer;

    timer.tick();
    const int count = convert(argc - 1, argv + 1);
    timer.tock();

    RealTime time = timer.elapsedTime();
    printf("\n%d files converted in %d hours %d min.\n", 
                count, iFloor(time / hours()), iFloor(time / minutes()) % 60);
    return 0;
}
