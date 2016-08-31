import java.awt.image.BufferedImage;

/**
   Terrain surface
 */
public class Terrain {

    /** elevationArray[x * width + z] = y */
    private float[]  elevationArray;

    /** TYPE_INT_ARGB format */
    private int[]    colorArray;

    /** Must be a power of 2 */
    private int      width;

    /**
       width - 1
     */
    private int      widthMask;

    /** Must be a power of 2 */
    private int      height;

    /**
       height - 1
     */
    private int      heightMask;

    /**
       log width
     */
    private int      scanShift;


    public Terrain() {
        this("color-64.jpg", "hills-64.jpg");
    }

    /**
       Both images must be the same size and powers of two.
     */
    public Terrain(String colorFile, String elevationFile) {
        BufferedImage colorImage     = Screen.loadImage(colorFile);
        BufferedImage elevationImage = Screen.loadImage(elevationFile);

        width  = elevationImage.getWidth();
        height = elevationImage.getHeight();

        assert colorImage.getWidth()  == width;
        assert colorImage.getHeight() == height;
        
        colorArray = colorImage.getRGB(0, 0, width, height, null, 0, width);
        
        int[] e = elevationImage.getRGB(0, 0, width, height, null, 0, width);
        elevationArray = new float[e.length];
        for (int i = 0; i < e.length; ++i) {
            elevationArray[i] = (float)(e[i] & 0xFF);
        }

        widthMask  = width - 1;
        heightMask = height - 1;
        
        scanShift = (int)(Math.log(width) / Math.log(2));

        assert Math.pow(2, scanShift) == width : "Width must be a power of two";
    }

    static class BilinearCoeffs {
        /** Indices */
        public final int[]   index   = new int[4];
        public final float[] weight  = new float[4];

        /** Sample f at the specified indices and produce the bilinear
         * interpolated position.*/
        public final float interpolate(float[] f) {
            return 
                f[index[0]] * weight[0] +
                f[index[1]] * weight[1] +
                f[index[2]] * weight[2] +
                f[index[3]] * weight[3];
        }

        /** Performs bilinear interpolation on color channels and then adds white fog */
        public final int colorInterpolate(int[] c, float fog) {
            int c0 = c[index[0]];
            int c1 = c[index[1]];
            int c2 = c[index[2]];
            int c3 = c[index[3]];
            
            float invFog = 1.0f - fog;
            int haze = (int)(0xFF * fog);

            int b = (int)(((c0 & 0xFF) * weight[0] +
                           (c1 & 0xFF) * weight[1] +
                           (c2 & 0xFF) * weight[2] +
                           (c3 & 0xFF) * weight[3]) * invFog);
                
            int g = (int)(((c0 & 0xFF00) * weight[0] +
                           (c1 & 0xFF00) * weight[1] +
                           (c2 & 0xFF00) * weight[2] +
                           (c3 & 0xFF00) * weight[3]) * invFog) & 0xFF00;
            
            int r = (int)(((c0 & 0xFF0000) * weight[0] +
                           (c1 & 0xFF0000) * weight[1] +
                           (c2 & 0xFF0000) * weight[2] +
                           (c3 & 0xFF0000) * weight[3]) * invFog) & 0xFF0000;

            return 0xFF000000 + r + g + b + (haze << 16) + (haze << 8) + haze;
        }
    }
    
    final protected void getBilinearCoeffs(float x, float z, BilinearCoeffs b) {
        float fx = (float)Math.floor(x);
        float fz = (float)Math.floor(z);

        int ix = (int)fx;
        int iz = (int)fz;

        // (x % width) + (z % height) * width

        int col0 = ix        & widthMask;
        int col1 = (ix + 1)  & widthMask;
        int row0 = (iz       & heightMask) << scanShift;
        int row1 = ((iz + 1) & heightMask) << scanShift;
        
        b.index[0] = row0 + col0;
        b.index[1] = row0 + col1;
        b.index[2] = row1 + col0;
        b.index[3] = row1 + col1;

        float dx = x - fx;
        float dz = z - fz;

        b.weight[0] = (1.0f - dx) * (1.0f - dz);
        b.weight[1] = dx          * (1.0f - dz);
        b.weight[2] = (1.0f - dx) * dz;
        b.weight[3] = dx          * dz;
    }

    /**
       Renders the terrain to the screen.

       @param screen Color buffer
       @param viewFOVX Horizontal field of view in radians
       @param viewTheta Horizontal angle of view direction in radians
       @param viewX  Viewer's world-space X position
     */
    public void render(int[] screen, int screenWidth, int screenHeight, 
                       float viewFOVX, float viewFOVY,
                       float viewTheta,
                       float viewX, float viewY, float viewZ) {

        final BilinearCoeffs bilinear = new BilinearCoeffs();

        // How far we can see
        final int MARCH_STEPS = 200;
        final float marchDistance = 1.0f;
        
        // pixels / meter of elevation map.
        // Does not affect depth
        final float SCALE = 5.0f;

        // Increase to slant more down
        float tilt = 5;

        // Camera space depth of the near plane
        float nearPlane = 1.0f;

        // Iterate over every screen column
        for (int sx = 0; sx < screenWidth; ++sx) {

            // Ray angle (initially in camera space)
            float theta = (viewFOVX * sx / (screenWidth - 1.0f)) - (viewFOVX / 2.0f);
            
            // Camera space depth increase per march step; falls off away from center
            float marchDepth = (float)Math.cos(theta);
            
            // Take view angle to world space
            theta += viewTheta;

            // World-space coordinates of the ray
            float marchX = SCALE * (float)Math.cos(theta);
            float marchZ = SCALE * (float)Math.sin(theta);

            // Camera space z (used for perspective foreshortening)
            float depth = nearPlane;

            float x = SCALE * viewX + marchX * nearPlane / marchDepth;
            float z = SCALE * viewZ + marchZ * nearPlane / marchDepth;
            
            // Largest y value previously rendered; do not render higher than this
            int y1 = screenHeight;

            for (int m = 0; m < MARCH_STEPS; ++m) {
                // We're looking at a cylinder of world-space height y
                getBilinearCoeffs(x, z, bilinear);
                float y = bilinear.interpolate(elevationArray);

                // Perspective projection and conversion to screen space
                float projY = (y - viewY + m * tilt * marchDepth) / depth;

                // Don't have to clip against the bottom of the screen since y1 begins
                // there.
                int y0 = Math.max(0, screenHeight - 1 - (int)projY);
                
                if (y0 < y1) {
                    float fog = Math.min((depth - nearPlane) * 0.2f, 1.0f);

                    // This elevation is visible.  Render the vertical line segment.
                    int c = bilinear.colorInterpolate(colorArray, fog);

                    // TODO: fog the c value here

                    // Draw a vertical stripe

                    // TODO: bilinear between elevations

                    // Dest index
                    int j = sx + y0 * screenWidth;
                    for (int sy = y0; sy < y1; ++sy) {
                        screen[j] = c;
                        j += screenWidth;
                    }
                    
                    // Update the new farthest depth
                    y1 = y0;
                }

                // Increase step size with distance
                float step = depth * 0.015f;
                x += marchX * step; 
                z += marchZ * step;
                depth += marchDepth * step;
            }
        }
    }
}
