extends Node

"""
Save the contents of a byte buffer to a file.

:param filePath: The path to the file where the byte buffer will be saved.
:type filePath: String
:param byteBuffer: The byte buffer containing the data to be saved.
:type byteBuffer: Array
"""

func save(filePath: String, byteBuffer: Array):
	var packedByteArray = PackedByteArray(byteBuffer)
	
	var f = FileAccess.open("user://" + filePath, FileAccess.WRITE)
	f.store_buffer(packedByteArray)
	f.flush()
	f.close()

"""
Load the contents of a file into a byte buffer.

:param filePath: The path to the file to be loaded.
:type filePath: String
:return: The byte buffer containing the data read from the file.
:rtype: Array
"""

func load(filePath: String) -> Array:
	var f = FileAccess.open("user://" + filePath, FileAccess.READ)
	var readBack = f.get_buffer(f.get_len())
	f.close()
	return readBack
