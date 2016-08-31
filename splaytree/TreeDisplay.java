/**
 @file TreeDisplay.java
 @author Morgan McGuire, morgan@cs.brown.edu
 @created 2002-09-15
 @edited  2002-09-16
 */

import javax.swing.*;
import java.awt.*;
import javax.swing.event.*;
import java.awt.event.*;
import java.util.*;

/**
 Renders ordered binary trees with nice colors and 3D shading.
 */
class TreeDisplay extends JPanel {

    /** Back pointer to the demo so this class can find the tree root */
    SplayDemo        demo     = null;

    /** Used for tracking node positions when handling mouse events. */
    class Position {
        Node n;
        int  x;
        int  y;
        Position(Node n, int x, int y) {
            this.n = n;
            this.x = x;
            this.y = y;
        }
    }
    Vector           position  = new Vector();

    /** Radius of nodes when rendered */
    final static int radius    = 20;
    
    /** Vertical spacing when rendered */
    final static int ySpacing  = 55;
    
    BinaryTree tree = null;
    String caption = "";

    public TreeDisplay(SplayDemo demo, BinaryTree tree, String caption) {
        this.caption = caption;
        this.tree = tree;
        this.demo = demo;
        setBackground(java.awt.Color.white);
        int width  = 500;
        int height = 400;
        setSize(width, height);
        Dimension dim = new Dimension(width, height);
        setPreferredSize(dim);
        setMinimumSize(dim);
        setMaximumSize(dim);
        enableEvents(java.awt.AWTEvent.MOUSE_EVENT_MASK);
    }

    protected void processMouseEvent(MouseEvent e) {
        switch (e.getID()) {
        case MouseEvent.MOUSE_PRESSED:
            // Find the node
            Node node = null;
            for (int n = 0; n < position.size(); ++n) {
                Position pos = (Position)position.get(n);
                if (Math.sqrt(Math.pow(pos.x - e.getX(), 2) +
                              Math.pow(pos.y - e.getY(), 2)) <= radius) {
                    node = pos.n;
                    break;
                }
            }
            
            if (node != null) {
                demo.leftMouse(node.key, this);
            } else {
                demo.leftMouse(-1, this);
            }
            
            break;
        }
    }

    synchronized public void paintComponent(Graphics r) {
        super.paintComponent(r);
        // Java promises to call this method with a Graphics2D
        Graphics2D g = (Graphics2D)r;
        Rectangle bounds = getBounds();

        Node node = tree.getRoot();

        // Enable anti-aliasing
        g.setRenderingHints(
          new RenderingHints(
             RenderingHints.KEY_ANTIALIASING,
             RenderingHints.VALUE_ANTIALIAS_ON));

        g.setFont(new Font("Arial", Font.BOLD, 30));
        g.setColor(java.awt.Color.black);
        g.drawString(caption, 5, bounds.height - 10);
        g.drawRect(0, 0, bounds.width - 1, bounds.height - 1);

        g.setFont(new Font("Arial", Font.BOLD, 16));

        position.clear();
        drawShadows(g, node, 250, 25, 100);
        if (node != null) {
            draw(g, node, 250, 25, 100);
        }
    }


    private void drawShadows(Graphics2D g, Node n, int x, int y, int width) {
        if (n != null) {
            final int nextY = y + ySpacing - width / 3;

            g.setColor(new java.awt.Color(.85f, .85f, .85f));
            g.fillOval(x - radius + 15, y - radius + 15, 
                       (int)(1.8 * radius), (int)(1.8 * radius));

            drawShadows(g, n.left,  x - width, nextY, width / 2);
            drawShadows(g, n.right, x + width, nextY, width / 2);
        }
    }


    /** Computes a color hashed on k, where a = bright and b = dark. */
    static private Color computeColor(int k, float a, float b) {
        // Get an integer between 1 and 6
        int j = (k % 6) + 1;

        // Enumerate through primary colors, avoiding white and black.

        // Extract the 0, 1, and 2 bits
        boolean b0 = (j & 1) == 1;
        boolean b1 = (j & 2) == 2;
        boolean b2 = (j & 4) == 4;
       
        return new java.awt.Color(b0 ? a : b, 
                                  b1 ? a : b,
                                  b2 ? a : b);
    }


    private void draw(Graphics2D g, Node n, int x, int y, int width) {
        position.add(new Position(n, x, y));

        final int nextY = y + ySpacing - width / 3;

        g.setColor(java.awt.Color.black);
        if (n.left != null) {
            g.setColor(java.awt.Color.black);
            g.drawLine(x, y, x - width, nextY);
            draw(g, n.left,  x - width, nextY, width / 2);
        }

        if (n.right != null) {
            g.setColor(java.awt.Color.black);
            g.drawLine(x, y, x + width, nextY);
            draw(g, n.right, x + width, nextY, width / 2);
        }
        

        // Draw a 3D shaded sphere for the node
        for (int i = radius; i >= 0; --i) {
            float d = 
                (float)Math.cos((Math.PI / 2) * 
                                (i / (double)radius)) * .75f + 0.25f;

            g.setColor(computeColor(n.key, d, 0.0f));

            g.fillOval(x - radius + (radius - i) / 4 + 1,
                       y - radius + (radius - i) / 4 + 1,
                       radius + i,  radius + i);
        }

        // Specular highlight
        for (int i = radius; i >= 0; --i) {
            g.setColor(computeColor(n.key, 1.0f, 
                     Math.min(1.0f, 1.5f * (1.0f - (float)i / radius))));

            g.fillOval(x - radius / 3 + 1 - i/2,
                       y - radius / 3 + 1 - i/2,
                       i,  i);
        }

        // Circle around node
        g.setColor(java.awt.Color.black);

        int dx2 = 0;
        if (n.key > 9) {
            dx2 = -5;
        }

        // Black outline around text
        g.drawOval(x - radius, y - radius, 2 * radius, 2 * radius);
        for (int dx = -1; dx <= 1; ++dx) {
            for (int dy = -1; dy <= 1; ++dy) {
                g.drawString("" + n.key, x - 5 + dx + dx2, y + 5 + dy);
            }
        }
        
        // Text
        g.setColor(java.awt.Color.white);
        g.drawString("" + n.key, x - 5 + dx2, y + 5);
    }
}
