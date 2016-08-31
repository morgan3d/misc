/**
   INSTALLATION:
   
   Install Node.js (http://nodejs.org) for your platform.  Put
   relay.js in a directory by itself (anywhere), and then in that
   directory run:

     sudo npm install socket.io


   RUNNING:

   Launch the relay under the Node.js program by executing the command:

      sudo node relay.js <portnum>

   at the command line.  It will print the server's address immediately.
   That is the address that the clients need to connect.

   relay.js allows the browser-based server program and browser-based
   client programs to communicate with each other.  Note that both the
   application server and client are clients of the relay server.  



   API:

   See clientserver/index.html for an example.

   The low-level API of the application communicating with the relay
   follows.  The codeheart.js network API sits on top of this
   low-level API.


   Server API:

   <pre>
     // Connect:
     var socket = io.connect('http://relayserver');

     socket.on('connect', function() {
        socket.emit('server init', {gameName: 'game name', serverName: 'server name'});
        });

     // Receive a new client:
     socket.on('client connect', function(msg) {
        // msg.clientID is the ID of the client
     });

     // Send a message to one client:
     socket.emit('message', {clientID: id, data: payload});

     // Send a message to all clients:
     socket.emit('message', {clientID: '*', data: payload});

     // Send a message to all clients except one (handy for propagating information):
     socket.emit('message', {clientID: '* - ' + id, data: payload});

     // Receive a message from a client
     socket.on('message', function(msg) {
        // msg.clientID is the source
	// msg.data is the body of the message
     });

     socket.on('client disconnect', function(msg) {
       // msg.clientID is the client
     });
  </pre>
     
  Client API: 
  <pre>
     // Connect:
     var socket = io.connect('http://relayserver');
     
     socket.on('connect', function() {
        socket.emit('client init', {gameName: 'game name', serverName: 'server name'});
        });

     // Handle server disconnect:
     socket.on('disconnect', function(msg) { ... });

     // Send a message to the server:
     socket.emit('message', {data: payload});

     // Receive a message from the server:
     socket.on('message', function(msg) {
       // msg.data is the payload
     });
  </pre>
 */

/** Set to true to enable debug output for testing the relay itself. */
var debug = true;

var PORT = process.argv[2] ? parseInt(process.argv[2]) : 1080;

var dns = require('dns');
var os  = require('os');

dns.lookup(os.hostname(), function (err, addr, fam) {
  console.log('Relay running at http://' + os.hostname() + ':' + PORT + 
              ' (http://' + addr + ':' + PORT + ')');
});

var io = require('socket.io').listen(PORT);

if (debug) console.log('PORT = ' + PORT);

//---------------------------------------------------------------------------

/** A server of game. If advertise is false, does not appear in
    the browsable list.
 */
function Server(game, name, socket) {
    this.game      = game;
    this.name      = name;
    this.socket    = socket;
    this.advertisement = null;

    // Table mapping client IDs to Clients
    this.clientTable   = {};
}

Server.prototype.addClient = function(client) {
    this.clientTable[client.id] = client;
    this.socket.emit('client connect', {clientID: client.id});
}


Server.prototype.removeClient = function(client) {
    var client = this.clientTable[client.id];

    if (client) {
	// Tell the server
	this.socket.emit('client disconnect', {clientID: client.id});

	// Remove the client (the syntax HAS to be exactly as below;
	// "delete client" doesn't work)
	delete this.clientTable[client.id];

	// Close the connection to the client
	client.socket.disconnect();
    }
}


Server.prototype.forEachClient = function(callback) {
    var id;
    for (id in this.clientTable) {
	callback(this.clientTable[id]);
    }
}

//---------------------------------------------------------------------------

var uniqueID = (function() {
    var lastID = 0;
    var MAX_EXACT_INT = Math.pow(2, 53) - 1;
    return function() {
	var id = 'ID' + lastID;
	// Prevent overflow (realistically impossible)
	lastID = (lastID + 1) % MAX_EXACT_INT;
	return id;
    }
})();


