"""
Class that implements a ring buffer (or circular buffer) which can be used to read and write stream of bytes.

Author: Leonardo Spaccini
"""
class_name RingBuffer

var bufferSize: int;
var buffer: Array;
var nextReadIndex: int;
var nextWriteIndex: int;

func _init(bufferSize: int):
	self.bufferSize = bufferSize;
	self.buffer = [];
	self.buffer.resize(bufferSize);
	self.nextReadIndex = 0;
	self.nextWriteIndex = 0;
	return;

"""
Peeks the next 'bytesCount' bytes from ring buffer, and returns
an array of size 'bytesCount' without advancing the 'nextReadIndex'.
When the value of the 'bytesCount' is greater than the value
of 'getReadableBytesCount()', this function will return an array
of size 'getReadableBytesCount()' instead.
"""
func peekBytes(bytesCount: int) -> Array:
	var byteArray = [];
	for i in range (0, bytesCount):
		var nextByte = self.buffer[(self.nextReadIndex + i) % self.bufferSize];
		byteArray.append(nextByte);
	return byteArray;

"""
Reads the next 'bytesCount' bytes from ring buffer, returns
an array of size 'bytesCount' and advances the 'nextReadIndex'.
When the value of the 'bytesCount' is greater than the value
of 'getReadableBytesCount()', this function will return an array
of size 'getReadableBytesCount()' instead.
"""
func readBytes(bytesCount: int) -> Array:
	var byteArray = [];
	for i in range (0, bytesCount):
		var nextByte = self.buffer[self.nextReadIndex];
		self.nextReadIndex = (self.nextReadIndex + 1) % self.bufferSize;
		byteArray.append(nextByte);
	return byteArray;

"""
Writes the given 'byteArray' of size n into the ring buffer
and advances the 'nextWriteIndex'.
When the size of the given 'byteArray' is greater than the value
of 'getWritableBytesCount()', this function will throw an error.
"""
func writeBytes(byteArray: Array) -> void:
	var byteArraySize = byteArray.size();
	var writableBytesCount = self.getWritableBytesCount();
	if(byteArraySize > writableBytesCount):
		push_error("Can not write " + str(byteArraySize) + " bytes into the ring buffer because the current capacity is " + str(writableBytesCount) + ".");
	for i in range (0, byteArraySize):
		self.buffer[self.nextWriteIndex] = byteArray[i];
		self.nextWriteIndex = (self.nextWriteIndex + 1) % self.bufferSize;
	return;

"""
Returns the number of bytes that can be read.
"""
func getReadableBytesCount() -> int:
	if(self.nextReadIndex <= self.nextWriteIndex):
		return self.nextWriteIndex - self.nextReadIndex;
	return self.bufferSize - self.nextReadIndex + self.nextWriteIndex;
	
"""
Returns the number of bytes that can be written.
"""
func getWritableBytesCount() -> int:
	if(self.nextWriteIndex < self.nextReadIndex):
		return self.nextReadIndex - self.nextWriteIndex;
	return self.bufferSize - self.nextWriteIndex + self.nextReadIndex;


