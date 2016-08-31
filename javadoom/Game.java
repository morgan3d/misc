import javax.swing.*;
import java.awt.event.*;
import java.awt.*;
import java.io.File;
import java.awt.image.BufferedImage;

/**
   Reusable base class for game-like applications.
   Runs an animation loop for real-time graphics.
   Provides additional graphics utility functions.

   <p>Morgan McGuire
   <br>morgan@cs.williams.edu
   <br>http://graphics.cs.williams.edu
*/
public abstract class Game extends JFrame {
    
    protected View      view;
    protected StopWatch fpsTimer      = new StopWatch();

    protected JCheckBox renderBox     = new JCheckBox("Enable rendering");
    protected JLabel    fpsDisplayBox = new JLabel("");
    protected JPanel    controlPane   = new JPanel();

    private   boolean   simulationEnabled;
    private   float     desiredFPS;

    // Simulation controls
    private JToggleButton play  = makeToggleToolButton("Play24.gif");
    private JToggleButton pause = makeToggleToolButton("Pause24.gif");
    private JButton       step  = makeToolButton("StepForward24.gif");
        
    private KeyInput keyInput;

    /** @param w Width of the view window
        @param h Height of the view window
        @param scale Enlarge/shrink the view window by this factor when displaying it.
        @param fps Desired frame rate (may not be achievable) */
    public Game(int w, int h, float scale, float fps) {
        super("Game");
        view = new View(w, h, scale);
        desiredFPS = fps;
        
        setSimulationEnabled(true);
        renderBox.setSelected(true);
        
        makeGUI();
        makeKeyListener();

        setSize(200 + view.getWidth(), Math.max(view.getHeight(), 400));
        // setResizable(false);
        setVisible(true);
    }


    private void makeKeyListener() {
        keyInput = new KeyInput();
        view.addKeyListener(keyInput);
    }

    /** Returns true if KeyEvent key code k was held down for any time during the
        previous frame. */
    public boolean keyDown(int k) {
        return keyInput.wasDown(k);
    }

    /** Returns true if KeyEvent key code k was pressed at least once during the
        previous frame. */
    public boolean keyPressed(int k) {
        return keyInput.wasPressed(k);
    }

