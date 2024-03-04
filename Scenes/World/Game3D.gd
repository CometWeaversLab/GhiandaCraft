# Node that implements a 3D world of procedurally generated cubes.
#
# Author: Leonardo Spaccini
extends Node3D

@onready var texture = load("res://Assets/Textures/UVCheckGrid_1024x1024.png");

var meshInstancesRIDs = Array();

func _ready():
	var quadMesh = CubeManager.meshQuad;
	
	var scenario = get_world_3d().scenario;
	
	TerrainManager.initTerrain();
	
	print_debug("Calculating geometry...")
	var loadedChunksKeys = TerrainManager.terrainChunks.keys();
	meshInstancesRIDs.resize(TerrainManager.CHUNK_SIZE_BLOCKS * loadedChunksKeys.size());
	
	var quadCounter = 0;
	for chunkKey in loadedChunksKeys:
		var chunk = TerrainManager.terrainChunks[chunkKey];
		# render blocks
		for y in TerrainManager.CHUNK_HEIGHT_BLOCKS:
			for x in TerrainManager.CHUNK_WIDTH_BLOCKS:
				for z in TerrainManager.CHUNK_WIDTH_BLOCKS:
					var blockType = chunk.blocks[y][x][z];
					var blockId = TerrainManager.chunkCoordToChunkIndex(Vector3(x, y, z));
					if(blockType != CubeManager.BLOCK_TYPE.EMPTY):
						# capisco quali facce sono visibili
						var isTopVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x, y + 1, z) == CubeManager.BLOCK_TYPE.EMPTY);
						var isFrontVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x, y, z - 1) == CubeManager.BLOCK_TYPE.EMPTY);
						var isLeftVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x + 1, y, z) == CubeManager.BLOCK_TYPE.EMPTY);
						var isBackVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x, y, z + 1) == CubeManager.BLOCK_TYPE.EMPTY);
						var isRightVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x - 1, y, z) == CubeManager.BLOCK_TYPE.EMPTY);
						var isBottomVisible = (TerrainManager.getBlock(chunkKey.x, chunkKey.y, x, y - 1, z) == CubeManager.BLOCK_TYPE.EMPTY);
						
						# TODO qui devo fare una somma di trasformazioni
						var cubeTransform = Vector3( \
							x + (chunkKey.x * TerrainManager.CHUNK_WIDTH_BLOCKS), \
							y - TerrainManager.CHUNK_WIDTH_BLOCKS / 2, \
							z + (chunkKey.y * TerrainManager.CHUNK_WIDTH_BLOCKS) \
						);
						
						# cree la meshInstance delle facce
						meshInstancesRIDs[blockId] = Array();
						meshInstancesRIDs[blockId].resize(6);
						if(isTopVisible):
							meshInstancesRIDs[blockId][0] = CubeManager.createBlockTopFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
						if(isFrontVisible):
							meshInstancesRIDs[blockId][1] = CubeManager.createBlockFrontFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
						if(isLeftVisible):
							meshInstancesRIDs[blockId][2] = CubeManager.createBlockLeftFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
						if(isBackVisible):
							meshInstancesRIDs[blockId][3] = CubeManager.createBlockBackFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
						if(isRightVisible):
							meshInstancesRIDs[blockId][4] = CubeManager.createBlockRightFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
						if(isBottomVisible):
							meshInstancesRIDs[blockId][5] = CubeManager.createBlockBottomFace(scenario, CubeManager.BLOCK_TYPE.GRASS, cubeTransform);
							quadCounter += 1;
	print_debug("Total Quad count: ", quadCounter)
	return;
	
func _process(delta):
	return;
