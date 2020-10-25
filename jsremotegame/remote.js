'use strict';

/*
 From https://github.com/morgan3d/misc/

 Created by Morgan McGuire in 2020
 Released into the public domain.
*/

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

// Going higher than the rendering rate on client or server
// does not seem to lower latency
const FRAMERATE_HZ = 60;

const width = 384;
const height = 224;

/* Set to true to force the client to try to clean up the image after
   video decompression and disable bilinear interpolation. In the current 
   implementation this adds no latency. */
const isPixelArt = true;

const peerConfig = {
    debug: 1,
    /*
    host: "...",
    port: 9001,
    path: '/remoteplay',
    key: 'remoteplay'
    */
};

const isUIWebView = ! /chrome|firefox|safari|edge/i.test(navigator.userAgent) && /applewebkit/i.test(navigator.userAgent);  
const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent) || isUIWebView;

/////////////////////////////////////////////////////////////////////////

async function getAudioBuffer(url) {
  const response = await fetch(url);
  const arrayBuffer = await response.arrayBuffer();
  const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
  return audioBuffer;
}    

let audioContext;
let soundEffect;


/* Milliseconds since epoch in UTC. Used for detecting when the last keepAlive
   was received. */
function now() {
    return new Date().getTime();
}

function loadImage(url) {
    const image = new Image();
    image.crossOrigin = "anonymous";
    image.src = url;
    return image;
}

const characterImageArray = [loadImage('lila.png'), loadImage('fredo.png')];
const backgroundImageArray = [];
for (let i = 0; i < 4; ++i) {
    backgroundImageArray.push(loadImage('background' + i + '.png'));
}

function generateUniqueID() {
    const length = 8;
    const prefix = 'rg';
    const number = (Math.random() + (performance.now() % 1000) / 1000) % 1;
    return prefix + number.toFixed(length).substring(2);
}


/* Perpetually send keep alive messages to this dataConnection, and listen for them
   coming back. getVideo() is a callback because the video may not be available right
   when the data connection is. */
function keepAlive(dataConnection, setWarning, drop) {
    dataConnection.messageHandlerArray = [];
    dataConnection.on('data', function (message) {
        for (let i = 0; i < dataConnection.messageHandlerArray.length; ++i) {
            if (dataConnection.messageHandlerArray[i](message)) { return; }
        }
    });

    // Undefined until the first message comes in
    let lastTime = undefined;

    // Save the ID, which may become invalid if the connection fails
    const elementID = '_' + dataConnection.peer;

    function ping() {
        const currentTime = now();
        if (lastTime && (currentTime - lastTime > MISSABLE_INTERVALS * KEEP_ALIVE_INTERVAL_MS)) {
            // The other side seems to have dropped connection
            console.log('lost connection. ', (currentTime - lastTime) / 1000, 'seconds without a keepAlive message.');
            // Ending the iterative callback chain should allow garbage collection to occur
            // and destroy all resources
            drop && drop(dataConnection.peer);
        } else {
            // console.log('sent KEEP_ALIVE message');
            dataConnection.send(KEEP_ALIVE_MESSAGE);

            // Show or hide the connection warning as appropriate. Note that the element might not exist
            // right at the beginning of the connection.
            const connectionIsBad = lastTime && (currentTime - lastTime >= 2 * KEEP_ALIVE_INTERVAL_MS);
            setWarning && setWarning(dataConnection.peer, connectionIsBad);

            // Schedule the next ping
            setTimeout(ping, KEEP_ALIVE_INTERVAL_MS);
        }
    }

    dataConnection.messageHandlerArray.push(function (data) {
        if (data === KEEP_ALIVE_MESSAGE) { lastTime = now(); return true; }
        // console.log('received data', data);
    });

    // Start the endless keepAlive process
    ping(dataConnection);
}

/* Write to the clipboard. Hard-coded to the specific URL box */
function clipboardCopy(text) {
    const urlTextBox = document.getElementById('urlTextBox');
    urlTextBox.select(); 
    urlTextBox.setSelectionRange(0, 99999);
    document.execCommand('copy');
    setTimeout(function () { urlTextBox.blur(); });
}

