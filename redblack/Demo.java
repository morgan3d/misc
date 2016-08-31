import javax.swing.*;

public class Demo extends JFrame {

    private RedBlack<Integer, String> tree = new RedBlack<Integer, String>();
    //    private RedBlack2 tree = new RedBlack2();

    private Demo() {
        super("Red Black Tree");
        getContentPane().add(new JLabel(tree));
        pack();
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setVisible(true);


        tree.add(7, "Candice");
        tree.add(5, "Beatrice");

        java.util.Random r = new java.util.Random();
        for (int i = 0; i < 30; ++i){ 
            tree.add(r.nextInt(100), "");
        }
        tree.add(6, "Susan");
        tree.add(4, "Linda");
        tree.add(2, "Harold");
        tree.add(1, "Able");
        tree.add(0, "Chris");
        tree.add(-1, "John");
        tree.add(-2, "Bob");
        tree.add(-3, "Sally");
        tree.add(-4, "Harry");
        tree.add(8, "Lester");
        tree.add(10, "Fred");
    }

    static public void main(String[] arg) {
        new Demo();
    }
}
