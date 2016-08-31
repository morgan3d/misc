public class Intersection {
    /** Distance along the ray */
    public float distance;
    
    /** Fraction of distance between vertex[0] and vertex[1] of
        the intersection */
    public float u;
    
    /** Wall that was intersected.*/
    public Wall wall;
    
    /** Reset to no intersection */
    public void reset() {
        distance = Float.POSITIVE_INFINITY;
        u = 0;
        wall = null;
    }
    
    /** True if a surface was hit */
    public boolean isValid() {
        return wall != null;
    }
}
