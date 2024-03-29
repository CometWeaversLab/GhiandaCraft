# Singleton script that manages terrain data for the world.
# Note that this script should only manage functionalities related to the terrain's data
# such as: generation, modification, loading, and saving. This script is not concerned
# about how the terrain data is actually rendered.
#
# The world's terrain is made out of voxels also called "blocks". By convention, a block has a 
# dimension of 1*1*1 unit, and it is uniquely identified by a set of 3D integer coordinates (x,y,z)
# which are referenced as the block's "global position" (or "world position").
# The terrain coordinate system uses left-handed orientation. Therefore, the convention 
# for the terrain orientation system is the following:
# - the "y" axis points "up" (identifies the height)
# - the "z" axis points "forward" (identifies the length)
# - the "x" axis points "left" (identifies the width)
# The world has a fixed height of 256 blocks. The length and width, instead, are virtually infinite,
# as the world terrain can be procedurally generated.
# 
# For convenience, the world's terrain is dividen into "chunks". A chunk is a portion of terrain
# that has a dimension of 16*256*16 blocks. Each chunk can be individually generated, loaded into
# memory or unloaded from memory. Each chunk is uniquely identified by a set of 2D integer 
# coordinates (chunk_x, chunk_z) which are referred as "chunk coordinates", where by convention:
# - chunk_z is the direction in the "z" axis (identifies the "latitude" or "north")
# - chunk_x is the direction in the "x" axis (identifies the "longitude" or "east")
# 
# By convention the base of the chunk (0,0) starts at block with global position (0,0,0) and ends
# at block with global position (15,0,15). Other examples are:
# - chunk (1,0) starts at block with global pos. (16,0,0) and ends at block with global pos (31,0,15)
# - chunk (-1,0) starts at block with global pos. (-16,0,0) and ends at block with global pos (-1,0,15)
# - chunk (0,0-1) starts at block with global pos. (0,0,-16) and ends at block with global pos (15,0,-1)
#
# Each block of the world's terrain can hence also be identified by its "local position"
# related to the chunk that contains it. Such position is represented by the tuple:
# (chunk_x, chunk_z, local_x, local_y, local_z).
#
# Author: Leonardo Spaccini

extends Node

const CHUNK_LENGTH_BLOCKS = 16;  # number of blocks in the z direction of a chunk
const CHUNK_WIDTH_BLOCKS  = 16;  # number of blocks in the x direction of a chunk
const CHUNK_HEIGHT_BLOCKS = 256; # number of blocks in the y direction of a chunk
const CHUNK_SIZE_BLOCKS = CHUNK_LENGTH_BLOCKS * CHUNK_WIDTH_BLOCKS * CHUNK_HEIGHT_BLOCKS; # number of blocks in a chunk

# Class that represends a chunk.
class TerrainChunk:
	var blocks = []; # 3D array [x][y][z] - may be slow but its good enough for now.

# Global variables
var terrainChunks = {}; # dictionary

# Function that returns the terrain chunk given the chunk coordinates,
# or null if such chunk is not loaded into memory.
#func getTerrainChunk(chunk_x: int, chunk_z: int) -> TerrainChunk:
#	return terrainChunks[Vector2(chunk_x, chunk_z)];
func saveTerrainChunkToDisk(chunk_x: int, chunk_z: int):
	var chunk = terrainChunks[Vector2(chunk_x, chunk_z)];
	var fileName = "chunk_" + str(chunk_x) + "_" + str(chunk_z) + ".bin";
	print_debug("Saving '" + fileName + "' into disk...")
	var data = [];
	data.resize(CHUNK_SIZE_BLOCKS);
	for y in CHUNK_HEIGHT_BLOCKS:
		for x in CHUNK_WIDTH_BLOCKS:
			for z in CHUNK_LENGTH_BLOCKS:
				data[y * CHUNK_HEIGHT_BLOCKS + x * CHUNK_WIDTH_BLOCKS + z] = chunk.blocks[y][x][z];
	FileManager.save(fileName, data);
	return;

func loadTerrainChunkFromDisk(chunk_x: int, chunk_z: int):
	var fileName = "chunk_" + str(chunk_x) + "_" + str(chunk_z) + ".bin";
	print_debug("Loading '" + fileName + "' from disk...")
	var data = FileManager.load(fileName);
	var blocks = []
	blocks.resize(CHUNK_HEIGHT_BLOCKS);
	for y in CHUNK_HEIGHT_BLOCKS:
		blocks[y] = [];
		blocks[y].resize(CHUNK_WIDTH_BLOCKS);
		for x in CHUNK_WIDTH_BLOCKS:
			blocks[y][x] = [];
			blocks[y][x].resize(CHUNK_WIDTH_BLOCKS);
			for z in CHUNK_LENGTH_BLOCKS:
				blocks[y][x][z] = data[y * CHUNK_HEIGHT_BLOCKS + x * CHUNK_WIDTH_BLOCKS + z];
	var terrainChunk = TerrainChunk.new();
	terrainChunk.blocks = blocks;
	terrainChunks[Vector2(chunk_x, chunk_z)] = terrainChunk;
	return;

