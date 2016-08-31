import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.awt.image.BufferedImage;

public class Screen extends JFrame {
    
    /** Underlying array for framebuffer */
    protected int[] screen;
    protected BufferedImage framebuffer;

    private final int WIDTH  = 512;
    private final int HEIGHT = 256;

    float viewFOVX = (float)Math.toRadians(60);
    float viewFOVY = viewFOVX * HEIGHT / WIDTH;
    float viewX = 32;
    float viewY = 128;
    float viewZ = 32;
    float viewTheta = (float)Math.toRadians(90);


    private Terrain terrain = new Terrain();

    public Screen() {
        super("3D");

        framebuffer = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        screen = new int[WIDTH * HEIGHT];

        renderScene();
        setSize(WIDTH * 2, HEIGHT * 2);
        setResizable(false);

        /*
        int fps = 30;
        new java.util.Timer().schedule(new java.util.TimerTask() {
                public void run() {
                    oneFrame();
                }}, 0, (int)(1000 / fps));
        */
        renderScene();
    }

    /** Process one frame of animation */
    protected void oneFrame() {
        move(0.3f);
        renderScene();
        repaint();
    }

    private void move(float distance) {
        viewX += (float)Math.cos(viewTheta) * distance;
        viewZ += (float)Math.sin(viewTheta) * distance;
    }

    /** Called from oneFrame */
    private void renderScene() {
        // Clear screen to white
        java.util.Arrays.fill(screen, 0xFFFFFFFF);

        // terrain.render(screen, WIDTH, HEIGHT, viewFOVX, viewFOVY, viewTheta, viewX, viewY, viewZ);
        
        ScreenVertex[] tri = {new ScreenVertex(100,  50, 0.5f, 0.0f),
                              new ScreenVertex( 50, 100, 0.0f, 0.5f), 
                              new ScreenVertex(150, 150, 1.0f, 1.0f),
                              new ScreenVertex()};

        Rasterizer.renderTri(screen, WIDTH, tri, 0xFFFF0000);

        framebuffer.setRGB(0, 0, WIDTH, HEIGHT, screen, 0, WIDTH);
    }
    
    public void paint(Graphics _g) {
        Graphics2D g = (Graphics2D)_g;
        g.drawImage(framebuffer, 
                    0, 0, getWidth(), getHeight(), 
                    0, 0, framebuffer.getWidth(), framebuffer.getHeight(), 
                    null);
    }

    static BufferedImage loadImage(String file) {
        return loadImage(new File(file));
    }

    static BufferedImage loadImage(File file) {
        try {
            return javax.imageio.ImageIO.read(file);        
        } catch (java.io.IOException e) {
            System.err.println(e);
            return null;
        }
    }
}
