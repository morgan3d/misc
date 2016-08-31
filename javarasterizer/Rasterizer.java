public class Rasterizer {
    
    /** All delta integer coords are shifted by this amount to
     * increase precision (fixed point) */
    static private final int SHIFT = 16;

    final static private void swap(ScreenVertex[] v, int i0, int i1) {
        ScreenVertex temp = v[i0]; v[i0] = v[i1]; v[i1] = temp;
    }

    /** Arranges the first three vertices in order of increasing y using bubble sort.*/
    static private void ySort(ScreenVertex[] v) {
        if (v[1].y < v[0].y) swap(v, 0, 1);
        if (v[2].y < v[1].y) swap(v, 1, 2);
        if (v[1].y < v[0].y) swap(v, 0, 1);

        assert v[0].y < v[1].y;
        assert v[1].y < v[2].y;
    }

    /** Arranges the first three vertices in order of increasing x using bubble sort.*/
    static private void xSort(ScreenVertex[] v) {
        if (v[1].x < v[0].x) swap(v, 0, 1);
        if (v[2].x < v[1].x) swap(v, 1, 2);
        if (v[1].x < v[0].x) swap(v, 0, 1);
    }

    /** @param v in screen coordinates.  Contains 4 elements; the 4th is used as scratch space */
    static public void renderTri(int[] screen, int screenWidth, ScreenVertex[] v, int color) {
        assert v != null;
        assert screen != null;

        // Break into upper tri and lower tri
        ySort(v);

        if (v[0].y == v[1].y) {
            if (v[1].y == v[2].y) {
                // The triangle is a horizontal line
                xSort(v);
                fillLine(v[0].x, v[1].x, v[0].y, color, screen, screenWidth);
            } else {
                // There is no upper triangle.
                
                // Ensure that v[0] is on the left
                if (v[0].x > v[1].x) swap(v, 0, 1);
                
                renderLower(v[0].x, v[2].x, v[1].x, v[0].y, v[2].y, color, screen, screenWidth);
            }

        } else {

             // Ensure that v[1] is on the left
            if (v[1].x > v[2].x) swap(v, 1, 2);

            if (v[1].y == v[2].y) {
                // There is no lower triangle
                renderUpper(v[1].x, v[0].x, v[2].x, v[0].y, v[1].y, color, screen, screenWidth);
            } else {

                // Determine triangle facing direction
                if (v[1].y > v[2].y) {
                    // Triangle points right   |>
                    int yMid = v[2].y;

                    // Interpolate to find the intersection of the mid-line with the left side
                    int xLeft = v[0].x + (v[1].x - v[0].x) * (yMid - v[0].y) / (v[1].y - v[0].y);

                    renderUpper(xLeft, v[0].x, v[2].x, v[0].y, yMid, color, screen, screenWidth);
                    renderLower(xLeft, v[1].x, v[2].x, yMid, v[1].y, color, screen, screenWidth);

                } else {
                    // Triangle points left   <|
                    int yMid = v[1].y;
                    // Interpolate to find the intersection of the mid-line with the left side
                    int xRight = v[0].x + (v[2].x - v[0].x) * (yMid - v[0].y) / (v[2].y - v[0].y);

                    renderUpper(v[1].x, v[0].x, xRight, v[0].y, yMid, color, screen, screenWidth);
                    renderLower(v[1].x, v[2].x, xRight, yMid, v[2].y, color, screen, screenWidth);
                }
                
            }
        }
    }

    
    /**    xL   xT   xR
                /\            y0
               /  \
              /____\          y1
     */
    static private void renderUpper(int xL, int xT, int xR, int y0, int y1, int color, int[] screen, int screenWidth) {
        assert y0 < y1;
        assert xL <= xR;

        int dy = y1 - y0;
        int dxA = ((xL - xT) << SHIFT) / dy;
        int dxB = ((xR - xT) << SHIFT) / dy;

        for (int y = y0; y <= y1; ++y) {
            int d = y - y0;

            // Both of these start at xT and move towards xL or xR
            int xA = xT + ((dxA * d) >> SHIFT);
            int xB = xT + ((dxB * d) >> SHIFT);

            fillLine(xA, xB, y, color, screen, screenWidth);
        }
    }

    /**
       xL = xLeft
       xT = xTip
       xR = xRight

            xL   xT   xR
              \----/        y0
               \  / 
                \/          y1
     */
    static private void renderLower(int xL, int xT, int xR, int y0, int y1, int color, int[] screen, int screenWidth) {
        assert y0 < y1;

        int dy  = y1 - y0;
        int dxA = ((xL - xT) << SHIFT) / dy;
        int dxB = ((xR - xT) << SHIFT) / dy;

        for (int y = y1; y >= y0; --y) {
            int d = y1 - y;

            // Both of these start at xT and move towards xL or xR
            int xA = xT + ((dxA * d) >> SHIFT);
            int xB = xT + ((dxB * d) >> SHIFT);
            fillLine(xA, xB, y, color, screen, screenWidth);
        }
    }

    /** Draws a solid horizontal line */
    static final private void fillLine(int x0, int x1, int y, int color, int[] screen, int screenWidth) {
        assert x0 <= x1 : "x0 = " + x0 + ", x1 = " + x1;
        assert x0 >= 0;
        assert x1 < screenWidth;

        int offset = y * screenWidth;
        int i0 = x0 + offset;
        int i1 = x1 + offset;

        java.util.Arrays.fill(screen, i0, i1 + 1, color);
    }
}
