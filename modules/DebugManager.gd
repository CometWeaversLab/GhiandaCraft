# Author: Leonardo Spaccini
extends Node

# array that contains user-readable names 
# for the "Viewport.DebugDraw" enumeration
const debugDrawNames = [
	"None",                               # DEBUG_DRAW_DISABLED  = 0
	"Unshaded",                           # DEBUG_DRAW_UNSHADED  = 1
	"Lighting",                           # DEBUG_DRAW_LIGHTING = 2
	"Overdraw",                           # DEBUG_DRAW_OVERDRAW = 3
	"Wireframe",                          # DEBUG_DRAW_WIREFRAME = 4
	"Normal Buffer",                      # DEBUG_DRAW_NORMAL_BUFFER = 5
	"Global Illumination Voxel Albedo",   # DEBUG_DRAW_VOXEL_GI_ALBEDO = 6
	"Global Illumination Voxel Lighting", # DEBUG_DRAW_VOXEL_GI_LIGHTING = 7
	"Global Illumination Voxel Emission", # DEBUG_DRAW_VOXEL_GI_EMISSION = 8
	"Shadow Atlas",                       # DEBUG_DRAW_SHADOW_ATLAS = 9
	"Directional Shadow Atlas",           # DEBUG_DRAW_DIRECTIONAL_SHADOW_ATLAS = 10
	"Luminance",                          # DEBUG_DRAW_SCENE_LUMINANCE = 11
	"Screen-Space Ambient Occlusion",     # DEBUG_DRAW_SSAO = 12
	"Screen-Space Indirect Lighting",     # DEBUG_DRAW_SSIL = 13
	"Parallel-Split Shadow Maps",         # DEBUG_DRAW_PSSM_SPLITS = 14
	"Decals Atlas",                       # DEBUG_DRAW_DECAL_ATLAS = 15
	"SDFGI",                              # DEBUG_DRAW_SDFGI = 16
	"SDFGI Probes",                       # DEBUG_DRAW_SDFGI_PROBES = 17
	"Global Illumination Buffer",         # DEBUG_DRAW_GI_BUFFER = 18
	"Disable LOD",                        # DEBUG_DRAW_DISABLE_LOD = 19
	"Omni-Lights Cluster",                # DEBUG_DRAW_CLUSTER_OMNI_LIGHTS = 20
	"Spot-Lights Cluster",                # DEBUG_DRAW_CLUSTER_SPOT_LIGHTS = 21
	"Decals Cluster",                     # DEBUG_DRAW_CLUSTER_DECALS = 22
	"Reflection Probes Cluster",          # DEBUG_DRAW_CLUSTER_REFLECTION_PROBES = 23
	"Occluders",                          # DEBUG_DRAW_OCCLUDERS = 24
	"Motion Vectors",                     # DEBUG_DRAW_MOTION_VECTORS = 25
	"Internal Buffer",                    # DEBUG_DRAW_INTERNAL_BUFFER = 26
];

func getViewportOverlayMode() -> Viewport.DebugDraw:
	return get_viewport().debug_draw;
	
func setViewportOverlayMode(mode: Viewport.DebugDraw):
	get_viewport().debug_draw = mode;
	return;
	
func nameOfViewportDebugDraw(mode: Viewport.DebugDraw) -> String:
	return debugDrawNames[mode];
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3:
			var viewportOverlayMode = getViewportOverlayMode();
			var nextViewportOverlayMode = (viewportOverlayMode + 1) % debugDrawNames.size();
			setViewportOverlayMode(nextViewportOverlayMode);
