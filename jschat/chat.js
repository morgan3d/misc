'use strict';

function startWebCam(callback) {
    navigator.mediaDevices.getUserMedia({audio: true, video: {facingMode: "user"}})
        .then(callback)
        .catch(function(err) {
            console.log(err);
        });
}


function addWebCamView(caption, mediaStream, playAudio) {
    const videobox = document.getElementById('videobox');

    const frame = document.createElement('div');
    frame.className = 'videoFrame';
    frame.innerHTML = `<div style="width: 100%">${caption}</div>`;
    const video = document.createElement('video');
    video.setAttribute('autoplay', true);
    video.setAttribute('controls', true);
    video.srcObject = mediaStream;
    video.muted = ! playAudio;
    frame.appendChild(video);
    videobox.appendChild(frame);
}


/* Write to the clipboard. Hard-coded to the specific URL box */
function clipboardCopy(text) {
    const urlTextBox = document.getElementById('urlTextBox');
    urlTextBox.select(); 
    urlTextBox.setSelectionRange(0, 99999);
    document.execCommand('copy');
    setTimeout(function () { urlTextBox.blur(); });
}
    
function startGuest() {
    let hostID = window.location.search.substring(1);
    document.getElementById('urlbox').innerHTML = `You are a guest of ${hostID}.`;
    
    startWebCam(function (mediaStream) {
        addWebCamView('You', mediaStream, false);
        let call = peer.call(hostID, mediaStream);
        
        call.on('stream', function (hostStream) {
            addWebCamView('Host', hostStream, true);
        });
    });
}


function startHost() {
    peer.on('open', function(id) {
        const url = 'https://morgan3d.github.io/misc/jschat/?' + id;
        document.getElementById('urlbox').innerHTML =
            `You are the host. Others can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;
    });
    
    startWebCam(function (mediaStream) {
        addWebCamView('You', mediaStream, false);
        
        peer.on('call', function(call) {
            // Answer the call, providing our mediaStream
            call.answer(mediaStream);

            // When the client connects, add its stream
            call.on('stream', function (guestStream) {
                addWebCamView('Guest', guestStream, true);
            });
        });
    });
}


let peer = new Peer();

function main() {
    if (window.location.search !== '') {
        startGuest();        
    } else {
        startHost();
    }
}
