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

const FRAMERATE_HZ = 60;

const width = 384;
const height = 224;

/* Set to true to force the client to try to clean up the image after
   video decompression */
const isPixelArt = true;

const peerConfig = {debug: 1};

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
            // Ending the iterative callback chain should allow garbage collection to occur
            // and destroy all resources
        } else {
            // console.log('sent KEEP_ALIVE message');
            dataConnection.send(KEEP_ALIVE_MESSAGE);

            // Show or hide the connection warning as appropriate. Note that the element might not exist
            // right at the beginning of the connection.
            const connectionIsBad = lastTime && (currentTime - lastTime >= 2 * KEEP_ALIVE_INTERVAL_MS);
            /*
            const warningElement = document.querySelector('#' + elementID + ' .warning');
            if (warningElement) {
                warningElement.style.visibility = connectionIsBad ? 'visible' : 'hidden';
            }*/

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

function startHost() {
    console.log('startHost');

    // The stream will fail silently when running on a non-https server
    if (location.protocol !== 'https:') {
        alert('canvas.captureStream() requires https, so this demo will not work on this server');
    }
    
    screenStream = document.getElementById('screen').captureStream(FRAMERATE_HZ);
    
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

    peer.on('error', function (err) {
        console.log('error in host:', err);
    });
    
    peer.on('open', function(id) {
        console.log('host peer opened with id ' + id);
        const url = location.href + '?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. One guest can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;

        peer.on('connection', function (dataConnection) {
            console.log('data connection to guest established');

            console.log('calling the guest back with the stream');
            const mediaConnection = peer.call(dataConnection.peer, screenStream);
            
            // TODO
            // keepAlive(dataConnection);
        });
        
    }); // peer.on('open')

    // Start the game loop
    gameTick();
}

let frame = 0;
function gameTick() {
    // Use setTimeout instead of
    // requestAnimationFrame. requestAnimationFrame runs at the
    // display rate, and I want a 60 Hz locked. This is not the
    // optimal way to accomplish that; see the quadplay source for a
    // more precise example.
    const callback = setTimeout(gameTick, 1000 / FRAMERATE_HZ);
     
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
    
        context.drawImage(characterImageArray[0], 16 + 16 * Math.cos(frame * 0.02), height - 134);
        context.drawImage(characterImageArray[1], width - 134 - (16 + 16 * Math.cos(frame * 0.03 + 1)), height - 134);

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
    document.getElementById('urlbox').innerHTML = `You are the guest in room ${hostID}.`;
    
    const peer = new Peer(generateUniqueID(), peerConfig);

    if (isPixelArt) {
        // Instead of showing the video directly, render it to the canvas
        // and then clean up the bits and render back to the canvas.
        const screen = document.getElementById('screen');
        const context = screen.getContext('2d');
        const video = document.getElementById('video');
        video.style.visibility = 'hidden';
        
        function drawVideo() {
            context.drawImage(video, 0, 0, width, height);
            // Run right before vsync to eliminate latency between the
            // video update and the. This will overdraw if the monitor
            // runs at higher than FRAMERATE_HZ, but the client isn't
            // doing much work anyway.
            requestAnimationFrame(drawVideo);
        }

        // Start the callback chain
        drawVideo();
    } else {
        document.getElementById('screen').remove();
    }

    peer.on('error', function (err) {
        console.log('error in guest:', err);
    });
    
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
        const dataConnection = peer.connect(hostID);
        dataConnection.on('open', function () {
            console.log('data connection to host established');
            // TODO
            //keepAlive(dataConnection);
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
