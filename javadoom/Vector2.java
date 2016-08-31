/**
   2D point or direction.  All "operator" methods mutate this object
   to avoid the cost of allocating memory.

   <p>Morgan McGuire
   <br>morgan@cs.williams.edu
 */
public final class Vector2 {

    public float x;
    public float y;

    public Vector2() {}

    public Vector2(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public void add(float dx, float dy) {
        x += dx;
        y += dy;
    }

    public void add(Vector2 d) {
        x += d.x;
        y += d.y;
    }

    public void sub(float dx, float dy) {
        x -= dx;
        y -= dy;
    }

    public void sub(Vector2 d) {
        x -= d.x;
        y -= d.y;
    }

    /** c = a - b */
    static public void sub(Vector2 a, Vector2 b, Vector2 c) {
        c.x = a.x - b.x;
        c.y = a.y - b.y;
    }

    /** c = a * b */
    static public void mul(Vector2 a, float b, Vector2 c) {
        c.x = a.x * b;
        c.y = a.y * b;
    }

    public void mul(Vector2 s) {
        x *= s.x;
        y *= s.y;
    }

    public void mul(float s) {
        x *= s;
        y *= s;
    }

    public void div(Vector2 s) {
        x /= s.x;
        y /= s.y;
    }

    public void div(float s) {
        x /= s;
        y /= s;
    }

    public Vector2 clone() {
        return new Vector2(x, y);
    }

    /** Copy values from v to this */
    public void set(Vector2 v) {
        x = v.x;
        y = v.y;
    }

    /** Vector magnitude */
    public float getLength() {
        return (float)Math.sqrt(getSquaredLength());
    }

    /** Sets result to source x (0,0,1) */
    static public void perp(Vector2 source, Vector2 result) {
        result.x =  source.y;
        result.y = -source.x;
    }

    public float getSquaredLength() {
        return x*x + y*y;
    }

    /** Make unit length and return the old length.*/
    public float unitize() {
        float L = getLength();
        mul(1.0f / L);
        return L;
    }

    public float dot(Vector2 v) {
        return x * v.x + y * v.y;
    }

    public String toString() {
        return "(" + x + ", " + y + ")";
    }

    /** Because of floating point precision, two vectors are rarely
        equal.*/
    public boolean equals(Vector2 v) {
        return (v != null) && (v.x == x) && (v.y == y);
    }
}