// Only defined on the host
let screenStream;

const INSTRUCTIONS = 'Use the <b>←</b>, <b>→</b>, <b>A</b>, and <b>D</b> keys to move your character, <b>Spacebar</b> for sound.';

let playerState = [{lt: false, rt: false, x: 134/2}, {lt: false, rt: false, x: width - 134/2}];

function processKeyEvent(player, type, keyCode) {
    const state = playerState[player];
    switch (keyCode) {
    case 39: case 68: // Right
        state.rt = type === 'keydown';
        break;
        
    case 37: case 65: // Left
        state.lt = type === 'keydown';
        break;

    case 32: // Spacebar
        if (type === 'keydown') {
            if (audioContext.state === 'suspended') {
                audioContext.resume();
            }
            if (soundEffect) {
                const trackSource = audioContext.createBufferSource();
                trackSource.buffer = soundEffect;
                trackSource.connect(audioContext.destination);
                trackSource.start();
            } else {
                console.log('audio not loaded yet');
            }
        }
        break;
    }
}

function peerErrorHandler(err) {
    let msg = err + '.';
    if (msg.indexOf('concurrent user limit')) {
        msg += ' The PeerJS Cloud is too popular right now. Try again in a little while.';
    }
    document.getElementById('urlbox').innerHTML = `Sorry. <span style="color:red">${msg}</span>`;
}


function startHost() {
    console.log('startHost');

    // polyfill for Safari
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
    getAudioBuffer('sound0.mp3').then(function (buffer) {
        soundEffect = buffer;
        console.log('loaded audio');
    });
    
    // The stream will fail silently when running on a non-https server
    if (location.protocol === 'file:') {
        alert('canvas.captureStream() requires http/https to avoid CORS violations, so this demo will not work on this server');
    }
    
    // Setting the frame rate here increases latency. Instead, specify
    // when the buffer has changed explicitly in the rendering routines.
    screenStream = document.getElementById('screen').captureStream();
    screenStream.addTrack(audioContext.createMediaStreamDestination().stream.getAudioTracks()[0]);
    
    if (true) {
        // Normally, remove the video on the host
        document.getElementById('video').remove();
    } else {
        // Local monitor when debugging
        const video = document.getElementById('video');
        video.style.top = '0px';
        video.style.right = '0px';
        video.srcObject = screenStream;
    }

    // The peer must be created RIGHT before open is registered,
    // otherwise we could miss it.
    const id = localStorage.getItem('id') || generateUniqueID();
    localStorage.setItem('id', id);
    const peer = new Peer(id, peerConfig);

    peer.on('error', peerErrorHandler);
    
    peer.on('open', function(id) {
        console.log('host peer opened with id ' + id);
        const url = location.href + '?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. One guest can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span><br>${INSTRUCTIONS}`;

        peer.on('connection', function (dataConnection) {
            console.log('data connection to guest established');

            console.log('calling the guest back with the stream');
            const mediaConnection = peer.call(dataConnection.peer, screenStream);

            keepAlive(dataConnection);
            dataConnection.messageHandlerArray.push(function (message) {
                if (message && message.type && message.type.startsWith('key')) {
                    processKeyEvent(1, message.type, message.keyCode);
                }
            });
        });
        
    }); // peer.on('open')

    // Start the game loop
    gameTick();

    function handleEvent(event) { processKeyEvent(0, event.type, event.keyCode); }
    document.addEventListener('keydown', handleEvent);
    document.addEventListener('keyup', handleEvent);
}

