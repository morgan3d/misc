/*
 From https://github.com/morgan3d/misc/

 Created by Morgan McGuire in 2020
 Released into the public domain.
*/
'use strict';

/*
 There is no consistent way to detect a closed WebRTC
 connection, so we have to send keepalive messages. PeerJS
 has its own parameters for ping rates, but does not appear
 to use them at present on investigating the code.
*/
const KEEP_ALIVE_INTERVAL_MS = 0.25 * 1000;
const KEEP_ALIVE_MESSAGE = 'KEEP_ALIVE';

// How many intervals can be missed before we drop connection
const MISSABLE_INTERVALS = 10;

const peerConfig = {
    debug: 1,/*
    host: "peer.???.org",
    port: 9001,
    path: '/remoteplay',
    key: 'remoteplay'*/
};

function generateUniqueID() {
    const length = 8;
    const prefix = 'xc';
    const number = (Math.random() + (performance.now() % 1000) / 1000) % 1;
    return prefix + number.toFixed(length).substring(2);
}

/* Milliseconds since epoch in UTC. Used for detecting when the last keepAlive
   was received. */
function now() {
    return new Date().getTime();
}

function startWebCam(callback) {
    console.log('startWebCam');
    if (! navigator.mediaDevices) {
        console.log('No media devices. Probably running without https');
        return;
    }
    
    navigator.mediaDevices.getUserMedia({audio: true, video: {width: 512, height: 512, facingMode: "user"}})
        .then(callback)
        .catch(function(err) {
            console.log(err);
        });
}


/* Returns the DOM element that was added */
function addWebCamView(caption, mediaStream, playAudio, id) {
    console.log('addWebCamView for ' + caption);
    const videobox = document.getElementById('videobox');
    const frame = document.createElement('div');
    frame.className = 'videoFrame';
    frame.id = '_' + id;
    frame.innerHTML = `<div style="width: 100%">${caption}</div><div class="warning">⚠</div>`;
    const video = document.createElement('video');
    video.setAttribute('autoplay', true);
    // video.setAttribute('controls', true);
    video.srcObject = mediaStream;
    video.muted = ! playAudio;
    frame.appendChild(video);
    videobox.appendChild(frame);

    return frame;
}


/* Write to the clipboard. Hard-coded to the specific URL box */
function clipboardCopy(text) {
    const urlTextBox = document.getElementById('urlTextBox');
    urlTextBox.select(); 
    urlTextBox.setSelectionRange(0, 99999);
    document.execCommand('copy');
    setTimeout(function () { urlTextBox.blur(); });
}

/* Perpetually send keep alive messages to this dataConnection, and listen for them
   coming back. getVideo() is a callback because the video may not be available right
   when the data connection is. */
function keepAlive(dataConnection) {
    // Undefined until the first message comes in
    let lastTime = undefined;

    // Save the ID, which may become invalid if the connection fails
    const elementID = '_' + dataConnection.peer;

    function ping() {
        const currentTime = now();
        if (lastTime && (currentTime - lastTime > MISSABLE_INTERVALS * KEEP_ALIVE_INTERVAL_MS)) {
            // The other side seems to have dropped connection
            console.log('lost connection. ', (currentTime - lastTime) / 1000, 'seconds without a keepAlive message.');
            const videoElement = document.getElementById(elementID);
            if (videoElement) { videoElement.remove(); }
            // Ending the iterative callback chain should allow garbage collection to occur
            // and destroy all resources
        } else {
            // console.log('sent KEEP_ALIVE message');
            dataConnection.send(KEEP_ALIVE_MESSAGE);

            // Show or hide the connection warning as appropriate. Note that the element might not exist
            // right at the beginning of the connection.
            const connectionIsBad = lastTime && (currentTime - lastTime >= 2 * KEEP_ALIVE_INTERVAL_MS);

            const warningElement = document.querySelector('#' + elementID + ' .warning');
            if (warningElement) {
                warningElement.style.visibility = connectionIsBad ? 'visible' : 'hidden';
            }

            // Schedule the next ping
            setTimeout(ping, KEEP_ALIVE_INTERVAL_MS);
        }
    }

    // Do not put these in dataConnection.on or they can fail due to a race condition
    // with initialization and never run.
    dataConnection.on('data', function (data) {
        if (data === KEEP_ALIVE_MESSAGE) { lastTime = now(); }
        // console.log('received data', data);
    });

    // Start the endless keepAlive process
    ping(dataConnection);
}


