import javax.swing.*;
import java.awt.*;
import java.awt.event.KeyEvent;

/**
   Ray-casting 3D engine.

   Must run with "java -Dapple.awt.graphics.UseQuartz=true Doom" on OS X 10.5 (Leopard)
   to avoid the slow Sun2D awt implementation.

   <p>Morgan McGuire
   <br>morgan@cs.williams.edu
   <br>http://graphics.cs.williams.edu
*/
public class Doom extends Game {
    
    protected Camera   camera   = new Camera();
    protected World    world    = new World();
    
    public Doom() {
        super(300, 190, 2, 30);
        Debug.createControls(this);
    }

    /** Update game state */
    synchronized protected void onSimulation() {
        float walkSpeed = 0.3f;
        float turnSpeed = (float)Math.toRadians(3.5f);

        if (keyDown(KeyEvent.VK_W)) {
            camera.move(walkSpeed);
        } else if (keyDown(KeyEvent.VK_S)) {
            camera.move(-walkSpeed / 2);
        }

        if (keyDown(KeyEvent.VK_A)) {
            if (keyDown(KeyEvent.VK_SHIFT)) {
                camera.strafe(walkSpeed);
            } else {
                camera.turn(turnSpeed);
            }
        }
        if (keyDown(KeyEvent.VK_D)) {
            if (keyDown(KeyEvent.VK_SHIFT)) {
                camera.strafe(-walkSpeed);
            } else {
                camera.turn(-turnSpeed);
            }
        }

        //camera.setHeading((float)(camera.getHeading() + Math.toRadians(2)));
    }

    /** Render the world */
    synchronized protected void onGraphics() {
        assert view != null;
        assert camera != null;
        assert world != null;

        Graphics2D graphics = view.getGraphics();
        int w = view.getBufferWidth();
        int h = view.getBufferHeight();

        world.render(camera, graphics, w, h);

        if (Debug.getShowMap()) {
            world.renderMap(camera, graphics, w, h);
        }
    }

    static public void main(String[] arg) {
        new Doom().start();
    }
}
