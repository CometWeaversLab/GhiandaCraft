# Labels that prints debug informations
#
# Author: Leonardo Spaccini

extends Label

@onready var gameCamera : Camera3D = get_node("/root/Game3D/FreeLookCamera3D");

func _process(delta):
	self.text = getFpsString(delta) \
		+ "\n" + getMonitorString() \
		+ "\n" + getCpuString() \
		+ "\n" + getGpuString() \
		+ "\n\n\n" + getCameraPosition() \
		+ "\n" + getCameraRotation();
	return;

func getProcessInfo():
	return "PID: " + str(OS.get_process_id());
		
func getFpsString(delta):
	return "FPS: " + str(Engine.get_frames_per_second()) + " ("\
		+ "frameTime: " + str(snapped(delta * 1000, 0.01)) + " ms, " \
		+ "framesCount: " + str(Engine.get_frames_drawn()) \
	+ ")";

func getMonitorString():
	return "VSync: " + getVsyncModeString();

func getVsyncModeString():
	var vsyncMode = DisplayServer.window_get_vsync_mode();
	if vsyncMode == DisplayServer.VSYNC_DISABLED:
		return "Off";
	elif vsyncMode == DisplayServer.VSYNC_ENABLED:
		return "On"
	elif vsyncMode == DisplayServer.VSYNC_ADAPTIVE:
		return "Adaptive";
	elif vsyncMode == DisplayServer.VSYNC_MAILBOX:
		return "Fast";
	return "";
	
func getCpuString():
	return "CPU: " + OS.get_processor_name() \
		+ " (" + str(OS.get_processor_count()) + " Threads" + ")";

func getGpuString():
	return "GPU: " + OS.get_video_adapter_driver_info()[0] \
		+ " (Driver version: " + OS.get_video_adapter_driver_info()[1] + ")";

func getFpsLimitString():
	var fpsLimit = Engine.max_fps;
	if fpsLimit == 0:
		return "unlimited";
	return str(fpsLimit);

func getCameraPosition():
	return "Position: (x: " + str(snapped(gameCamera.position.x, 0.01)) \
		+ ", y: " + str(snapped(gameCamera.position.y, 0.01)) \
		+ ", z: " + str(snapped(gameCamera.position.z, 0.01)) \
		+ ")";

func getCameraRotation():
	return "Rotation: (Yaw: " + str(snapped(gameCamera.rotation.x * 360 / (2 * PI), 1)) \
		+ "°, Pitch: " + str(snapped(gameCamera.rotation.y * 360 / (2 * PI), 1)) \
		+ "°, Roll: " + str(snapped(gameCamera.rotation.z * 360 / (2 * PI), 1)) \
		+ "°)";