function startGuest() {
    console.log('startGuest');
    const hostID = window.location.search.substring(1);
    document.getElementById('urlbox').innerHTML = `You are the guest in room ${hostID}.`;
    
    const peer = new Peer(generateUniqueID(), peerConfig);

    peer.on('error', function (err) {
        console.log('error in guest:', err);
    });
    
    peer.on('open', function (id) {
        startWebCam(function (mediaStream) {
            console.log('web cam started');
            
            addWebCamView('You', mediaStream, false, id);
            
            console.log('call host');
            let videoElement = undefined;
            let alreadyAddedThisCall = false;

            const mediaConnection = peer.call(hostID, mediaStream);
            mediaConnection.on('stream',
                    function (hostStream) {
                        if (! alreadyAddedThisCall) {
                            alreadyAddedThisCall = true;
                            console.log('host answered');
                            videoElement = addWebCamView('Host', hostStream, true, mediaConnection.peer);
                        } else {
                            console.log('rejected duplicate call');
                        }
                    },
                    
                    function (err) {
                        console.log('host stream failed with', err);
                    }
                   ); //mediaConnection.on('stream')

            console.log('connect data to host');
            const dataConnection = peer.connect(hostID);
            dataConnection.on('open', function () {
                console.log('data connection to host established');
                keepAlive(dataConnection);
            });

        }); // startWebCam
    }); // peer.on('open')
}


function startHost() {
    console.log('startHost');

    // The peer must be created RIGHT before open is registered,
    // otherwise we could miss it.
    const id = localStorage.getItem('id') || generateUniqueID();
    localStorage.setItem('id', id);
    const peer = new Peer(id, peerConfig);
    
    peer.on('error', function (err) {
        console.log('error in host:', err);
    });
    
    peer.on('open', function(id) {
        console.log('host peer opened with id ' + id);
        const url = 'https://morgan3d.github.io/misc/jschat/?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. One guest can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;
                
        startWebCam(function (mediaStream) {
            addWebCamView('You', mediaStream, false, id);
            
            let videoElement = undefined;

            peer.on('connection', function (dataConnection) {
                console.log('data connection to guest established');
                keepAlive(dataConnection);
            });

            peer.on('call',
                    function (mediaConnection) {
                        console.log('guest called');
                        
                        // Answer the call, providing our mediaStream
                        mediaConnection.answer(mediaStream);
                        
                        // Close is not supported on Firefox
                        mediaConnection.on('close', function () {
                            console.log('guest left the call');
                        });                        

                        // Work around a bug in peer.js where it calls
                        // twice if the video element is added during the
                        // callback
                        let alreadySeenThisCall = false;
                        
                        // When the client connects, add its stream
                        mediaConnection.on('stream',
                                function (guestStream) {
                                    if (! alreadySeenThisCall) {
                                        alreadySeenThisCall = true;                                                
                                        
                                        console.log('guest streamed');
                                        videoElement = addWebCamView('Guest', guestStream, true, mediaConnection.peer);
                                    } else {
                                        console.log('rejected duplicate stream from guest');
                                    }
                                },
                                function (err) {
                                    console.log('guest stream failed with', err);
                                });
                    },
                    
                    function (err) {
                        console.log('guest call failed with', err);
                    }
                   ); // peer.on('call')
        }); // startWebCam
    }); // peer.on('open')
}


function main() {
    document.getElementById('urlbox').style.visibility = 'visible';                            
    if (window.location.search !== '') {
        startGuest();        
    } else {
        startHost();
    }
}
