/*
 From https://github.com/morgan3d/misc/

 Created by Morgan McGuire in 2020
 Released into the public domain.

 There is no consistent way to detect a closed WebRTC
 connection, so we have to send keepalive messages.
*/
'use strict';

const KEEP_ALIVE_INTERVAL_MS = 0.5 * 1000;

// How many intervals can be missed before we drop connection
const MISSABLE_INTERVALS = 6;

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
function addWebCamView(caption, mediaStream, playAudio) {
    console.log('addWebCamView for ' + caption);
    const videobox = document.getElementById('videobox');
    const frame = document.createElement('div');
    frame.className = 'videoFrame';
    frame.innerHTML = `<div style="width: 100%">${caption}</div>`;
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

/* Perpetually send keep alive messages to this dataConnection */
function keepAlive(dataConnection, getTime, getVideo) {
    function ping() {
        let time = getTime();
        if (time && (now() - time > MISSABLE_INTERVALS * KEEP_ALIVE_INTERVAL_MS)) {
            // The other side seems to have died
            console.log('lost connection');
            getVideo().remove();
            // Ending the chain should allow garbage collection to occur
        } else {
            dataConnection.send('keepAlive');
            setTimeout(ping, KEEP_ALIVE_INTERVAL_MS);
        }
    }

    dataConnection.on('open', function () {
        console.log('data connection open');
        dataConnection.on('data', function (data) {
            console.log('received data', data);
        });

        ping(dataConnection);
    });    
}


function startGuest() {
    console.log('startGuest');
    let hostID = window.location.search.substring(1);
    document.getElementById('urlbox').innerHTML = `You are a guest of ${hostID}.`;
    
    peer = new Peer();

    peer.on('error', function (err) {
        console.log('error in guest:', err);
    });
    
    peer.on('open', function (id) {
        startWebCam(function (mediaStream) {
            console.log('web cam started');
            
            addWebCamView('You', mediaStream, false);
            
            console.log('call host');
            let mediaConnection = peer.call(hostID, mediaStream);

            let lastKeepAliveReceived = undefined;
            let videoElement = undefined;

            let alreadyAddedThisCall = false;
            mediaConnection.on('stream',
                    function (hostStream) {
                        if (! alreadyAddedThisCall) {
                            alreadyAddedThisCall = true;
                            console.log('host answered');
                            lastKeepAliveReceived = now();
                            videoElement = addWebCamView('Host', hostStream, true);
                        } else {
                            console.log('rejected duplicate call');
                        }
                    },
                    
                    function (err) {
                        console.log('host stream failed with', err);
                    }
                   ); //mediaConnection.on('stream')

            console.log('connect data to host');
            let dataConnection = peer.connect(hostID);
            dataConnection.on('open', function () {
                keepAlive(dataConnection, 
                    function () { return lastKeepAliveReceived; },
                    function () { return videoElement; });
            });

        }); // startWebCam
    }); // peer.on('open')
}


function startHost() {
    console.log('startHost');

    // The peer must be created RIGHT before open is registered,
    // otherwise we could miss it.
    peer = new Peer();

    peer.on('error', function (err) {
        console.log('error in host:', err);
    });
    
    peer.on('open', function(id) {
        console.log('host peer opened with id ' + id);
        const url = 'https://morgan3d.github.io/misc/jschat/?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. Others can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;
                
        startWebCam(function (mediaStream) {
            addWebCamView('You', mediaStream, false);
            
            let lastKeepAliveReceived = undefined;
            let videoElement = undefined;

            peer.on('connection', function (dataConnection) {
                keepAlive(dataConnection,
                    function () { return lastKeepAliveReceived; },
                    function () { return videoElement; });
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
                                        lastKeepAliveReceived = now();
                                        videoElement = addWebCamView('Guest', guestStream, true);
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


let peer;

function main() {
    if (window.location.search !== '') {
        startGuest();        
    } else {
        startHost();
    }
}
