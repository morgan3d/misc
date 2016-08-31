Vector4 glToScreen(const Vector4& v) {
    
    // Get the matrices and viewport
    double modelView[16];
    double projection[16];
    double viewport[4];
    double depthRange[2];

    glGetDoublev(GL_MODELVIEW_MATRIX, modelView);
    glGetDoublev(GL_PROJECTION_MATRIX, projection);
    glGetDoublev(GL_VIEWPORT, viewport);
    glGetDoublev(GL_DEPTH_RANGE, depthRange);

    // Compose the matrices into a single row-major transformation
    Vector4 T[4];
    int r, c, i;
    for (r = 0; r < 4; ++r) {
        for (c = 0; c < 4; ++c) {
            T[r][c] = 0;
            for (i = 0; i < 4; ++i) {
                // OpenGL matrices are column major
                T[r][c] += projection[r + i * 4] * modelView[i + c * 4];
            }
        }
    }

    // Transform the vertex
    Vector4 result;
    for (r = 0; r < 4; ++r) {
        result[r] = T[r].dot(v);
    }

    // Homogeneous divide
    const double rhw = 1 / result.w;

    return Vector4(
        (1 + result.x * rhw) * viewport[2] / 2 + viewport[0],
        (1 - result.y * rhw) * viewport[3] / 2 + viewport[1],
        (result.z * rhw) * (depthRange[1] - depthRange[0]) + depthRange[0],
        rhw);
}