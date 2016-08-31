/**
 @file BinaryTree.java
 @author Morgan McGuire, morgan@cs.brown.edu
 @created 2002-09-17
 @edited  2002-09-17
 */

public class BinaryTree {
    protected Node root = null;
    
    public BinaryTree(Node root) {
        this.root = root;
    }

    public void setRoot(Node n) {
        root = n;
    }

    public Node getRoot() {
        return root;
    }

    /** Returns null if not found. */
    public Node get(int key) {
        Node node = root;

        while (node != null) {
            if (key == node.key) {
                return node;
            } else if (key > node.key) {
                node = node.right;
            } else if (key < node.key) {
                node = node.left;
            }
        }

        return null;
    }

    public void insert(int key) {
        insert(new Node(key));
    }

    public void insert(Node node) {
        if (node == null) {
            return;
        }

        if (root == null) {
            root = node;
            return;
        }
        
        Node parent = null;
        Node current = root;
        while (current != null) {
            parent = current;

            if (current.key == node.key) {
                // Already in the set
                return;
            }

            if (node.key < current.key) {
                current = current.left;
            } else {
                current = current.right;
            }
        }

        // current is now null
        if (node.key < parent.key) {
            parent.setLeft(node);
        } else {
            parent.setRight(node);
        }
        
    }

    /** Does nothing if they key is not present. */
    public void delete(int key) {
        delete(get(key));
    }

    public void delete(Node node) {
        // Based on Tree-Delete, CLR page 253
        if (node == null) {
            // Not in set
            return;
        }

        Node y = null;

        if (node.isLeaf()) {
            // The node has no children; just replace it with null
            replace(node, null);

        } else if (node.left == null) {
            // Replace this node with its right child. 
            // There is no left child.
            replace(node, node.right);

        } else if (node.right == null) {
            // Replace this node with its left child.
            // There is no right child.
            replace(node, node.left);
            
        } else {
            
            // The node has children.  Replace it with its successor.
            // The successor might have children of its own, however.
            Node r = getSuccessor(node);
            Node x = null;

            // Grab the first non-null child of r (if there is one).
            if (r.left == null) {
                x = r.right;
            } else {
                x = r.left;
            }
            
            // Replace r with its child
            replace(r, x);

            // Replace the node with its successor
            if (node.left == r) {
                node.left = null;
            } else if (node.right == r) {
                node.right = null;
            }

            replace(node, r);
            r.setLeft(node.left);
            r.setRight(node.right); 
        }
        
        node.left   = null;
        node.right  = null;
        node.parent = null;
    }

    /** Next larger key */
    public Node getSuccessor(Node node) {
        // Based on Tree-Successor, CLR page 249
        if (node == null) {
            return null;
        }

        if (node.right != null) {
            return getMinimum(node.right);
        }

        Node y = node.parent;
        while ((y != null) && (node != y.right)) {
            node = y;
            y = node.parent;
        }

        return y;
    }

    public Node getMinimum() {
        return getMinimum(root);
    }

    public Node getMinimum(Node node) {
        // Based on Tree-Minimum, CLR page 248

        if (node == null) {
            return null;
        }

        while (node.left != null) {
            node = node.left;
        }
        return node;
    }

    /** Replaces one subtree with another, ensuring that
        the root pointer is maintained. */
    private void replace(Node oldNode, Node newNode) {
        if (oldNode.isRoot()) {
            root = newNode;
            if (newNode != null) {
                newNode.parent = null;
            }
        } else {
            oldNode.parent.replaceChild(oldNode, newNode);
        }
    }
        
    /** Perform a binary tree rotation about this node's
        parent... that is, replace the parent with this node and move
        the affected children so the binary search tree property is
        maintained. */
    public void rotate(int key) {
        rotate(get(key));
    }

    public void rotate(Node n) {
        if (n == null) {
            return;
        }
        
        System.out.println("Rotating " + n.key);

        // Parent
        Node p = n.parent;

        // Grandparent
        Node g = (p != null) ? p.parent : null;

        if (n.isRoot()) {
            // Rotating the root does nothing
            return;
        } 

        final boolean wasLeft = n.isLeft();

        if (g != null) {
            // Make the grandparent point at the node.
            g.replaceChild(p, n);
        } else {
            // No grandparent; this node is the new tree root.
            root = n;
            n.parent = null;
        }

        if (wasLeft) {
            p.setLeft(n.right);
            n.setRight(p);
        } else {
            p.setRight(n.left);
            n.setLeft(p);
        }
    }

    /** Ensures that the tree hasn't been corruped; here for
        debugging purposes. */
    public void debugCheckIntegrity() {
        checkIntegrity(root, -1, 1000);
    }

    private void checkIntegrity(Node n, int min, int max) {
        if (n != null) {
            if (! (n.isRoot() || n.isLeft() || n.isRight())) {
                throw new Error("Integrity violation: " + n.key);
            }

            if (n.isRoot() && (root != n)) {
                throw new Error("Integrity violation: " + n.key +
                                " thinks it is the root");
            }

            if ((n.key >= max) || (n.key <= min)) {
                throw new Error("Integrity violation: " + n.key +
                                " is not between " + min + " and " + max);
            }

            checkIntegrity(n.left, min, n.key);
            checkIntegrity(n.right, n.key, max);
        }        
    }
}

