# Node that implements a freelook 3D camera that uses quaternions for rotations
# and is not affected by gimbal lock.
#
# Author: Leonardo Spaccini

extends Camera3D

const SPEED_BASE   = 1.0;
const SPEED_SPRINT = 4.0;
const MOUSE_SENSITIVITY_X = 0.002;
const MOUSE_SENSITIVITY_Y = 0.002;
const YAW_SENSITIVITY = 0.01;

var isGameWindowFocused = true;

func _ready():
	get_viewport().warp_mouse(get_viewport().size / 2.0) # reset cursor at the center of the viewport
	return;

# Gets notified when the game window acquires or loses focus
func _notification(event):
	if event == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		isGameWindowFocused = true;
	elif event == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		isGameWindowFocused = false;
	return;

# FIXME inputs (mouse and keyboard) and hence movement and rotation,
# should be checked in _physics_process(..) instead. Good enough for now.
func _process(delta):
	if(!isGameWindowFocused): 
		return;
	# obtains mouse position relative to the center of the viewport,
	# then reset cursor at the center of the viewport
	var mousePosition = get_viewport().get_mouse_position() - get_viewport().size / 2.0;
	get_viewport().warp_mouse(get_viewport().size / 2.0);
	
	# calculate movement speed
	var speed;
	if Input.is_key_pressed(KEY_SHIFT):
		speed = SPEED_SPRINT;
	else:
		speed = SPEED_BASE;
	
	# calculate movement unit vector
	var cameraMovement = Vector3.ZERO;
	if Input.is_key_pressed(KEY_A):
		cameraMovement.x -= 1;
	if Input.is_key_pressed(KEY_D):
		cameraMovement.x += 1;
	if Input.is_key_pressed(KEY_W):
		cameraMovement.z -= 1;
	if Input.is_key_pressed(KEY_S):
		cameraMovement.z += 1;
	if Input.is_key_pressed(KEY_SPACE):
		cameraMovement.y += 1;
	if Input.is_key_pressed(KEY_ALT):
		cameraMovement.y -= 1;
	cameraMovement = cameraMovement.normalized() * speed;
	
	# calculate rotation angles (in radians)
	var anglePitch = - mousePosition.x * MOUSE_SENSITIVITY_X;
	var angleRoll = - mousePosition.y * MOUSE_SENSITIVITY_Y;
	var angleYaw = 0;
	if Input.is_key_pressed(KEY_Q):
		angleYaw = angleYaw + YAW_SENSITIVITY;
	if Input.is_key_pressed(KEY_E):
		angleYaw = angleYaw - YAW_SENSITIVITY;
		
	# Create a quaternion from yaw, pitch, and roll angles
	var cy = cos(angleYaw   * 0.5)
	var sy = sin(angleYaw   * 0.5)
	var cp = cos(anglePitch * 0.5)
	var sp = sin(anglePitch * 0.5)
	var cr = cos(angleRoll  * 0.5)
	var sr = sin(angleRoll  * 0.5)

	var w = cy * cp * cr + sy * sp * sr
	var x = cy * cp * sr - sy * sp * cr
	var y = sy * cp * sr + cy * sp * cr
	var z = sy * cp * cr - cy * sp * sr
	
	var cameraRotation = Quaternion(x, y, z, w);

	# update camera position and rotation
	self.translate_object_local(cameraMovement * delta);
	self.set_quaternion(self.get_quaternion() * cameraRotation * delta);
	return;
