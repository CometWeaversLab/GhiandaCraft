extends Node

func save(file_path: String, byte_buffer: Array):
	var packedByteArray = PackedByteArray(byte_buffer)
	
	var f = FileAccess.open("user://" + file_path, FileAccess.WRITE)
	f.store_buffer(packedByteArray)
	f.flush()
	f.close()

func load(file_path: String) -> Array:
	var f_2 = FileAccess.open("user://" + file_path, FileAccess.READ)
	var read_back = f_2.get_buffer(f_2.get_len())
	f_2.close()
	return read_back