    private void makeGUI() {
        // Add the view to the screen
        Container pane = getContentPane();
        pane.setLayout(new BoxLayout(pane, BoxLayout.LINE_AXIS));

        controlPane.setLayout(new BoxLayout(controlPane, BoxLayout.PAGE_AXIS));

        makeSimulationControls();

        // Rendering control
        JButton refresh = new JButton(new ImageIcon("Refresh16.gif"));
        refresh.setSize(16, 16);
        refresh.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    renderBox.setSelected(false);
                    onGraphics();
                    repaint();
                }});
        addControl(makeJPanel(renderBox, refresh));

        addControl(new JLabel("Desired: " + (int)Math.round(desiredFPS) + " fps"));
        addControl(makeJPanel(new JLabel("Actual:"), fpsDisplayBox));

        view.setBorder(BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
        pane.add(view);
        pane.add(controlPane);
    }

    private void makeSimulationControls() {
        play.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    setSimulationEnabled(true);
                }});

        pause.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    setSimulationEnabled(false);
                }});

        step.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    setSimulationEnabled(false);
                    onSimulation();
                }});

        addControl(makeJPanel(play, pause, step));
    }

    protected void addControl(JComponent c) {
        c.setAlignmentX(Component.LEFT_ALIGNMENT);
        controlPane.add(c);
    }

    public boolean isSimulationEnabled() {
        return simulationEnabled;
    }

    public void setSimulationEnabled(boolean s) {
        simulationEnabled = s;
        play.setSelected(s);
        pause.setSelected(! s);
    }
    
    /** Creates a JPanel containing both components in a flow-layout.*/
    static protected JPanel makeJPanel(JComponent c0, JComponent c1) {
        JPanel pane = new JPanel();
        pane.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 5));
        pane.add(c0);
        pane.add(c1);
        return pane;
    }

    static protected JPanel makeJPanel(JComponent c0, JComponent c1, JComponent c2) {
        JPanel pane = makeJPanel(c0, c1);
        pane.add(c2);
        return pane;
    }

    static protected JToggleButton makeToggleToolButton(String icon) {
        JToggleButton b = new JToggleButton(new ImageIcon(icon));
        b.setSize(24, 24);
        return b;
    }

    static protected JButton makeToolButton(String icon) {
        JButton b = new JButton(new ImageIcon(icon));
        b.setSize(24, 24);
        return b;
    }

    /** Call to launch the game */
    public void start() {
        // Render the first frame
        onGraphics();
        repaint();

        // Start the timer for subsequent frames
        new java.util.Timer().schedule(new java.util.TimerTask() {
                public void run() {
                    keyInput.frameStart();

                    if (isSimulationEnabled()) {
                        onSimulation();
                    }

                    if (renderBox.isSelected()) {
                        onGraphics();

                        // Update the view
                        //repaint(view.getBounds());
                        
                        // TODO: Make it so that we don't have to repaint the whole screen
                        repaint();

                        fpsTimer.tick();
                    } else {
                        fpsTimer.reset();
                    }

                    if (fpsTimer.isValid()) {
                        fpsDisplayBox.setText("" + (int)Math.round(fpsTimer.getFPS()) + " fps");
                    } else {
                        fpsDisplayBox.setText("--");
                    }
                }}, 0, (int)(1000 / desiredFPS));
    }

    /** Repaint this region of the frame */
    public void repaint(Rectangle r) {
        repaint(r.x, r.y, r.width, r.height);
    }

    /** Process one frame of animation.  Override in subclass.
        Automatically forces a repaint of the view.*/
    synchronized protected void onGraphics() { }
    
    synchronized protected void onSimulation() { }

    /** Paint must be synchronized to ensure that it does not execute
        during oneFrame, which would cause flickering. */
    synchronized public void paint(Graphics g) {
        super.paint(g);
    }

    public static Image loadImage(String file) {
        return loadImage(new File(file));
    }

    public static Image loadImage(File file) {
        try {
            // Faster on some old macs:
            // return Toolkit.getDefaultToolkit().getImage(file.getPath());

            return javax.imageio.ImageIO.read(file);        
        } catch (java.io.IOException e) {
            System.err.println(e);
            return null;
        }
    }

    /** Draws a solid filled, dove-tailed arrow head of the given size
        at the specified position, using the current color.*/
    static public void drawArrowHead(Graphics2D g, float posx, float posy,
                                     float heading, float scale) {
        Vector2 U = new Vector2(scale * (float)Math.cos(heading), 
                                scale * (float)Math.sin(heading));
        Vector2 V = new Vector2();
        Vector2.perp(U, V);

        int[] x = {(int)(posx + U.x), (int)(posx - U.x + V.x), (int)posx, (int)(posx - U.x - V.x)};
        int[] y = {(int)(posy + U.y), (int)(posy - U.y + V.y), (int)posy, (int)(posy - U.y - V.y)};
        
        g.fillPolygon(x, y, x.length);
    }


    /** Times the frame rate of an animation. Times over several
        frames to smooth results and allow high precision. */
    public static class StopWatch {
        /** frameCount resets to this when it hits zero. */
        private static final int TIMING_FRAMES = 10;

        /** Milliseconds at which timing began. */
        private long   timingStart;

        /** Number of frames until next timing. */
        private int    frameCount;
        private float  timedFPS;
     
        public StopWatch() {
            reset();
        }

        public void reset() {
            frameCount = 0;
            timedFPS = Float.NaN;
        }

        /** Returns true if enough samples have been taken to display an FPS count. */
        public boolean isValid() {
            return ! Float.isNaN(timedFPS);
        }

        /** Recorded fps over several frames.*/
        public float getFPS() {
            return timedFPS;
        }

        /** Returns the number of seconds per frame on average.*/
        public float getFrameTime() {
            return 1.0f / timedFPS;
        }

        /** Call once per frame. */
        public void tick() {
            --frameCount;
            if (frameCount == -1) {
                // First time; start the timer
                frameCount = TIMING_FRAMES;
                timingStart = System.currentTimeMillis();
            } else if (frameCount == 0) {
                frameCount = TIMING_FRAMES;
                long now = System.currentTimeMillis();
                
                timedFPS = (float)TIMING_FRAMES * 1000.0f / (now - timingStart);
                timingStart = now;
            }
        }
    }

    public static class View extends JPanel {
        private BufferedImage buffer;
        private Graphics2D    graphics;

        /** Creates a w x h buffer and sizes the view to display 1 pixel as s x s on-screen pixels.
            Change the size of the View to stretch the underlying image.
        */
        public View(int w, int h, float s) {
            buffer = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
            graphics = buffer.createGraphics();

            Dimension dim = new Dimension((int)(w * s), (int)(h * s));
            setSize(dim);
            setPreferredSize(dim);
            setMaximumSize(dim);
            setMinimumSize(dim);

            setOpaque(true);

            // We're already double-buffering, so avoid the overhead
            // of a Swing double buffer; on most systems there should 
            // still not be any flickering.
            setDoubleBuffered(false);

            // Listen for tab and alt keys
            setFocusTraversalKeysEnabled(false);

            // The view can receive focus when clicked
            addMouseListener(new MouseAdapter() {
                    public void mouseClicked(MouseEvent e) {
                        View.this.requestFocusInWindow();
                }});
        }

        /** Receive focus for keyboard */
        public boolean isFocusable() {
            return true;
        }

        /** Creates 1:1 rendered view. */
        public View(int w, int h) {
            this(w, h, 1);
        }

        /** Returns the Graphics2D for rendering to this view. After
          drawing, call repaint() to force Java to update the on-screen
          image.*/
        public Graphics2D getGraphics() {
            return graphics;
        }

        /** Returns the underlying */
        public int getBufferWidth() {
            return buffer.getWidth();
        }

        public int getBufferHeight() {
            return buffer.getHeight();
        }

        synchronized public void paintComponent(Graphics _g) {
            Graphics2D g = (Graphics2D)_g;
            g.drawImage(buffer, 
                        0, 0, getWidth(), getHeight(), 
                        0, 0, buffer.getWidth(), buffer.getHeight(), 
                        null);
        }
    }


    /** Manages per-frame polling of keyboard input from a View. */
    private static class KeyInput implements KeyListener {
        /** True if a key is currently held down. */
        private boolean[] currentlyDown     = new boolean[KeyEvent.KEY_LAST];

        /** True if a key was ever held down during the frame. */
        private boolean[] everDown          = new boolean[KeyEvent.KEY_LAST];

        /** True if a key was pressed this frame. */
        private boolean[] pressed           = new boolean[KeyEvent.KEY_LAST];

        public void keyPressed(KeyEvent e) {
            currentlyDown[e.getKeyCode()] = true;
            everDown[e.getKeyCode()]      = true;
            pressed[e.getKeyCode()]       = true;
        }
            
        public void keyReleased(KeyEvent e) {
            currentlyDown[e.getKeyCode()] = false;
        } 

        public void keyTyped(KeyEvent e) {}
        
        /** Returns true if key @a k was down for any period of time
            since frameStart was called.

            @param k A KeyEvent key code */
        public boolean wasDown(int k) {
            assert k >= KeyEvent.KEY_FIRST && k <= KeyEvent.KEY_LAST : "Illegal key code: " + k;
            return everDown[k];
        }

        public boolean wasPressed(int k) {
            assert k >= KeyEvent.KEY_FIRST && k <= KeyEvent.KEY_LAST : "Illegal key code: " + k;
            return pressed[k];
        }

        /** Call once per frame to wipe the state of the pressed array.*/
        public void frameStart() {
            System.arraycopy(currentlyDown, 0, everDown, 0, everDown.length);
            java.util.Arrays.fill(pressed, false);
        }
    }
}
