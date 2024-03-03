# Singleton script that manages the voxel terrain of the world.
#
# The world's terrain is made out of voxels also called "blocks". By convention, a block has a 
# dimension of 1*1*1 unit, and its position is the global coordinates of the center of its top face.
# The terrain coordinate system uses right-handed orientation (the same as Godot editor). 
# Therefore, the convention for the terrain coordinates is the following:
# - the y axis points "up"
# - the z axis points "forward"
# - the x axis points "left"
# The maximum height of the world is defined as 256. Therefore the y axis of the world ranges 
# from -127 to 126 (included), where 0 should represents the sea-level of the world.
#
# TODO chunk documentation
#
# Author: Leonardo Spaccini

extends Node

const CHUNK_WIDTH_BLOCKS  = 16;  # number of blocks in the x and z axis of a chunk
const CHUNK_HEIGHT_BLOCKS = 256; # number of blocks in the y axis of a chunk
const CHUNK_SIZE_BLOCKS = CHUNK_HEIGHT_BLOCKS * CHUNK_WIDTH_BLOCKS * CHUNK_WIDTH_BLOCKS; # number of blocks in a chunk

# A chunk is a contiguous memory portion that contains terrain information.
class TerrainChunk:
	var blockId = [];

var loadedChunks = {};

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
	
	for chunk_x in range(0, 1):
		for chunk_z in range(0, 1):
			
			var newChunk = TerrainChunk.new();
			newChunk.blockId.resize(CHUNK_SIZE_BLOCKS);
			for x in CHUNK_WIDTH_BLOCKS:
				for z in CHUNK_WIDTH_BLOCKS:
					var noisev = noise.get_noise_2d(x + chunk_x * CHUNK_WIDTH_BLOCKS, z + chunk_z * CHUNK_WIDTH_BLOCKS); # between -1 and 1
					var worldHeight = (noisev + 1) / 2 * CHUNK_HEIGHT_BLOCKS;
					for y in CHUNK_HEIGHT_BLOCKS:
						var chunkIndex = chunkCoordToChunkIndex(Vector3(x, y, z));
						if(y <= worldHeight):
							newChunk.blockId[chunkIndex] = 1; # grass
						else:
							newChunk.blockId[chunkIndex] = 0; # empty
			loadedChunks[Vector2(chunk_x,chunk_z)] = newChunk;
	return;
	