/**
 @file SplayTree.java
 @author Morgan McGuire, morgan@cs.brown.edu
 @created 2002-09-17
 @edited  2002-09-17
 */

public class SplayTree extends BinaryTree {
    
    public SplayTree(Node root) {
        super(root);
    }

    public Node get(int key) {
        Node node = super.get(key);
        splay(node);
        return node;
    }

    public void insert(Node node) {
        super.insert(node);
        splay(node);
    }

    public void delete(int key) {
        delete(super.get(key));
    }

    public void delete(Node node) {
        if (node != null) {
            splay(node.parent);
        }
        super.delete(node);
    }

    public void splay(Node node) {
        if (node == null) {
            return;
        }

        while (! node.isRoot()) {

            // Can't be null-- this isn't the root
            Node p = node.parent;

            // Might be null
            Node g = p.parent;

            if (g == null) {
                System.out.println("**Case 1");
                // CASE 1: parent but no grandparent
                rotate(node);
                // This will be the last step
                if (! node.isRoot()) {
                    throw new Error("Should have stopped");
                }
            } else {
                
                if (node.isLeft() == p.isLeft()) {
                    System.out.println("**Case 2");
                    // CASE 2: node and parent are both left or right children
                    rotate(p);
                    rotate(node);
                } else {
                    System.out.println("**Case 3");
                    // CASE 3: one of each
                    rotate(node);
                    rotate(node);
                }
            }
        }
    }
}

