"""
Script that implements the game network server.

The game server is an authoritative server used for both single-player and multi-player game sessions.
The server does, in fact, handles most of the game logic such as the terrain generation, terrain
modification, player inventories, loading, saving and much more.

The server runs asynchronously in a separate thread.

Some useful resources:
- https://gamedevacademy.org/streampeer-in-godot-complete-guide/

Author: Leonardo Spaccini
"""
extends Node

var serverThread : Thread;
var tcpServer : TCPServer;
var tcpConnections = {};

func initializeForSingleplayer():
	self.initialize("127.0.0.1", 42069, 1);
	return;

#listenPort = "*" (default), the server will listen on all available addresses (both IPv4 and IPv6).
#listenPort = "0.0.0.0" (for IPv4) or "::" (for IPv6), the server will listen on all available addresses matching that IP type.
#listenPort = any valid address (e.g. "192.168.1.101", "::1", etc), the server will only listen on the interface with that addresses
func initialize(listenIp: String, listenPort: int, maxConnections: int):
	print_rich("[color=magenta][SERVER] Initializing server (listening on: " + listenIp + ":" + str(listenPort) + "/tcp, max connections: " + str(maxConnections) + ")...");
	var lastErrorCode;
	
	# initialize TCP server...
	self.tcpServer = TCPServer.new();
	lastErrorCode = tcpServer.listen(listenPort, listenIp);
	if(lastErrorCode != OK): # TODO gestire meglio gli errori
		printerr("[SERVER] Could not initialize TCP server (error code: " + str(lastErrorCode) + ")");
		get_tree().quit(-1); 
		
	# initialize and start the server thread
	self.serverThread = Thread.new();
	lastErrorCode = self.serverThread.start(_serverLoop, Thread.PRIORITY_NORMAL);
	if(lastErrorCode != OK): # TODO gestire meglio gli errori
		printerr("[SERVER] Could not start server thread (error code: " + str(lastErrorCode) + ")");
		get_tree().quit(-1);
	
	print_rich("[color=magenta][SERVER] Server is now up and running!");
	return;

func _serverLoop():
	while(1): # while(tcpServer.is_listening()):
		_serverAcceptNewConnections();
		_serverProcessConnections();
	return;

func _serverAcceptNewConnections():
	while(tcpServer.is_connection_available()):
		var tcpConnection = tcpServer.take_connection() as StreamPeerTCP;
		var tcpConnectionAddress = tcpConnection.get_connected_host();
		var tcpConnectionPort = tcpConnection.get_connected_port();
		var tcpConnectionStatus = tcpConnection.get_status();
		var tcpConnectionSocket = tcpConnectionAddress + ":" + str(tcpConnectionPort);
		print_rich("[color=magenta][SERVER] Accepted connection from " + tcpConnectionSocket + "/tcp (status: " + GameNetUtils.parseTcpConnectionStatus(tcpConnectionStatus) + ")");
		# Store the connection inside the dictionary, using the socket as a key (since it is unique).
# tcpConnection.set_no_delay(true);
		tcpConnections[tcpConnectionSocket] = tcpConnection;
	return;

func _serverProcessConnections():
	for tcpConnectionSocket in tcpConnections:
		var tcpConnection = tcpConnections[tcpConnectionSocket];
		_serverProcessConnection(tcpConnection);
	return;

func _serverProcessConnection(tcpConnection: StreamPeerTCP):
# tcpConnection.poll(); 
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus == StreamPeerTCP.STATUS_CONNECTED):
		var streamBufferLengthBytes = tcpConnection.get_available_bytes();
		if(streamBufferLengthBytes > 0):
			var data = tcpConnection.get_data(streamBufferLengthBytes);
			var errorCode = data[0]; # TODO handle errors
			var streamBufferBytes = data[1];
			_serverProcessPacket(tcpConnection, streamBufferBytes);
	return;

func _serverProcessPacket(tcpConnection: StreamPeerTCP, packetBytes: Array):
	# FIXME non è detto che il pacchetto che ricevo sia completo. in caso non lo sia,
	# memorizzarlo in un buffer specifico di ogni connessione e riprovare successivamente.
	# print_rich("[color=magenta][SERVER] Receiving packet from " + tcpConnectionSocket + " with content bytes: " + str(packetBytes));
	#var packetLen = (packetBytes[0] << 8) + packetBytes[1];
	var packetCommand = packetBytes[0];
	match packetCommand:
		GameNetPacketManager.PacketType.TERRAIN_DATA_REQ:
			_processTerrainDataRequest(tcpConnection, packetBytes) 
	return;

func _processTerrainDataRequest(tcpConnection: StreamPeerTCP, packetBytes: Array):
	var tcpConnectionAddress = tcpConnection.get_connected_host();
	var tcpConnectionPort = tcpConnection.get_connected_port();
	var tcpConnectionSocket = tcpConnectionAddress + ":" + str(tcpConnectionPort) + "/tcp";
	var requestContent = GameNetPacketManager.parseTerrainDataReq(packetBytes);
	var requestedChunkX = requestContent[0];
	var requestedChunkZ = requestContent[1];
	# FIXME non è detto che il pacchetto che ricevo sia completo. in caso non lo sia,
	# memorizzarlo in un buffer specifico di ogni connessione e riprovare successivamente.
	print_rich("[color=magenta][SERVER] <" + tcpConnectionSocket + "> Receiving terrain data request for chunk (" + str(requestedChunkX) + ", " + str(requestedChunkZ) + ")...");
	
	# Response
	_responseTerrainData(tcpConnection, requestedChunkX, requestedChunkZ);
	return;

func _responseTerrainData(tcpConnection: StreamPeerTCP, chunk_x: int, chunk_z: int):
	var tcpConnectionAddress = tcpConnection.get_connected_host();
	var tcpConnectionPort = tcpConnection.get_connected_port();
	var tcpConnectionSocket = tcpConnectionAddress + ":" + str(tcpConnectionPort) + "/tcp";
	print_rich("[color=magenta][SERVER] <" + tcpConnectionSocket + "> Sending terrain data response for chunk (" + str(chunk_x) + ", " + str(chunk_z) + ")...");
	# SEND BACK TEST TERRAIN DATA
	var terrainData = [1,2,3,4];
	var response = GameNetPacketManager.createTerrainDataRes(chunk_x, chunk_z, terrainData);
	_sendResponse(tcpConnection, response);
	return;
	
func _sendResponse(tcpConnection: StreamPeerTCP, packetBytes: PackedByteArray):
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus != StreamPeerTCP.STATUS_CONNECTED):
		printerr("[SERVER] Could not send response to client! Connection status is \": " + GameNetUtils.parseTcpConnectionStatus(tcpConnectionStatus) + "\"");
		return;
	var errorCode = tcpConnection.put_data(packetBytes);
	if(errorCode != Error.OK):
		printerr("[SERVER] Could not send response to client! (error code: " + str(errorCode) + ")");
	return;
