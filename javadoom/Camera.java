public class Camera {

    /** Horizontal field of view in radians */
    private float         fieldOfView = (float)Math.toRadians(60);
    private float         heading     = (float)Math.toRadians(90);
    private float         pitch       = 0;
    private final Vector2 position    = new Vector2();

    /** Clockwise angle from the x-axis in radians*/
    public float getHeading() {
        return heading;
    }

    public void setHeading(float h) {
        heading = h;
    }

    /** Clockwise angle from the horizontal in radians*/
    public float getPitch() {
        return pitch;
    }

    /** Clones the result. */
    public Vector2 getPosition() {
        return position.clone();
    }

    /** Moves this distance along the heading direction */
    public void move(float distance) {
        position.add(distance * (float)Math.cos(heading), distance * (float)Math.sin(heading));
    }

    /** Moves this distance perpendicular to the heading direction
        (positive is to the left) */
    public void strafe(float distance) {
        position.add(-distance * (float)Math.sin(heading), distance * (float)Math.cos(heading));
    }

    /** Angle is in radians */
    public void turn(float angle) {
        heading += angle;
    }

    /** Clones the result */
    public Vector2 getViewVector() {
        return new Vector2((float)Math.cos(heading), (float)Math.sin(heading));
    }

    /** Gets the ray through pixel x on a viewport of the given a width.
        Returns the dot product of the view vector and the ray direction.*/
    public float computeRay(int x, int viewportWidth, Ray ray) {
        ray.origin.set(position);

        // Have to negate the angle offset, since the left-most pixel (0)
        // corresponds to the largest angular offset.
        float offset = fieldOfView * (0.5f - (float)x / (viewportWidth - 1));
        float angle = heading + offset;

        ray.direction.x = (float)Math.cos(angle);
        ray.direction.y = (float)Math.sin(angle);

        return (float)Math.cos(offset);
    }
}
