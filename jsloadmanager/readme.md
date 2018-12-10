Load manager for asynchronous resource loading requests in
complicated loading trees, with post processing of resources and
caching. 

This is useful for loading files that recursively trigger the loading
of other files without having to manage promises or lots of callbacks
explicitly. I originally used it for implementing project loading in a
web integrated development environment.

The routines are:

- dataManager = new LoadManager()
- dataManager.fetch()
- dataManager.end()
 
No source dependencies. Requires ES5 for the Map class and for..of loop,
which all modern browsers support. That is, doesn't work on Internet
Explorer, but works on everything else including Safari, Firefox, 
Chrome, Edge, Opera, mobile versions, etc.

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
