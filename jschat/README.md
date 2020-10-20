Minimal peer-to-peer browser videoconferencing system by Morgan McGuire 
using [WebRTC](https://webrtc.org/),
[MediaStreams](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream), 
and [PeerJS](https://peerjs.com/).

Run the demo from https://morgan3d.github.io/misc/jschat/. That URL
will launch the host, which provides the guest URL.


TODO:

- Fix startup sometimes failing. Race condition?
- Detect drop
- Leave button
- Make an explicit "Join" button so that it doesn't prompt for permissions suddenly on page load
- Audio mute button
- Video mute button
- Nice visual feedback on URL copy
- Text streaming
- How do I connect a third party?
