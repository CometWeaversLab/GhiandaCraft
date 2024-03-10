"""
TODO documentation


Author: Leonardo Spaccini
"""
extends Node

enum PacketType {
	LOGIN_REQ = 0x00,
	LOGIN_RES = 0x01,
	# ...
	TERRAIN_DATA_REQ = 0x02,
	TERRAIN_DATA_RES = 0x03
}

# chunk_x: int16 (from -32768 to 32767)
# chunk_z: int16 (from -32768 to 32767)
func createTerrainDataReq(chunk_x: int, chunk_z: int) -> PackedByteArray:
	chunk_x = chunk_x + 32768;
	chunk_z = chunk_z + 32768;
	var chunk_x_msb = ((chunk_x >> 8) & 0xff);
	var chunk_x_lsb = ((chunk_x >> 0) & 0xff);
	var chunk_z_msb = ((chunk_z >> 8) & 0xff);
	var chunk_z_lsb = ((chunk_z >> 0) & 0xff);
	return PackedByteArray([PacketType.TERRAIN_DATA_REQ, chunk_x_msb, chunk_x_lsb, chunk_z_msb, chunk_z_lsb]);
	
func parseTerrainDataReq(packetBytes: PackedByteArray) -> Array:
	var chunk_x_msb = packetBytes[1];
	var chunk_x_lsb = packetBytes[2];
	var chunk_z_msb = packetBytes[3];
	var chunk_z_lsb = packetBytes[4];
	var chunk_x = (chunk_x_msb << 8) + chunk_x_lsb - 32768;
	var chunk_z = (chunk_z_msb << 8) + chunk_z_lsb - 32768;
	return [chunk_x, chunk_z];

func createTerrainDataRes(chunk_x: int, chunk_z: int, payload: Array) -> PackedByteArray:
	chunk_x = chunk_x + 32768;
	chunk_z = chunk_z + 32768;
	var chunk_x_msb = ((chunk_x >> 8) & 0xff);
	var chunk_x_lsb = ((chunk_x >> 0) & 0xff);
	var chunk_z_msb = ((chunk_z >> 8) & 0xff);
	var chunk_z_lsb = ((chunk_z >> 0) & 0xff);
	var packet_len_msb = ((payload.size() >> 8) & 0xff);
	var packet_len_lsb = ((payload.size() >> 0) & 0xff);
	var array = [PacketType.TERRAIN_DATA_RES, chunk_x_msb, chunk_x_lsb, chunk_z_msb, chunk_z_lsb, packet_len_msb, packet_len_lsb];
	array.append_array(payload);
	return PackedByteArray(array);
