"""
Script that implements a generic network server.

A network server is a singleton instance that needs to be initialized manually.
Once initialized, the network server will accept and manage TCP connections from clients,
using byte buffers to handle the incoming and outgoing streams of bytes.

A network server provides the functionalities to read-from and write-into these byte buffers,
but it is not concerned about the interpretation of their meaning, which is instead delegated
to other components with an higher level of abstraction (for example the "MessageServer").

Some useful resources:
- https://gamedevacademy.org/streampeer-in-godot-complete-guide/

Author: Leonardo Spaccini
"""
extends Node

# TODO la dimensione del ring buffer è estremamente elevata. sarebbe il caso di
# implementare un meccanismo di compressione/decompressione del traffico TCP
# per essere sicuri di poter memorizzare tutti i messaggi

const TCP_CONNECTION_RING_BUFFER_SIZE = 131072; # 128 KB

var serverThread : Thread;
var tcpServer : TCPServer;
var tcpConnections = Dictionary();

"""
Class that represents a TCP connection from the client to the server.
"""
class TCPConnection:
	var connection: StreamPeerTCP;
	var ringBuffer: RingBuffer;
	
	func _init(connection: StreamPeerTCP):
		self.connection = connection;
		self.ringBuffer = RingBuffer.new(TCP_CONNECTION_RING_BUFFER_SIZE);
		return;

# TODO DOCS
func initializeForSingleplayer():
	self.initialize("127.0.0.1", 42069, 1);
	return;

#listenPort = "*" (default), the server will listen on all available addresses (both IPv4 and IPv6).
#listenPort = "0.0.0.0" (for IPv4) or "::" (for IPv6), the server will listen on all available addresses matching that IP type.
#listenPort = any valid address (e.g. "192.168.1.101", "::1", etc), the server will only listen on the interface with that addresses
func initialize(listenIp: String, listenPort: int, maxConnections: int):
	print_rich("[color=magenta][SERVER] Initializing network connectivity (listening on: " + listenIp + ":" + str(listenPort) + "/tcp, max connections: " + str(maxConnections) + ")...");
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

func getConnections():
	return tcpConnections;

#func getConnection(socket):
#	return tcpConnections[socket];
	
func getBytes(socket):
	var tcpConnection = tcpConnections[socket];
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus == StreamPeerTCP.STATUS_CONNECTED):
		return tcpConnection.get_available_bytes();
	return 0;
	
func readBytes(socket, count):
	var tcpConnection = tcpConnections[socket];
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus == StreamPeerTCP.STATUS_CONNECTED):
		var streamBufferLengthBytes = tcpConnection.get_available_bytes();
		if(streamBufferLengthBytes > 0):
			var data = tcpConnection.get_data(streamBufferLengthBytes);
			var errorCode = data[0]; # TODO handle errors
			var streamBufferBytes = data[1];
			return streamBufferBytes;
	return [];
	
func writeBytes(socket, packetBytes: PackedByteArray):
	var tcpConnection = tcpConnections[socket];
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus != StreamPeerTCP.STATUS_CONNECTED):
		printerr("[SERVER] Could not send response to client! Connection status is \": " + GameNetUtils.parseTcpConnectionStatus(tcpConnectionStatus) + "\"");
		return;
	var errorCode = tcpConnection.put_data(packetBytes);
	if(errorCode != Error.OK):
		printerr("[SERVER] Could not send response to client! (error code: " + str(errorCode) + ")");
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
		tcpConnections[tcpConnectionSocket] = TCPConnection.new(tcpConnection);
	return;

func _serverProcessConnections():
	for tcpConnectionSocket in tcpConnections:
		var tcpConnection = tcpConnections[tcpConnectionSocket] as TCPConnection;
		_serverProcessConnection(tcpConnection);
	return;

func _serverProcessConnection(tcpConnection: TCPConnection):
	var streamTcp = tcpConnection.connection;
	streamTcp.poll(); 
	var streamTcpStatus = streamTcp.get_status();
	if(streamTcpStatus == StreamPeerTCP.STATUS_CONNECTED):
		var streamBufferLengthBytes = streamTcp.get_available_bytes();
		if(streamBufferLengthBytes > 0):
			var writableBytes = tcpConnection.ringBuffer.getWritableBytesCount();
			var maxReceivableBytes = min(streamBufferLengthBytes, writableBytes);
			var data = streamTcp.get_data(maxReceivableBytes);
			var errorCode = data[0]; # TODO handle errors
			var streamBufferBytes = data[1];
			tcpConnection.ringBuffer.writeBytes(streamBufferBytes);
	return;

#func _serverProcessPacket(tcpConnection: StreamPeerTCP, packetBytes: Array):
#	var tcpConnectionAddress = tcpConnection.get_connected_host();
#	var tcpConnectionPort = tcpConnection.get_connected_port();
#	var tcpConnectionSocket = tcpConnectionAddress + ":" + str(tcpConnectionPort);
#	var connection = tcpConnections[socket];
	# print_rich("[color=magenta][SERVER] Receiving packet from " + tcpConnectionSocket + " with content bytes: " + str(packetBytes));
	#var packetLen = (packetBytes[0] << 8) + packetBytes[1];
#	return;
