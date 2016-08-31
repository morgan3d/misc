import java.util.ArrayList;
import java.util.Vector;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.geom.AffineTransform;

public class World {

    ArrayList<Wall> wallArray = new ArrayList<Wall>();

    /** Only used for debugging.*/
    Vector<Intersection> intersectionArray = new Vector<Intersection>();
    Vector<Ray>          rayArray          = new Vector<Ray>();
    
    public World() {
        Image tex = Game.loadImage("sonya.jpg");
        wallArray.add(new Wall(new Vector2(-2, 4), new Vector2(2, 4), 4, tex));
        wallArray.add(new Wall(new Vector2( 2, 4), new Vector2(5, 3), 4, tex));

        for (int i = 0; i < 100; ++i) {
            wallArray.add(new Wall(new Vector2(-6, 4 + i), new Vector2(-2, 4 + i), 4, tex));
        }
    }

    /** Draw first-person view of the world 
        @param w, h width and height of the viewport
     */
    public void render(Camera camera, Graphics2D graphics, int w, int h) {
        graphics.setColor(Color.BLACK);
        graphics.fillRect(0, 0, w, h);

        renderWalls(camera, graphics, w, h);
    }

    /** Get the first intersection of this ray with any wall. Resets
        the intersection before searching.*/
    private void getFirstIntersection(Ray ray, Intersection intersection) {
        intersection.reset();
        for (Wall wall : wallArray) {
            wall.getFirstIntersection(ray, intersection);
        }
    }


    /** Draw a top view of the world. 
        @param w, h width and height of the viewport
     */
    public void renderMap(Camera camera, Graphics2D graphics, int w, int h) {
        AffineTransform oldTransform = graphics.getTransform();
        
        graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        float pixelsPerMeter = 5;

        // (Note that transformations occur in reverse order)
        // Put the origin at the center of the screen
        graphics.translate(w / 2, h / 2);
        
        // Scale flip the y axis
        graphics.scale(1, -1);

        // Camera position after map scaling
        Vector2 scaledPos = new Vector2();
        Vector2.mul(camera.getPosition(), pixelsPerMeter, scaledPos);
        
        if (intersectionArray.size() == w) {
            renderRays(graphics, scaledPos, w, pixelsPerMeter);
        }

        // Render walls
        for (Wall wall : wallArray) {
            wall.renderMap(graphics, pixelsPerMeter);
        }

        // Render Camera
        graphics.setColor(Color.RED);
        Game.drawArrowHead(graphics, scaledPos.x, scaledPos.y, camera.getHeading(), 5);

        // Restore graphics state
        graphics.setTransform(oldTransform);
        graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF);
    }


    /** Draw view rays to intersections for debugging purposes. Called from renderMap.*/
    private void renderRays(Graphics2D graphics, Vector2 scaledPos, int w, float pixelsPerMeter) {
        graphics.setColor(Color.YELLOW);
        float LARGE = 100;
        Vector2 dest = new Vector2();

        int x0 = 0, x1 = w - 1;

        if (Debug.getOneRay()) {
            // Cast only one ray in the center
            x0 = x1 = w / 2;
        }
        for (int x = x0; x <= x1; ++x) {
            Intersection i = intersectionArray.get(x);
            Ray r = rayArray.get(x);
            
            // How far should this line be drawn?
            float distance = (i != null) ? i.distance : LARGE;
            
            // dest = (r.origin + r.direction * distance) * pixelsPerMeter
            Vector2.mul(r.direction, distance, dest);
            dest.add(r.origin);
            dest.mul(pixelsPerMeter);
            
            graphics.drawLine((int)scaledPos.x, (int)scaledPos.y, (int)dest.x, (int)dest.y);
        }
    }


    private void renderWalls(Camera camera, Graphics2D graphics, int w, int h) {

        Intersection intersection = new Intersection();
        Ray ray = new Ray();

        int x0 = 0, x1 = w - 1;

        if (Debug.getOneRay()) {
            // Cast only one ray in the center
            x0 = x1 = w / 2;
        }

        boolean storeIntersections = Debug.getShowRays() && Debug.getShowMap();
        intersectionArray.setSize(0);
        rayArray.setSize(0);
        if (storeIntersections) {
            intersectionArray.setSize(w);
            rayArray.setSize(w);
        }

        for (int x = x0; x <= x1; ++x) {            
            float s = camera.computeRay(x, w, ray);

            getFirstIntersection(ray, intersection);

            if (intersection.isValid()) {
                float scale = 1.0f / (intersection.distance * s);
                intersection.wall.drawStrip(graphics, x, h, intersection.u, scale);
            }

            if (storeIntersections) {
                // For debugging purposes, keep the valid intersections
                if (intersection.isValid()) {
                    intersectionArray.set(x, intersection);
                    intersection = new Intersection();
                }
                rayArray.set(x, ray);
                ray = new Ray();
            }
        }

    }

}
