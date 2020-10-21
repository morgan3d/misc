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

/* Milliseconds since epoch in UTC. Used for detecting when the last keepAlive
   was received. */
function now() {
    return new Date().getTime();
}

function loadImage(url) {
    const image = new Image();
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


/* Write to the clipboard. Hard-coded to the specific URL box */
function clipboardCopy(text) {
    const urlTextBox = document.getElementById('urlTextBox');
    urlTextBox.select(); 
    urlTextBox.setSelectionRange(0, 99999);
    document.execCommand('copy');
    setTimeout(function () { urlTextBox.blur(); });
}


function startHost() {
    console.log('startHost');

    // The peer must be created RIGHT before open is registered,
    // otherwise we could miss it.
    const peer = new Peer(generateUniqueID());

    peer.on('error', function (err) {
        console.log('error in host:', err);
    });
    
    peer.on('open', function(id) {
        console.log('host peer opened with id ' + id);
        const url = 'https://morgan3d.github.io/misc/jsremotegame/?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. One guest can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;
    }); // peer.on('open'

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
    const callback = setTimeout(gameTick, 1000/60);
     
    try {
        const context = document.getElementById('screen').getContext('2d');
        const width = 384;
        const height = 224;
        
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
    
    const peer = new Peer(generateUniqueID());

    peer.on('error', function (err) {
        console.log('error in guest:', err);
    });
    
    peer.on('open', function (id) {
    }); // peer.on('open
}



function main() {
    document.getElementById('urlbox').style.visibility = 'visible';
    if (window.location.search !== '') {
        startGuest();        
    } else {
        startHost();
    }
}
