import java.awt.*;

/** 
    Provides high precision (floating point) rendering on a Java Graphics2D.
    
    <p>Morgan McGuire
    <br>morgan@cs.williams.edu
 */
public class Renderer {

    /** Multiplies numbers by this before rounding to int to allow
        scales that. */
    private static final float PRECISION = 256.0f;

    private Graphics2D graphics;
    private int width;
    private int height;

    public Renderer(Graphics2D g, int w, int h) {
        graphics = g;
        width    = w;
        height   = h;
        
        // Put the origin in the center of the screen
        graphics.translate(w / 2.0, h / 2.0);

        // Flip the y-axis and set precision
        graphics.scale(1.0 / PRECISION, -1.0 / PRECISION);
    }

    public void setColor(Color c) {
        graphics.setColor(c);
    }

    public void clear() {
        graphics.fillRect(0, 0, w, h);
    }

    public void drawLine(float x0, float x1, float y0, float y1) {
        graphics.drawLine((int)(x0 * PRECISION), (int)(y0 * PRECISION), 
                          (int)(x1 * PRECISION), (int)(y1 * PRECISION));
    }
}