function Client(server, socket) {
    this.server    = server;
    this.socket    = socket;

    // Unique ID
    this.id        = 'client' + uniqueID();
}

//---------------------------------------------------------------------------

/** 
    Maps game names to a table mapping server names 
    to instances.
 */
var gameTable = {};

function getServer(gameName, serverName) {
    var serverTable = gameTable[gameName];
    if (serverTable) {
	var server = serverTable[serverName];
	if (server) {
	    return server;
	}
    }

    return null;
}

/** Values for type */
var SERVER = 'SERVER';
var CLIENT = 'CLIENT';

io.sockets.on('connection', function(socket) {
    
    var me   = null;
    var type = null;

    if (debug) console.log('Connection received');
    
    //-----------------------------------------------------------------------
    // Server communication

    // Sent by a server registering itself
    // data = {gameName:, serverName:}
    socket.on('server init', function(data) {
        if (debug) console.log('on server init');

	me = new Server(data.gameName, data.serverName, socket);
	var previous = getServer(data.gameName, data.nameName);

	type = SERVER;
	if (previous === null) {
	    // This is a new server

            // Allocate an entry for the game if needed
            if (gameTable[data.gameName] === undefined) {
                gameTable[data.gameName] = {}
            }

            // Register the server
	    gameTable[data.gameName][data.serverName] = me;
            if (debug) console.log('registering "' + data.gameName + '"/"' + data.serverName + '"');

	    // Register the disconnect handler
	    socket.on('disconnect', function() {
		// Tell all clients that the server is gone
		me.forEachClient(function(client) { me.removeClient(client); });
	    });

	    // Message received from the server to be relayed to one or more clients
	    //
	    // data = {clientID: ID or "*", data: arbitrary}
	    socket.on('message', function(data) {
                if (debug) console.log('Received message for clientID: ' + data.clientID);

		// Send to the client based on the clientID in the 
		if (data.clientID == '*') {
                    if (debug) console.log('sending to everyone');

		    // Message for all clients
		    me.forEachClient(function(client) { 
                        if (debug) console.log('Sending to client');
                        client.socket.emit('message', data); 
                    });

		} else if (data.clientID.substring(0, 4) == '* - ') {
		    // Message for all but one client
		    var excludeID = data.clientID.substring(4);
		    me.forEachClient(function(client) {
			if (client.id != excludeID) {
			    client.socket.emit('message', data); 
			}
		    });
		} else {
		    // Message for one client
		    var client = me.clientTable[data.clientID];
		    client.socket.emit('message', data);
		}
	    });


	} else {
	    socket.emit('error', 'A server already exists with that name.');
	    socket.disconnect();
	}
    });


    //-----------------------------------------------------------------------
    // Client communication

    // Sent by the client opening its relayed connection to a server
    // data = {game: g, server: c}
    socket.on('client init', function (data) {
        if (debug) console.log('on client init');

	type = CLIENT;

        if (debug) console.log('on client init');
        if (debug) console.log('looking for "' + data.gameName + '"/"' + data.serverName + '"');
	var server = getServer(data.gameName, data.serverName);

	if (server !== null) {
	    me = new Client(server, socket);
	    // Tell the server that it has a new client
	    server.addClient(me);

	    // Message received from a client to be relayed to the server
	    // msg = {data: arbitrary} (all other fields reserved)
	    socket.on('message', function(msg) {
		// Wrap the mssage
		msg.clientID = me.id;
		me.server.socket.emit('message', msg);
	    });

	    // Register the disconnect handler
	    socket.on('disconnect', function() {
		// Tell the server that I've disconnected
		server.removeClient(me);
	    });

	} else {
	    socket.emit('error', 'There is no server with that name.');
	    socket.disconnect();
	}
    });


});
