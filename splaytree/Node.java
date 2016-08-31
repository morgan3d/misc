/**
 Binary tree node.  If you use the Node versions of the tree
 operations (instead of the key versions) you can extend Node
 with your own data and the trees will carry it around with
 the associated key.
 */
class Node {
    public Node left   = null;
    public Node right  = null;
    public Node parent = null;

    /** Keys are assumed to be non-negative integers. */
    public int  key   = 0;

    public Node(int key) {
        this(key, null, null);
    }


    public Node(int key, Node left) {
        this(key, left, null);
    }


    public Node(int key, Node left, Node right) {
        this.key  = key;
        this.right  = right;
        this.left   = left;
        this.parent = null;

        // Back pointers
        if (this.left != null) {
            this.left.parent  = this;
        }

        if (this.right != null) {
            this.right.parent = this;
        }
    }

    public boolean isLeaf() {
        return (left == null) && (right == null);
    }

    public boolean isRoot() {
        return parent == null;
    }

    public boolean isLeft() {
        return (parent != null) && (parent.left == this);
    }

    public boolean isRight() {
        return (parent != null) && (parent.right == this);
    }

    /**  Total size of the tree */
    public int size() {
        int s = 1;
        if (left != null) {
            s += left.size();
        }
        if (right != null) {
            s += right.size();
        }
        return s;
    }

    /** Depth == 0 is an empty tree */
    public int depth() {
        int L = 1;
        int R = 1;
        if (left != null) {
            L = left.depth();
        }
        if (right != null) {
            R = right.depth();
        }
        return Math.max(L, R);
    }

    /** Takes care of the back pointer */
    public void setRight(Node n) {
        right = n;
        if (n != null) {
            System.out.println("Setting " + n.key + "'s parent to " + key);
            n.parent = this;
        }
    }

    /** Takes care of the back pointer */
    public void setLeft(Node n) {
        left = n;
        if (n != null) {
            System.out.println("Setting " + n.key + "'s parent to " + key);
            n.parent = this;
        }
    }

    /** Sets the appropriate right or left child */
    public void replaceChild(Node oldChild, Node newChild) {
        if (oldChild == left) {
            setLeft(newChild);
        } else if (oldChild == right) {
            setRight(newChild);        
        } else {
            throw new Error("Not a child");
        }
    }

    public String toString() {
        return "Node " + key + 
            " parent = " + ((parent != null) ? ("" + parent.key) : "null");
    }
}
