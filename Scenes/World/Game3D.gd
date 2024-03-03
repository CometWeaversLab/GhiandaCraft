# Node that implements a 3D world of procedurally generated cubes.
#
# Author: Leonardo Spaccini
extends Node3D

@onready var texture = load("res://Assets/Textures/UVCheckGrid_1024x1024.png");

const cubeSize = 1;
var cubeMesh : Mesh;
var cubeMaterial : Material;
var cubeRIDs = [];

func _ready():
	# prepare the material
	cubeMaterial = StandardMaterial3D.new();
	cubeMaterial.albedo_color = Color(0.0, 1.0, 0.0);
	#cubeMaterial.albedo_texture = texture;
	cubeMaterial.uv1_scale = Vector3(3, 2, 1); # same texture for every face
	cubeMaterial.texture_repeat = true; #default

	# prepare the mesh
	cubeMesh = BoxMesh.new();
	cubeMesh.set_size(Vector3(cubeSize, cubeSize, cubeSize));
	cubeMesh.surface_set_material(0, cubeMaterial);
	
	# alloracate blocks
	TerrainManager.initTerrain();
	var chunkstotal = TerrainManager.loadedChunks.keys().size();
	cubeRIDs.resize(TerrainManager.CHUNK_SIZE_BLOCKS * chunkstotal);
	
	for chunk_x in range(0, 1):
		for chunk_z in range(0, 1):
			var chunk = TerrainManager.loadedChunks[Vector2(chunk_x,chunk_z)];
			# render blocks
			for cubeIndex in TerrainManager.CHUNK_SIZE_BLOCKS:
				var blockId = chunk.blockId[cubeIndex];
				if(blockId != 0):
					var chunkCoord = TerrainManager.chunkIndexToChunkCoord(cubeIndex);
					var cubeTransform = Transform3D(Basis.IDENTITY, Vector3( \
					chunkCoord.x + (chunk_x * TerrainManager.CHUNK_WIDTH_BLOCKS), \
						chunkCoord.y - TerrainManager.CHUNK_WIDTH_BLOCKS / 2, \
						chunkCoord.z + (chunk_z * TerrainManager.CHUNK_WIDTH_BLOCKS) \
					) * cubeSize);
					cubeRIDs[cubeIndex] = RenderingServer.instance_create(); # create a new instance
					RenderingServer.instance_set_base(cubeRIDs[cubeIndex], cubeMesh); # set the instance mesh
					RenderingServer.instance_set_scenario(cubeRIDs[cubeIndex], get_world_3d().scenario);
					RenderingServer.instance_set_transform(cubeRIDs[cubeIndex], cubeTransform);
	return;
	
func _process(delta):
	return;
