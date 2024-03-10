extends Node

# user://
# On Windows: %APPDATA%\Godot\app_userdata\ProjectName
# On GNU/Linux: $HOME/.godot/app_userdata/ProjectName

"""
Check if the file exists at the specified path.

:param filePath: The path to the file to be checked.
:type filePath: String
:return: True if the file exists, False otherwise.
:rtype: bool
"""
func fileExists(filePath: String) -> bool:
	return FileAccess.file_exists("user://" + filePath);

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
	var readBack = f.get_buffer(f.get_length())
	f.close()
	return readBack
