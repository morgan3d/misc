'use strict';

function getMedia() {
    navigator.mediaDevices.getUserMedia({audio: true, video: {facingMode: "user"}})
        .then(function(mediaStream) {
            console.log('ok!');
        })
        .catch(function(err) {
            console.log(err);
        });
}

/* Write to the clipboard. Hard-coded to the specific URL box */
function clipboardCopy(text) {
    const urlTextBox = document.getElementById('urlTextBox');
    urlTextBox.select(); 
    urlTextBox.setSelectionRange(0, 99999);
    document.execCommand('copy');
    setTimeout(function () { urlTextBox.blur(); });
}
    

let peer = new Peer();

function main() {
    if (window.location.search !== '') {
        // Guest
        let hostID = window.location.search.substring(1);
        document.getElementById('urlbox').innerHTML = `You are a guest of ${hostID}.`;
        
        // let conn = peer.connect(hostID);
        
    } else {
        // Host
        peer.on('open', function(id) {
            const url = 'https://morgan3d.github.io/misc/jschat/?' + id;
            document.getElementById('urlbox').innerHTML =
                `You are the host. Others can join at:<br><span style="white-space:nowrap; cursor: pointer; font-weight: bold" onclick="clipboardCopy('${url}')" title="Copy to Clipboard"><input title="Copy to Clipboard" type="text" value="${url}" id="urlTextBox">&nbsp;<b style="font-size: 125%">⧉</b></span>`;
        });
        
        peer.on('call', function(call) {
            // Answer the call, providing our mediaStream
            call.answer(mediaStream);
        });
    }
}
