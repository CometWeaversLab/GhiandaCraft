# Singleton scripts that manages the geometry related to cubes.
#
# Author: Leonardo Spaccini

extends Node

enum BLOCK_FACE {
	TOP = 0, 
	FRONT = 1,
	RIGHT = 2,
	BACK = 3,
	LEFT = 4,
	BOTTOM = 5
}

enum BLOCK_TYPE {
	EMPTY = 0x00, 
	GRASS = 0x01
}

const MESH_QUAD_SIZE = 1.0;

# meshes
@export var meshLine : Mesh;
@export var meshQuad : Mesh;

# materials
var materialShader : Material;
@export var materialsDictionary = Dictionary(); # potrebbe essere un array?

# textures
@onready var textureGrassTop = load("res://assets/Textures/Grass_Top.png");
@onready var textureGrassSide = load("res://assets/Textures/Grass_Side.png");
@onready var textureGrassBottom = load("res://assets/Textures/Grass_Bottom.png");


# shaders
@onready var shaderBasic = load("res://shaders/basic.gdshader");

func _ready():
	self.materialShader = ShaderMaterial.new();
	materialShader.shader = shaderBasic;
	
	# create the line mesh
	self.meshLine = ImmediateMesh.new();
	meshLine.surface_begin(Mesh.PRIMITIVE_LINES);
	#set_color(0,0,0)
	meshLine.surface_add_vertex(Vector3(0, 0, 0))
	meshLine.surface_add_vertex(Vector3(0, 0, 1)) # FORWARD
	meshLine.surface_end();
	meshLine.surface_set_material(0, materialShader);
	
	# create the quad mesh
	self.meshQuad = QuadMesh.new();
	self.meshQuad.set_size(MESH_QUAD_SIZE * Vector2.ONE);
	

	
	# create the materials
	var materialGrassTop = createMaterialFromTexture(textureGrassTop);
	var materialGrassSide = createMaterialFromTexture(textureGrassSide);
	var materialGrassBottom = createMaterialFromTexture(textureGrassBottom);
	
	# intialize material dictionary
	var grassMaterialArray = Array();
	grassMaterialArray.resize(BLOCK_FACE.size());
	grassMaterialArray[BLOCK_FACE.TOP] = materialGrassTop;
	grassMaterialArray[BLOCK_FACE.BACK] = materialGrassSide;
	grassMaterialArray[BLOCK_FACE.FRONT] = materialGrassSide;
	grassMaterialArray[BLOCK_FACE.LEFT] = materialGrassSide;
	grassMaterialArray[BLOCK_FACE.RIGHT] = materialGrassSide;
	grassMaterialArray[BLOCK_FACE.BOTTOM] = materialGrassBottom;
	
	materialsDictionary[BLOCK_TYPE.GRASS] = grassMaterialArray;
	return;
	
func createMaterialFromTexture(texture: Texture) -> Material:
	var material = StandardMaterial3D.new();
	material.albedo_texture = texture;
	material.texture_repeat = false;
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST;
	return material;
	
func createBlockTopFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position;
	var quadTransform = Transform3D(Basis.IDENTITY.rotated(Vector3(1,0,0), -PI/2), quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.TOP, quadTransform);
	
func createBlockBottomFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position + Vector3(0, -1.0, 0);
	var quadTransform = Transform3D(Basis.IDENTITY.rotated(Vector3(1,0,0), + PI/2), quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.BOTTOM, quadTransform);
	
func createBlockFrontFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position + Vector3(0, -0.5, -0.5);
	var quadTransform = Transform3D(Basis.IDENTITY.rotated(Vector3(0,1,0), + PI), quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.FRONT, quadTransform);
	
func createBlockBackFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position + Vector3(0, -0.5, +0.5);
	var quadTransform = Transform3D(Basis.IDENTITY, quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.BACK, quadTransform);

func createBlockLeftFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position + Vector3(+0.5, -0.5, 0);
	var quadTransform = Transform3D(Basis.IDENTITY.rotated(Vector3(0,1,0), + PI / 2), quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.LEFT, quadTransform);

func createBlockRightFace(scenario: RID, blockType: BLOCK_TYPE, position: Vector3) -> RID:
	var quadPosition = position + Vector3(-0.5, -0.5, 0);
	var quadTransform = Transform3D(Basis.IDENTITY.rotated(Vector3(0,1,0), - PI / 2), quadPosition);
	return createBlockFace(scenario, blockType, CubeManager.BLOCK_FACE.RIGHT, quadTransform);
	
func createBlockFace(scenario: RID, blockType: BLOCK_TYPE, faceType: BLOCK_FACE, transform: Transform3D) -> RID:
	var quadMaterial = CubeManager.materialsDictionary[blockType][faceType];
	var rid = RenderingServer.instance_create();
	RenderingServer.instance_set_base(rid, meshQuad);
	RenderingServer.instance_set_scenario(rid, scenario);
	RenderingServer.instance_set_surface_override_material(rid, 0, quadMaterial)
	RenderingServer.instance_set_transform(rid, transform);
	return rid;
	
func createLine(scenario: RID, positionStart: Vector3, positionEnd: Vector3, color: Color) -> RID:
	var rid = RenderingServer.instance_create();
	RenderingServer.instance_set_base(rid, meshLine);
	RenderingServer.instance_set_scenario(rid, scenario);
	
	var scale = (positionEnd - positionStart).length();
	var quaternion = Quaternion(Vector3(0,0,1), (positionEnd - positionStart).normalized());
	var transf = Transform3D(Basis.IDENTITY.from_euler(quaternion.get_euler()).scaled(Vector3.ONE * scale), positionStart);

	RenderingServer.instance_set_transform(rid, transf);
	
	RenderingServer.instance_geometry_set_shader_parameter(rid, "color", color)
	return rid;
