/**
  \file LoadManager.js

  Load manager for asynchronous resource loading requests in
  complicated loading trees, with post processing of resources and
  caching. This is useful for loading files that recursively trigger
  the loading of other files without having to manage promises or lots
  of callbacks explicitly.

  The routines are:

  - dataManager = new LoadManager()
  - dataManager.fetch()
  - dataManager.end()
 
  ----------------------------------------------------

  This implementation uses XMLHttpRequest internally. There is a newer
  browser API for making HTTP requests called Fetch
  (https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)
  that uses Promises; it is more elegant in some ways but also more
  complicated because it relies on more language features. Since the
  current implementation is working fine, I don't intend to port to
  the Fetch API until some critical feature (such as the explicit
  headers or credentialing) is required.

  ----------------------------------------------------

  Open Source under the BSD-2-Clause License:

  Copyright 2018 Morgan McGuire, https://casual-effects.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// We don't support a native 'xml' fetch because XMLHttpRequest.responseXML
// doesn't work within web workers.

/** Begin a series of fetches. Options:

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    {
      callback : function () {...},
      errorCallback : function () {...},

      // If true, parse JSON locally so that better error messages
      // can be provided than via server validation.
      parseJSONLocally : false,

      // If true, append '?' to each URL when fetching to force 
      // it to be reloaded from the server, or at least validated.
      // Defaults to false.
      forceReload : false
    }
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Invoke \a callback when all fetch() calls have been processed, 
    or \a errorCallback when the first fails.  */
function LoadManager(options) {

    // Map from url to:
    // {
    //   raw      : result of the fetch
    //   status   : 'loading', 'success', 'failure'
    //   post     : Map from post-processing functions (and null) to:
    //      {
    //            value: value
    //            callbacks: array of callbacks to invoke when data arrives and is post-processed
    //            errorCallbacks: etc.
    //      }
    // }
    
    this.resource = new Map();
    this.crossOrigin = 'anonymous';
    this.pendingRequests = 0;

    // 'accepting requests', 'loading', 'complete', 'failure'
    this.status = 'accepting requests';

    this.forceReload = options.forceReload || false;

    // Invoke when pendingRequests hits zero if status is not 'failure'
    this.callback = options.callback;
    this.errorCallback = options.errorCallback;
}


/**
   Invoke \a callback on the contents of \a url after the specified
   post-processing function, or \a errorCallback on failure. Results
   are cached both before and *after* post-processing, so that there
   is no duplication of the HTTP request, the post processing, or any
   of the storage.

   Set \a postProcessing to null to get the raw result in the callback.

   \param url String, mandatory
   \param type Type of data at the URL: 'text', 'json', 'arraybuffer', or 'image' (uses Image)
   \param postProcess(rawData, url) function
   \param callback(data, rawData, url, postProcess)
   \param errorCallback(reason, url) optional. Invoked on failure if some other load has not already failed.

   You will receive a failure if the post process fails.
 */
