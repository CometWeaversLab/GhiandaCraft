# Node that implements a 3D world of procedurally generated cubes.
#
# Author: Leonardo Spaccini

extends Node3D

@onready var texture = load("res://Assets/Textures/UVCheckGrid_1024x1024.png");

var cubeMesh;
var cubeMaterial;
var cubeRIDs = [];

func _ready():	
# prepare the material
	cubeMaterial = StandardMaterial3D.new();
	cubeMaterial.albedo_color = Color(1.0, 1.0, 1.0);
	cubeMaterial.albedo_texture = texture;
	cubeMaterial.uv1_scale = Vector3(3, 2, 1); # same texture for every face
	cubeMaterial.texture_repeat = true; #default
	
	# prepare the mesh
	cubeMesh = BoxMesh.new();
	cubeMesh.set_size(Vector3(1.0, 1.0, 1.0));
	cubeMesh.surface_set_material(0, cubeMaterial);
	
	# generate blocks
	cubeRIDs.resize(1000);
	for i in range(0, 10):
		for j in range(0, 10):
			for k in range(0, 10):
				var cubeIndex = (100 * i) + (10 * j) + k;
				var cubeTransform = Transform3D(Basis.IDENTITY, 2 * Vector3(i - 5, j - 5, k - 5));
				cubeRIDs[cubeIndex] = RenderingServer.instance_create(); # create a new instance
				RenderingServer.instance_set_base(cubeRIDs[cubeIndex], cubeMesh); # set the instance mesh
				RenderingServer.instance_set_scenario(cubeRIDs[cubeIndex], get_world_3d().scenario);
				RenderingServer.instance_set_transform(cubeRIDs[cubeIndex], cubeTransform);
	return;
