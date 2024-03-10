"""
Script that implements the game network client.

Author: Leonardo Spaccini
"""
extends Node

var tcpConnection : StreamPeerTCP;

func initializeForSingleplayer():
	self.initialize("127.0.0.1", 42069);
	return;
	
func initialize(serverIp: String, serverPort: int):
	print_rich("[color=cyan][CLIENT] Attempting to connect to server (" + serverIp + ":" + str(serverPort) + "/tcp)...");
	var lastErrorCode;
	
	self.tcpConnection = StreamPeerTCP.new();
	self.tcpConnection.set_no_delay(true);
	lastErrorCode = tcpConnection.connect_to_host(serverIp, serverPort);
	if(lastErrorCode != Error.OK): # TODO gestire meglio gli errori
		printerr("[CLIENT] Could not connect to server (error code: " + str(lastErrorCode) + ")");
		get_tree().quit(-1);
	
	print_rich("[color=cyan][CLIENT] Successfully connected to server!");
	
	
	# BEGIN TEST
	tcpConnection.poll(); # forzo il primo polling per avere una connessione stabilita
	_requestTerrainData(0, 0);
	# ENDOF TEST
	return;
	
func _physics_process(_delta):
	_clientProcessConnection();
	return;
	
func _clientProcessConnection():
	tcpConnection.poll(); 
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus == StreamPeerTCP.STATUS_CONNECTED):
		var streamBufferLengthBytes = tcpConnection.get_available_bytes();
		if(streamBufferLengthBytes > 0):
			var data = tcpConnection.get_data(streamBufferLengthBytes);
			var errorCode = data[0]; # TODO handle errors
			var streamBufferBytes = data[1];
			_clientProcessPacket(tcpConnection, streamBufferBytes);
	return;

func _clientProcessPacket(tcpConnection: StreamPeerTCP, packetBytes: Array):
	# FIXME non è detto che il pacchetto che ricevo sia completo. in caso non lo sia,
	# memorizzarlo in un buffer specifico di ogni connessione e riprovare successivamente.
	# print_rich("[color=magenta][SERVER] Receiving packet from " + tcpConnectionSocket + " with content bytes: " + str(packetBytes));
	#var packetLen = (packetBytes[0] << 8) + packetBytes[1];
	var packetCommand = packetBytes[0];
	match packetCommand:
		GameNetPacketManager.PacketType.TERRAIN_DATA_RES:
			_processTerrainDataResponse(tcpConnection, packetBytes) 
	return;
	
func _processTerrainDataResponse(tcpConnection: StreamPeerTCP, packetBytes: Array):
	#var requestedChunkX = requestContent[0];
	#var requestedChunkZ = requestContent[1];
	# FIXME non è detto che il pacchetto che ricevo sia completo. in caso non lo sia,
	# memorizzarlo in un buffer specifico di ogni connessione e riprovare successivamente.
	print_rich("[color=cyan][CLIENT] Receiving terrain data response: " + str(packetBytes));
	return;
	
# chunk_x: uint16 (from -32768 to 32767)
# chunk_y: uint16 (from -32768 to 32767)
func _requestTerrainData(chunk_x: int, chunk_z: int):
	print_rich("[color=cyan][CLIENT] Sending terrain request data for chunk (" + str(chunk_x) + ", " + str(chunk_z) + ")...");
	var packetBytes = GameNetPacketManager.createTerrainDataReq(chunk_x, chunk_z);
	_sendRequest(packetBytes);
	return;
	
func _sendRequest(packetBytes: PackedByteArray):
	var tcpConnectionStatus = tcpConnection.get_status();
	if(tcpConnectionStatus != StreamPeerTCP.STATUS_CONNECTED):
		printerr("[CLIENT] Could not send request to server! Connection status is \": " + GameNetUtils.parseTcpConnectionStatus(tcpConnectionStatus) + "\"");
		return;
	var errorCode = tcpConnection.put_data(packetBytes);
	if(errorCode != Error.OK):
		printerr("[CLIENT] Could not send request to server! (error code: " + str(errorCode) + ")");
	return;
