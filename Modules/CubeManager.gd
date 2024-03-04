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

@export var meshQuad : Mesh;
@export var materialsDictionary = Dictionary(); # potrebbe essere un array?

@onready var textureGrassBack = load("res://Assets/Textures/Dirt_Back.png");
@onready var textureGrassBottom = load("res://Assets/Textures/Dirt_Bottom.png");
@onready var textureGrassFront = load("res://Assets/Textures/Dirt_Front.png");
@onready var textureGrassLeft = load("res://Assets/Textures/Dirt_Left.png");
@onready var textureGrassRight = load("res://Assets/Textures/Dirt_Right.png");
@onready var textureGrassTop = load("res://Assets/Textures/Dirt_Top.png");

func _ready():
	# create the quad mesh
	self.meshQuad = QuadMesh.new();
	self.meshQuad.set_size(MESH_QUAD_SIZE * Vector2.ONE);
	
	# create the materials
	var materialGrassBack = createMaterialFromTexture(textureGrassBack);
	var materialGrassBottom = createMaterialFromTexture(textureGrassBottom);
	var materialGrassFront = createMaterialFromTexture(textureGrassFront);
	var materialGrassLeft = createMaterialFromTexture(textureGrassLeft);
	var materialGrassRight = createMaterialFromTexture(textureGrassRight);
	var materialGrassTop = createMaterialFromTexture(textureGrassTop);
	
	# intialize material dictionary
	var grassMaterialArray = Array();
	grassMaterialArray.resize(BLOCK_FACE.size());
	grassMaterialArray[BLOCK_FACE.BACK] = materialGrassBack;
	grassMaterialArray[BLOCK_FACE.BOTTOM] = materialGrassBottom;
	grassMaterialArray[BLOCK_FACE.FRONT] = materialGrassFront;
	grassMaterialArray[BLOCK_FACE.LEFT] = materialGrassLeft;
	grassMaterialArray[BLOCK_FACE.RIGHT] = materialGrassRight;
	grassMaterialArray[BLOCK_FACE.TOP] = materialGrassTop;
	
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
