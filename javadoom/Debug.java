import javax.swing.*;

/** Debugging options for Doom.*/
public abstract class Debug {
    static private JCheckBox showRaysBox = new JCheckBox("Show rays");
    static private JCheckBox showMapBox  = new JCheckBox("Show map");
    static private JCheckBox oneRayBox   = new JCheckBox("One ray");

    static public void createControls(Game g) {
        showMapBox.setSelected(true);
        showRaysBox.setSelected(false);
        oneRayBox.setSelected(false);

        g.addControl(showMapBox);
        g.addControl(showRaysBox);
        g.addControl(oneRayBox);
    }

    /** Show rays in map */
    static boolean getShowRays() {
        return showRaysBox.isSelected();
    }

    static boolean getShowMap() {
        return showMapBox.isSelected();
    }

    /** True if only one ray should be cast. */
    static boolean getOneRay() {
        return oneRayBox.isSelected();
    }
}
