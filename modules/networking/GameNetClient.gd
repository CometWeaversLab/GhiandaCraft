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
	return;
	
func _physics_process(_delta):
	tcpConnection.poll();
	
	# BEGIN TEST
	const packetBytes = [0x03, 0x55, 0xAA];
	print_rich("[color=cyan][CLIENT] Sending packet to server with content bytes: " + str(packetBytes));
	var errorCode = tcpConnection.put_data(packetBytes);
	if(errorCode != Error.OK):
		printerr("[CLIENT] Could not connect to server! Error code: " + str(errorCode));
	# ENDOF TEST
	return;
