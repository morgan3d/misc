import java.awt.image.BufferedImage;
import java.awt.*;

/** One-sided 3D rectangle perpendicular to the floor. */
public class Wall {
    /** Acceptable roundoff error in computations */
    private static final float EPSILON = 0.00001f;

    private final Vector2    v0 = new Vector2();

    private final Vector2    v1 = new Vector2();

    /** (v1 - v0) / |v1 - v0|^2 */
    private final Vector2    direction = new Vector2();

    /** Unit length vector that points out of the front of the
        wall. */
    private final Vector2    normal = new Vector2();   

    private float            height;
    private Image            image;

    /** Vertices are not cloned. */
    public Wall(Vector2 v0, Vector2 v1, float h, Image im) {
        this.v0.set(v0);
        this.v1.set(v1);

        height    = h;
        image     = im;

        Vector2.sub(v1, v0, direction);
        direction.div(direction.getSquaredLength());

        Vector2.perp(direction, normal);
        normal.unitize();
    }

    /** Draws a vertical strip of texture.
        @param scale The relative size of the strip
        @param h Viewport height
     */
    public void drawStrip(Graphics2D graphics, int x, int h, float u, float scale) {
        int stripHeight = (int)(scale * h * height);

        int dy0 = (h - stripHeight) / 2;
        int dy1 = (h + stripHeight) / 2;

        // TODO: handle walls with tiling texture
        int sx = Math.min((int)(u * image.getWidth(null)), image.getWidth(null) - 1);

        graphics.drawImage(image, x, dy0, x + 1, dy1,
                           sx, 0, sx + 1, image.getHeight(null), 
                           null);

        // Drawing horizontally improves speed by about 30%, probably because of cache coherence
        /*
        graphics.drawImage(image, dy0, x, dy1, x + 1,
                           0, sx, image.getWidth(), sx + 1,
                           null);
        */
    }

    /** Draw on the map */
    public void renderMap(Graphics2D g, float scale) {
        g.setColor(Color.WHITE);
        g.drawLine((int)(v0.x * scale), (int)(v0.y * scale), (int)(v1.x * scale), (int)(v1.y * scale));
    }


    /**  If there is an intersection between this ray and the wall
        <b>and</b> it is closer than the current intersection
        returns that in @a intersection.*/
    public void getFirstIntersection(Ray ray, Intersection intersection) {
        // Rate at which the ray approaches the wall line
        float rate = -ray.direction.dot(normal);

        if (Math.abs(rate) <= EPSILON) {
            // The ray is parallel to the wall
            return;
        }

        // Perpendicular separation distance between ray origin and wall:
        // (origin - v0).dot(normal)
        float sep = (ray.origin.x - v0.x) * normal.x + 
                    (ray.origin.y - v0.y) * normal.y;
        
        // Distance to travel along the ray to the intersection
        float distance = sep / rate;

        if ((distance < 0) || (distance >= intersection.distance)) {
            // This ray does not hit the line before the previously
            // discovered intersection
            return;
        }
        
        // See if the intersection point is within the line segment
        //
        //   point = ray.origin + ray.direction * distance
        //   u = (point - v0).dot(direction)
        float u = 
            (ray.origin.x + ray.direction.x * distance - v0.x) * direction.x +
            (ray.origin.y + ray.direction.y * distance - v0.y) * direction.y;

        if ((u < 0) || (u > 1)) {
            // Intersection is outside this line segment
            return;
        }

        // Intersection found!
        intersection.u = u;
        intersection.distance = distance;
        intersection.wall = this;
    }
}
