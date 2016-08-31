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
    //-1.0f; // G3D
    1.0f; // 3DS Max

// See G3D::BumpMap::computeNormalMap for conversion from bump to normal

// Main routine
static void normalToBump(const String& srcFilename, const String& dstFilename) {
    debugPrintf("Processing %s\n", srcFilename.c_str());
    shared_ptr<Image> normalMap = Image::fromFile(srcFilename);

    const int w = normalMap->width();
    const int h = normalMap->height();

    // Compute the laplacian once; it never changes
    shared_ptr<Image> laplacian = Image::create(w, h, ImageFormat::R32F());

    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            float ddx = normalMap->get<Color3>(x + 1, y, WrapMode::TILE).r - normalMap->get<Color3>(x - 1, y, WrapMode::TILE).r;
            float ddy = normalMap->get<Color3>(x, y + 1, WrapMode::TILE).g - normalMap->get<Color3>(x, y - 1, WrapMode::TILE).g;
            laplacian->set(x, y, Color1(ddx + signConvention * ddy) / 2.0f);
        }
    }

    // Ping-pong buffers
    shared_ptr<Image> src = Image::create(w, h, ImageFormat::R32F());
    shared_ptr<Image> dst = Image::create(w, h, ImageFormat::R32F());

    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            dst->set(x, y, Color1(0.5));
        }
    }

    // Number of Poisson iterations
    const int N = 100;
    for (int i = 0; i < N; ++i) {
        // Swap buffers
        shared_ptr<Image> tmp = src;
        src = dst;
        dst = tmp;

        for (int x = 0; x < w; ++x) {
            for (int y = 0; y < h; ++y) {
                dst->set(x, y,
                         Color1((src->get<Color1>(x - 1, y, WrapMode::TILE).value + src->get<Color1>(x, y - 1, WrapMode::TILE).value +
                                 src->get<Color1>(x + 1, y, WrapMode::TILE).value + src->get<Color1>(x, y + 1, WrapMode::TILE).value + 
                                 laplacian->get<Color1>(x, y).value) * 0.25f));
            }
        }
        debugPrintf("On pass %d/%d\n", i, N);
    }

    float lo = finf(), hi = -finf();
    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            const float v = dst->get<Color1>(x, y).value;
            lo = min(lo, v);
            hi = max(hi, v);
        }
    }

    shared_ptr<Image> final = Image::create(w, h, ImageFormat::RGB8());
    for (int x = 0; x < w; ++x) {
        for (int y = 0; y < h; ++y) {
            final->set(x, y, Color1((dst->get<Color1>(x, y).value - lo) / (hi - lo)));
        }
    }

    final->save(dstFilename);
    debugPrintf("Saved %s\n", dstFilename.c_str());
}


int convert(const int count, const char** fileSpecList) {
    Array<String> files;
    for (int i = 0; i < count; ++i) {
        const String& spec = fileSpecList[i];
        FileSystem::getFiles(spec, files, true);
    }

    for (int i = 0; i < files.size(); ++i) {
        const String& source = files[i];
        const String& dest = FilePath::concat(FilePath::parent(files[i]), FilePath::base(files[i])) + "-bump" + ".png";
        normalToBump(source, dest);
    }

    return files.size();
}


int main(int argc, const char** argv) {
    Stopwatch timer;

    timer.tick();
    // const char* c[] = {"C:/Users/morgan/Downloads/normal.tga"}; const int count = convert(1, c);
    const int count = convert(argc - 1, argv + 1);
    timer.tock();

    RealTime time = timer.elapsedTime();
    printf("\n%d files converted in %d hours %d min.\n", 
                count, iFloor(time / hours()), iFloor(time / minutes()) % 60);
    return 0;
}
