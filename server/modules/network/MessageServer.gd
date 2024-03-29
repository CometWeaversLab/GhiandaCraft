"""
Script that implements the functionalities related to a network message.

The structure of the messages is the following:
- The 0-3 bytes represents the "messageId", which is a uint64 that identifies the message
  for the specific TCP connection. The first message sent by the client for the connection has
  messageId equals to zero, then the client increases it by one at each subsequent message.
  The server replies to each client message with a message with the same messageId, so that the
  client can identify which message replies to which, in case of buffering.
- The 4 byte represents the "commandId", which represents the meaning of the message.
  The complete list of commands can be found in the "NetworkMessage" script.
- The rest of the message is structured depending on the "commandId". More details can be found
  in the "NetworkMessage" script.
Note that every field of the message is little-endian.

Author: Leonardo Spaccini
"""
extends Node

func hasNextMessage():
	pass
	
func getNextMessage(socket):
	pass
	
func writeMessage():
	pass
	
func _physics_process(_delta):
	var connections = NetworkServer.tcpConnections;
	for socket in connections:
		var connection = connections[socket];
		var ringBuffer = connection.ringBuffer;
		var readableBytesCount = ringBuffer.getReadableBytesCount();
		if(readableBytesCount > 0):
			var peekByte = ringBuffer.peekBytes(1);
			if(peekByte[0] == 2):
				if(readableBytesCount >= 5): # lunghezza di un messaggio di richiesta dati chunk
					var message = ringBuffer.readBytes(5);
					print("ricevuto messaggio richiesta chunk dal client")
	return;
