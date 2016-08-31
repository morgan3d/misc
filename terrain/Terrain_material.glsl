#ifndef Terrain_material_glsl // -*- c++ -*-
#define Terrain_material_glsl 
/** 
  \file Terrain_material.glsl
  \author Morgan McGuire, http://cs.williams.edu/~morgan

  Shared routines for computing the diffuse material coefficient 
  texture coordinates from the elevation and orientation of
  the heightfield.
*/

#define TextureIndex float

#expect NUM_ELEVATION_ZONES "int"

/** Elevation over which one zone blends into another*/
const float transitionRadius = 3.0;

/** Texture MIP level assumed to be beyond the diffuse 
    texture's MIP chain, for forcing the average. */
const float maxMaterialLOD = 12;


void getTextureIndicesFromElevation(float y, out float verticalBlend, out float lowFlat, out float lowSteep, out float highFlat, out float highSteep) {
    // Unrolled to avoid actual array accesses
#   for (int i = 0; i < NUM_ELEVATION_ZONES; ++i)
        if ((y > startElevation$(i) + transitionRadius) && (y <= startElevation$(i + 1) + transitionRadius)) {
            lowFlat      = flatIndex$(i);      lowSteep    = steepIndex$(i);
            highFlat     = flatIndex$(i + 1);  highSteep   = steepIndex$(i + 1);

            verticalBlend = clamp((y - (startElevation$(i + 1) - transitionRadius)) / (transitionRadius * 2.0), 0.0, 1.0);
        }
#   endfor
}


void getTextureIndicesFromElevation(float y, out float lowFlat, out float lowSteep) {
    // Unrolled to avoid actual array accesses
#   for (int i = 0; i < NUM_ELEVATION_ZONES; ++i)
    if ((y > startElevation$(i) + transitionRadius) && (y <= startElevation$(i + 1) + transitionRadius)) {
        lowFlat      = flatIndex$(i);      lowSteep    = steepIndex$(i);
    }
#   endfor
}

#endif
