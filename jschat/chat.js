/*
 From https://github.com/morgan3d/misc/

 Created by Morgan McGuire in 2020
 Released into the public domain
*/
'use strict';

function startWebCam(callback) {
    console.log('startWebCam');
    navigator.mediaDevices.getUserMedia({audio: true, video: {facingMode: "user"}})
        .then(callback)
        .catch(function(err) {
            console.log(err);
        });
}


function addWebCamView(caption, mediaStream, playAudio) {
    console.log('addWebCamView for ' + caption);
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
    console.log('startGuest');
    let hostID = window.location.search.substring(1);
    document.getElementById('urlbox').innerHTML = `You are a guest of ${hostID}.`;
    
    peer = new Peer();

    peer.on('open', function (id) {
        startWebCam(function (mediaStream) {
            console.log('web cam started');
            
            addWebCamView('You', mediaStream, false);
            
            console.log('call host');
            let call = peer.call(hostID, mediaStream);
            
            call.on('stream',
                    function (hostStream) {
                        console.log('host answered');
                        addWebCamView('Host', hostStream, true);
                    },
                    
                    function (err) {
                        console.log('host stream failed with', err);
                    }
                   ); //call.on('stream')
        }); // startWebCam
    }); // peer.on('open')
}


function startHost() {
    console.log('startHost');

    // The peer must be created RIGHT before open is registered,
    // otherwise we could miss it.
    peer = new Peer();
    peer.on('open',
            function(id) {
                console.log('host peer opened with id ' + id);
                const url = 'https://morgan3d.github.io/misc/jschat/?' + id;
                document.getElementById('urlbox').innerHTML =
                    `You are the host. Others can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;

                
    startWebCam(function (mediaStream) {
        addWebCamView('You', mediaStream, false);
        
        peer.on('call',
                function(call) {
                    console.log('guest called');
                    
                    // Answer the call, providing our mediaStream
                    call.answer(mediaStream);
                    
                    // When the client connects, add its stream
                    call.on('stream',
                            function (guestStream) {
                                console.log('guest streamed');
                                addWebCamView('Guest', guestStream, true);
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
            },
            function (err) {
                console.log('host open failed with', err);
            }
           ); // peer.on('open')
    
}


let peer;

function main() {
    if (window.location.search !== '') {
        startGuest();        
    } else {
        startHost();
    }
}
