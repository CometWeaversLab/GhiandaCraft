"""
Singleton class that provides logging capabilities.

Author: Leonardo Spaccini
"""
extends Node

func _init(bufferSize: int):
	return;

"""
Peeks the next 'bytesCount' bytes from ring buffer, and returns
an array of size 'bytesCount' without advancing the 'nextReadIndex'.
When the value of the 'bytesCount' is greater than the value
of 'getReadableBytesCount()', this function will return an array
of size 'getReadableBytesCount()' instead.
"""
func serverInfo(varargs... ):
	print(varargs)
	for i in range (0, bytesCount):
		var nextByte = self.buffer[(self.nextReadIndex + i) % self.bufferSize];
		byteArray.append(nextByte);
	return byteArray;
