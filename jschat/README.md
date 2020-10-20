Minimal peer-to-peer browser video chat system by Morgan McGuire 
using [WebRTC](https://webrtc.org/),
[MediaStreams](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream), 
and [PeerJS](https://peerjs.com/).

Run the demo from https://morgan3d.github.io/misc/jschat/. That URL
will launch the host, which provides the guest URL.

This code sample serves as a reference implementation for using MediaStreams over
WebRTC. The application to video chat is just to create a motivating context
and it is not intended to be a serious demo of browser based video chat.

TODO:

- Fix keepalive
- Leave button
- Limit to one guest 
- Allow reconnect
- Make an explicit "Join" button so that it doesn't prompt for permissions suddenly on page load
- Audio mute button
- Video mute button
- Nice visual feedback on URL copy
- Text streaming
