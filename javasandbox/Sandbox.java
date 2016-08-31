import java.net.*;
import java.io.*;
import java.security.*;
import java.util.HashMap;

/** Loads classes into a private sandbox. Useful for making plugins
    to your Java applications, for reloading classes dynamically,
    and for loading untrusted code.

    <p>Each Sandbox loads all
    classes fresh (except those specificially designated as
    shared). If you create two Sandboxes and each loads the same
    classes, those classes will not be ==, and their instances will
    not be castable.  This allows you to reload classes at runtime, to
    run untrusted classes with separate loaders and protection
    mechanisms, and to wipe the static data of a dynamically loaded
    class.
    
    <p>In order to allow Sandboxes to communicate, all java.*
    classes are shared with the system ClassLoader and you may
    designate specific classes to be shared and not reloaded.
    
    <p>Morgan McGuire
    <br>morgan@cs.williams.edu
    <br>http://graphics.cs.williams.edu
    <br>Revised April 11, 2008
*/
public class Sandbox extends URLClassLoader {
    
    /** Names and classes that should be shared; all other
        classes (except for java.* classes) will be loaded fresh. */
    protected HashMap<String, Class> shared = new HashMap<String, Class>();
    
    /** <b>Replaces</b> the system classpath with this one. */
    private Sandbox(URL[] classpath, Class[] share) {
        super(classpath, null);

        for (Class c : share) {
            addSharedClass(c);
        }
    }

    /** Prepends this directory onto the system classpath */
    private Sandbox(String addToClasspath, Class[] share) throws IOException {
        this(toClasspath(addToClasspath), share);
    }

    /** Prepends this directory onto the system classpath */
    private Sandbox(String addToClasspath) throws IOException {
        this(toClasspath(addToClasspath), new Class[0]);
    }
        
    /** Uses default classpath. */
    private Sandbox(Class[] share) throws IOException {
        this(getSystemClasspath(), share);

    }

    /** Uses default classpath. */
    private Sandbox() throws IOException {
        this(getSystemClasspath(), new Class[0]);

    }

    /** Share class c with this sandbox. */
    public void addSharedClass(Class c) {
        if ((c.getClassLoader() != this) && 
            (findLoadedClass(c.getName()) != null)) {
            throw new IllegalArgumentException
                ("Class " + c.getName() + 
                 " has already been loaded by " + this + " and cannot be shared.");
        }

        shared.put(c.getName(), c);
    }
    
    /** Directory is treated relative to the current dir */
    private static URL[] toClasspath(String directory) throws IOException {
        try {
            URL url = new File(directory).toURL();
            return toClasspath(url);
        } catch (MalformedURLException e) {
            throw new IOException(e.getMessage());
        }
    }
    
    /** Concatenates two arrays */
    private static URL[] append(URL[] a, URL[] b) {
        URL[] c = new URL[a.length + b.length];
        System.arraycopy(a, 0, c, 0, a.length);
        System.arraycopy(b, 0, c, a.length, b.length);
        return c;
    }
    
    private static URL[] getSystemClasspath() {
        ClassLoader sys = ClassLoader.getSystemClassLoader();
        if (sys instanceof URLClassLoader) {
            return ((URLClassLoader)sys).getURLs();
        } else {
            return new URL[0];
        }
    }
    
    private static URL[] toClasspath(URL directory) {
        // Custom classpath
        return append(new URL[]{directory}, getSystemClasspath());
    }
    
    public Class loadClass(String name) throws ClassNotFoundException {
        return loadClass(name, false);
    }

    protected Class loadClass(String name, boolean b) throws ClassNotFoundException {
        Class c = shared.get(name);
        if (c != null) {
            // Use the existing shared class
            return c;
        } else if (name.startsWith("java.")) {
            // Load this system class
            return Class.forName(name, b, ClassLoader.getSystemClassLoader());
        } else {
            // Load it myself
            return super.loadClass(name, b);
        }
    }

    /** Loads the class named name in its own sandbox.  The same as:
        <code>Class.forName(name, false, new Sandbox(shared));</code>*/
    static Class loadIsolated(String name, Class[] shared) throws ClassNotFoundException, IOException {
        return new Sandbox(shared).loadClass(name);
    }
}