func chunkCoordToChunkIndex(vec3: Vector3) -> int : 
	assert(vec3.x >= 0 && vec3.x < CHUNK_WIDTH_BLOCKS,  "component 'x' must be in range [0, " + str(CHUNK_WIDTH_BLOCKS)  + "]")
	assert(vec3.z >= 0 && vec3.z < CHUNK_WIDTH_BLOCKS,  "component 'z' must be in range [0, " + str(CHUNK_WIDTH_BLOCKS)  + "]")
	assert(vec3.y >= 0 && vec3.y < CHUNK_HEIGHT_BLOCKS, "component 'y' must be in range [0, " + str(CHUNK_HEIGHT_BLOCKS) + "]")
	return (vec3.y * CHUNK_HEIGHT_BLOCKS) + (vec3.z * CHUNK_WIDTH_BLOCKS) + vec3.x;
	
func chunkIndexToChunkCoord(index: int) -> Vector3:
	assert(index >= 0 && index < CHUNK_SIZE_BLOCKS, "argument 'index' must be in range [0, " + str(CHUNK_SIZE_BLOCKS) + "]")
	var x = index % CHUNK_WIDTH_BLOCKS;
	var z = floor(index / CHUNK_WIDTH_BLOCKS) % CHUNK_WIDTH_BLOCKS;
	var y = floor(index / CHUNK_HEIGHT_BLOCKS);
	return Vector3(x, y, z);

func initTerrain():
	var noise = FastNoiseLite.new();
	#noise.noise_type = FastNoiseLite.TYPE_PERLIN;
	noise.seed = 12356
	#noise.frequency = 20
	#noise.fractal_octaves = 8
	#noise.fractal_lacunarity = 2
	#noise.fractal_gain = 0.5
	
	# Leonardo: chunk loading works, but need to check if the file already exists
	# before doing it...
	#for chunk_x in range(-1, 2):
	#	for chunk_z in range(-1, 2):
	#		loadTerrainChunkFromDisk(chunk_x, chunk_z);
	#return;
	
	for chunk_x in range(0, 1):
		for chunk_z in range(0, 1):
			
			var newChunk = TerrainChunk.new();
			newChunk.blocks.resize(CHUNK_HEIGHT_BLOCKS);
			for y in CHUNK_HEIGHT_BLOCKS:
				newChunk.blocks[y] = Array();
				newChunk.blocks[y].resize(CHUNK_WIDTH_BLOCKS);
				for x in CHUNK_WIDTH_BLOCKS:
					newChunk.blocks[y][x] = Array();
					newChunk.blocks[y][x].resize(CHUNK_WIDTH_BLOCKS);
					for z in CHUNK_WIDTH_BLOCKS:
						var noisev = noise.get_noise_2d(x + chunk_x * CHUNK_WIDTH_BLOCKS, z + chunk_z * CHUNK_WIDTH_BLOCKS); # between -1 and 1
						var worldHeight = (noisev + 1) / 2 * CHUNK_HEIGHT_BLOCKS;
						var chunkIndex = chunkCoordToChunkIndex(Vector3(x, y, z));
						if(y <= worldHeight):
							newChunk.blocks[y][x][z] = CubeManager.BLOCK_TYPE.GRASS;
						else:
							newChunk.blocks[y][x][z] = CubeManager.BLOCK_TYPE.EMPTY;
			terrainChunks[Vector2(chunk_x,chunk_z)] = newChunk;
			saveTerrainChunkToDisk(chunk_x, chunk_z);
	return;
	
func getBlock(chunk_x: int, chunk_z: int, x: int, y: int, z: int) -> int:
	var chunk_delta_x = 0;
	var chunk_delta_z = 0;
	var delta_x = 0;
	var delta_z = 0;
	if(y < 0 || y >= CHUNK_HEIGHT_BLOCKS):
		return CubeManager.BLOCK_TYPE.EMPTY; # sempre vuoto
	if(x < 0):
		chunk_delta_x =- 1;
		delta_x += CHUNK_WIDTH_BLOCKS;
	if(x >= CHUNK_WIDTH_BLOCKS):
		chunk_delta_x =+ 1;
		delta_x -= CHUNK_WIDTH_BLOCKS;
	if(z < 0):
		chunk_delta_z =- 1;
		delta_z += CHUNK_WIDTH_BLOCKS;
	if(z >= CHUNK_WIDTH_BLOCKS):
		chunk_delta_z =+ 1;
		delta_z -= CHUNK_WIDTH_BLOCKS;
	
	var key = Vector2(chunk_x + chunk_delta_x, chunk_z + chunk_delta_z)
	if(!terrainChunks.has(key)):
		return CubeManager.BLOCK_TYPE.EMPTY;
	var chunk = terrainChunks[key];
	return chunk.blocks[y][x + delta_x][z + delta_z];
