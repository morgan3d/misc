/**
 @file SplayDemo.java
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
 @file SplayDemo.java
 @author Morgan McGuire, morgan@cs.brown.edu
 @created 2002-09-15
 @edited  2002-09-16
 */

public class SplayDemo extends JApplet {

    /** The demo can maintain multiple trees to show balance
        differences. */
    BinaryTree tree[]      = new BinaryTree[2];

    /** Part of the UI */
    JComboBox mouseAction = null;

    public SplayDemo() {
        tree[0] = new BinaryTree(null);
        tree[1] = new SplayTree(null);
        build3Trees();

        JPanel vbox = new JPanel();
        vbox.setLayout(new BorderLayout());
        vbox.setBackground(java.awt.Color.white);

        JPanel trees = new JPanel();
        trees.setBackground(java.awt.Color.white);

        trees.add(new TreeDisplay(this, tree[0], "Binary Tree"));
        trees.add(new TreeDisplay(this, tree[1], "Splay Tree"));
        vbox.add(trees, BorderLayout.CENTER);

        JPanel controls = new JPanel();
        controls.add(new JLabel("Mouse click"));
        controls.setBackground(java.awt.Color.white);

        mouseAction =
            new JComboBox(
               new String[]{"accesses", "rotates", "deletes", "inserts"});
        controls.add(mouseAction);
        controls.add(new JLabel("a node.   Pre-built trees: "));

        {
            JButton button = new JButton("1");
            button.setToolTipText("Build a tree for executing a case 1 splay step.");
            button.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {build1Trees(); repaint();}
                });
            controls.add(button);
        }

        {
            JButton button = new JButton("2");
            button.setToolTipText("Build a tree for executing a case 2 splay step.");
            button.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {build2Trees(); repaint();}
                });
            controls.add(button);
        }

        {
            JButton button = new JButton("3");
            button.setToolTipText("Build a tree for executing a case 3 splay step.");
            button.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {build3Trees(); repaint();}
                });
            controls.add(button);
        }

        {
            JButton button = new JButton("?");
            button.setToolTipText("Build a random tree.");
            button.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {buildRandomTrees(); repaint();}
                });
            controls.add(button);
        }


        vbox.add(controls, BorderLayout.SOUTH);

        setContentPane(vbox);

        mouseAction.setSelectedIndex(0);
    }

    private void buildRandomTrees() {
        for (int t = 0; t < tree.length; ++t) {
            tree[t].setRoot(null);
        }

        for (int j = 0; j < 10; ++j) {
            int key = (int)(Math.random() * 20);
            for (int t = 0; t < tree.length; ++t) {
                tree[t].insert(key);
            }
        }
    }

    
    private void build1Trees() {
        // Build case 1 trees

        //                4
        //             2    5
        //           1   3
        for (int t = 0; t < tree.length; ++t) {
            tree[t].setRoot(
                            new Node(4,
                                     new Node(2, new Node(1), new Node(3)),
                                     new Node(5)));
        }
    }


    private void build2Trees() {
        // Build case 2 trees

        //                7
        //             5     8
        //           3   6
        //         1  4

        for (int t = 0; t < tree.length; ++t) {
            tree[t].setRoot(
               new Node(7,
                   new Node(5, new Node(3, new Node(1), new Node(4)), new Node(6)),
                   new Node(8)));
        }
    }


    private void build3Trees() {
        // Build case 3 trees

        //                3
        //             1     8
        //                 5   9
        //               4   7

        for (int t = 0; t < tree.length; ++t) {
            tree[t].setRoot(
               new Node(3,
                        new Node(1),
                        new Node(8, new Node(5, new Node(4), new Node(7)), new Node(9))));
        }
    }

    private void buildTrees() {
        //
        //                4
        //           2        8
        //         1   3    6
        //                5   7
        //
        for (int t = 0; t < tree.length; ++t) {
            tree[t].setRoot(
            new Node(4,
                     new Node(2, new Node(1), new Node(3)),
                     new Node(8, new Node(6, new Node(5), new Node(7)))));
        }
    }


    /**
       Invoked by the display when the user clicks the left 
       mouse button on a node.  -1 means no node was selected.
       Repaints the whole applet.
     */
    public void leftMouse(int key, TreeDisplay display) {
        System.out.println("---------------------------------");

        String action = (String)mouseAction.getSelectedItem();

        if (action == "accesses") {
            for (int t = 0; t < tree.length; ++t) {
                tree[t].get(key);
            }
        } else if (action == "rotates") {
            // Rotate just that tree
            display.tree.rotate(key);
        } else if (action == "deletes") {
            // Delete from all trees
            for (int t = 0; t < tree.length; ++t) {
                tree[t].delete(key);
            }
        } else if (action == "inserts") {
            for (int i = 0; i < 100; ++i) {
                int k = (int)(Math.random() * 20);
                // Note that tree 0 is the binary tree, so the get
                // won't trigger a splay.
                if (tree[0].get(k) == null) {
                    for (int t = 0; t < tree.length; ++t) {
                        tree[t].insert(k);
                    }
                    break;
                }
            }
        }

        for (int t = 0; t < tree.length; ++t) {
            tree[t].debugCheckIntegrity();
        }

        repaint();
    }

    public static void main(String arg[]) {
        JFrame frame = new JFrame("Splay Tree Demo");
        frame.addWindowListener(new java.awt.event.WindowAdapter() {
                public void windowClosing(java.awt.event.WindowEvent e) {
                    System.exit(0);
                }
            });
        
        SplayDemo demo = new SplayDemo();
        frame.setContentPane(demo);
        frame.pack();
        frame.setVisible(true);
    }
}