let frame = 0;
function gameTick() {
    // Use setTimeout instead of
    // requestAnimationFrame. requestAnimationFrame runs at the
    // display rate, and I want a 60 Hz locked. This is not the
    // optimal way to accomplish that; see the quadplay source for a
    // more precise example.
    const callback = setTimeout(gameTick, Math.floor(1000 / FRAMERATE_HZ));
     
    try {
        const context = document.getElementById('screen').getContext('2d');
        context.drawImage(backgroundImageArray[0], 0, 0);
        for (let b = 1; b < backgroundImageArray.length; ++b) {
            const backgroundWidth = 272;
            for (let i = -1; i <= +1; ++i) {
                const offset = ((frame * b * 0.25) % backgroundWidth) + (i * backgroundWidth);
                context.drawImage(backgroundImageArray[b], offset, 40);
            }
        }
        context.fillStyle = '#333';
        context.fillRect(0, 200, 384, 24);

        for (let p = 0; p < 2; ++p) {
            const state = playerState[p];
            if (state.lt && ! state.rt) {
                state.x -= 3;
            } else if (state.rt && ! state.lt) {
                state.x += 3;
            }
            state.x = (state.x + width) % width;
            context.drawImage(characterImageArray[p], state.x - 134 / 2, height - 134);
        }

        context.fillStyle = '#dc0';
        context.font = "12px Arial";
        context.fillText("Frame " + frame, 10, 20);

        screenStream.getVideoTracks()[0].requestFrame();
        ++frame;
    } catch (err) {
        // If anything goes wrong, stop the game
        clearTimeout(callback);
        throw err;
    }
}


function startGuest() {
    console.log('startGuest');
    const hostID = window.location.search.substring(1);
    document.getElementById('urlbox').innerHTML = `You are the guest in room ${hostID}.<br>${INSTRUCTIONS}`;
    
    const peer = new Peer(generateUniqueID(), peerConfig);

    if (isPixelArt) {
        // Instead of showing the video directly, render it to the canvas
        // and then clean up the bits and render back to the canvas.
        const screen = document.getElementById('screen');
        const context = screen.getContext('2d');
        const video = document.getElementById('video');

        // On Safari, video will not update unless the video element is in the
        // DOM and visible, so we hide it behind the canvas instead of hiding
        // it completely (which is friendlier to the browser compositor).
        if (! isSafari) { video.style.visibility = 'hidden'; }
        
        function drawVideo() {
            //setTimeout(drawVideo, 1000 / FRAMERATE_HZ);
            requestAnimationFrame(drawVideo);
            context.drawImage(video, 0, 0, width, height);
            // Run right before vsync to eliminate latency between the
            // video update and the canvas update. This will overdraw if the monitor
            // runs at higher than FRAMERATE_HZ, but the client isn't
            // doing much work anyway. 
        }

        // Start the callback chain
        drawVideo();
    } else {
        document.getElementById('screen').remove();
    }

    peer.on('error', peerErrorHandler);
    
    peer.on('open', function (id) {
        let alreadyAddedThisCall = false;

        // PeerJS cannot initiate a call without a media stream, so the
        // client can't initiate the call. Instead, we have the client
        // initiate a data connection and then the host calls *back*
        // with the media stream.
        
        // When the host calls us
        peer.on(
            'call',
            function (mediaConnection) {
                console.log('host called back');

                // Answer the call but provide no media stream
                mediaConnection.answer(null);

                mediaConnection.on(
                    'stream',
                    function (hostStream) {
                        if (! alreadyAddedThisCall) {
                            alreadyAddedThisCall = true;
                            console.log('host answered');
                            document.getElementById('video').srcObject = hostStream;
                        } else {
                            console.log('rejected duplicate call');
                        }
                    },
                    
                    function (err) {
                        console.log('host stream failed with', err);
                    }
                ); //mediaConnection.on('stream')
            }); // peer.on('call')

        
        console.log('connect data to host');
        // This will trigger the host to call back with a mediaconnection as well
        const dataConnection = peer.connect(hostID, {reliable: true, serialization: 'json'});
        dataConnection.on('open', function () {
            console.log('data connection to host established');
            keepAlive(dataConnection);

            document.addEventListener('keydown', function (event) {
                dataConnection.send({type: 'keydown', keyCode: event.keyCode});
            });
            
            document.addEventListener('keyup', function (event) {
                dataConnection.send({type: 'keyup', keyCode: event.keyCode});
            });
        });
        

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