LoadManager.prototype.fetch = function (url, type, postProcess, callback, errorCallback) {
    console.assert(typeof type === 'string', 'type must be a string');
    console.assert((typeof postProcess === 'function') || !postProcess,
                   'postProcess must be a function, null, or undefined');
    
    if (this.status === 'failure') { return; }
    const LM = this;
    
    console.assert(this.status !== 'complete',
                   'Cannot call LoadManager.fetch() after LoadManager.end()');

    let rawEntry = this.resource.get(url);
    
    if (! rawEntry) {
        ++this.pendingRequests;
        
        // Not in the cache, so create it
        rawEntry = {
            url:            url,
            raw:            undefined,
            status:         'loading',
            failureMessage: undefined,
            post:           new Map()
        };
        
        this.resource.set(url, rawEntry);

        function onLoadSuccess() {
            if (LM.status === 'failure') { return; }
            rawEntry.status = 'success';
            // Run all post processing and callbacks
            for (let [p, v] of rawEntry.post) {
                v.value = p ? p(rawEntry.raw, rawEntry.url) : rawEntry.raw;
                
                for (let c of v.callbackArray) {
                    // Note that callbacks may increase LM.pendingRequests
                    if (c) { c(v.value, rawEntry.raw, rawEntry.url, p); }
                }
            }

            --LM.pendingRequests;
            if ((LM.pendingRequests === 0) && (LM.status === 'loading')) {
                LM.status = 'complete';
                // Throw away all of the data
                LM.resource = null;
                if (LM.callback) { LM.callback(); }
            }
        }

        function onLoadFailure() {
            if (LM.status === 'failure') { return; }
            rawEntry.status = 'failure';
            rawEntry.failureMessage = '';

            // Run all failure callbacks
            for (let [p, v] of rawEntry.post) {
                for (let c of v.errorCallbackArray) {
                    if (c) { c(rawEntry.failureMessage, rawEntry.url); }
                }
            }
            LM.status = 'failure';
            LM.resource = null;
            if (LM.errorCallback) { LM.errorCallback(); }
        }        
        
        // Fire off the asynchronous request
        if (type === 'image') {
            // Allow loading from other domains and reading the pixels (CORS).
            // Works only if the other site allows it; which github does and
            // for which we can use a proxy and an XMLHttpRequest as an
            // annoying workaround if necessary.
            const image = new Image();
            rawEntry.raw = image;
            if (LM.crossOrigin) {
                image.crossOrigin = LM.crossOrigin;
            }
            image.onload = onLoadSuccess;
            image.onerror = onLoadFailure;
            image.src = url + (LM.forceReload ? '?' : '');
        } else {
            const xhr = new XMLHttpRequest();

            // Force a check for the latest file using a query string
            xhr.open('GET', url + (LM.forceReload ? '?' : ''), true);
            if (LM.parseJSONLocally && (type === 'json')) {
                xhr.responseType = 'text';
            } else {
                xhr.responseType = type;
            }
            
            xhr.onload = function() {
                const status = xhr.status;
                if (status === 200) {
                    if (xhr.response) {
                        if (LM.parseJSONLocally && (type === 'json')) {
                            // now parse
                            try {
                                rawEntry.raw = JSON.parse(xhr.response);
                                onLoadSuccess();
                            } catch (e) {
                                rawEntry.failureMessage = "JSON parse error: " + e;
                                onLoadFailure();
                            }
                        } else {
                            rawEntry.raw = xhr.response;
                            onLoadSuccess();
                        }
                    } else {
                        rawEntry.failureMessage = "File was in the incorrect format";
                        onLoadFailure();
                    }
                } else {
                    rawEntry.failureMessage = "Server returned error " + status;
                    onLoadFailure();
                }
            };
            xhr.send();
        } // if XMLHttp
    }

    let postEntry = rawEntry.post.get(postProcess);
    if (! postEntry) {
        // This is the first use of this post processing
        if (rawEntry.status === 'success') {
            // Run the post processing right now
            postEntry = {
                value: postProcess ? postProcess(rawEntry.raw, rawEntry.url) : rawEntry.raw,
            };
            if (callback) { callback(postEntry.value, rawEntry.raw, url, postProcess); }
        } else if (rawEntry.status === 'failure') {
            if (errorCallback) { errorCallback(rawEntry.failureMessage, url); }
        } else {
            // Schedule the callback
            postEntry = {
                value: null,
                callbackArray: [callback],
                errorCallbackArray: [errorCallback]
            };
        }
        rawEntry.post.set(postProcess, postEntry);
    } else if (rawEntry.status === 'success') {
        // Run the callback now
        if (callback) { callback(postEntry.value, rawEntry.raw, url, postProcess); }
    } else if (rawEntry.status === 'failure') {
        // Run the callback now
        if (errorCallback) { errorCallback(rawEntry.failureMessage, url); }
    } else {
        // Schedule the callback
        postEntry.callbackArray.push(callback);
        postEntry.errorCallbackArray.push(errorCallback);
    }
}


/** 
    Call after the last fetch.
*/
LoadManager.prototype.end = function () {
    if (this.status !== 'failure') {
        console.assert(this.status === 'accepting requests');

        if (this.pendingRequests === 0) {
            // Immediately invoke the callback
            this.status = 'complete';
            // Throw away all of the data
            this.resource = null;
            if (this.callback) { this.callback(); }
        } else {
            // Tell the loading callbacks that they
            // should invoke the completion callback.
            this.status = 'loading';
        }
    }
}


