Streaming P2P browser graphics example using WebRTC by Morgan
McGuire. This code was codeveloped with Josh Minor.

Run the demo at: https://morgan3d.github.io/misc/jsremotegame/

Character sprites are public domain images by [Puffolotti](https://opengameart.org/users/puffolotti).
Background sprites are based on public domain images by Luis Zuno [(@ansimuz)](https://opengameart.org/content/industrial-parallax-background).

Tested and independently optimized for Chrome, Edge, Firefox, and Safari on Windows and macOS.
WebRTC, MediaStream, AudioContext, and PeerJS are very finicky. It took a lot of testing and
careful ordering of operations to make the code robust.
I haven't tested on Linux yet.

TODO:

- Safari doesn't work as a guest. It just gets that first frame and
  then stops receiving (the incoming image appears to be transparent
  black).
