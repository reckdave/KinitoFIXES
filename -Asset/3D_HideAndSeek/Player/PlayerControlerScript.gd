extends KinematicBody

export  var speed = 3
var h_acceleration = 2
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false
export  var mouseOn = false
var mouse_sensitivity = 0.04

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()
var _delta = 0.0
var stepPos = false

onready var camera = $Head / Camera
onready var head = $Head
onready var ground_check = $GroundCheck
onready var hand = $Head / Hand / Move
onready var _original_camera_translation:Vector3 = camera.translation

func _ready():
	print("fixed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		if mouseOn:
			#print("hello_world")
			rotate_y(deg2rad( - event.relative.x * mouse_sensitivity))
			head.rotate_x(deg2rad( - event.relative.y * mouse_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad( - 89), deg2rad(89))

var stepVal = 0.0
func _physics_process(delta):
	_delta += delta
	direction = Vector3()
	full_contact = ground_check.is_colliding()
	
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = - get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else :
		gravity_vec = - get_floor_normal()
		h_acceleration = normal_acceleration
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
		input.y += 1
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
		input.y -= 1
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
		input.x -= 1
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		input.x += 1






	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	move_and_slide(movement, Vector3.UP)
	
	var averageMovement = clamp((abs(movement.x) + abs(movement.z)) / 4, 0, 1)
	
	var camera_bob = clamp(floor(abs(input.x) + abs(input.y)), 0, 1) * _delta * 2
	var equation = (camera_bob - (tanh(((camera_bob + 0.5) - floor(camera_bob + 0.5) - 0.5) * 10) / 2 + floor(camera_bob + 0.5) - 0.5) - 0.5) * 2.4
	var _target_camera_translation = _original_camera_translation + Vector3.UP * equation * averageMovement
	camera.translation = camera.translation.linear_interpolate(_target_camera_translation, delta)

	var wobleEquationx = (sin(_delta) + sin(camera.translation.y)) / 200
	var wobleEquationy = (sin(_delta * 2) - sin(_delta)) / 200
	hand.translation += (Vector3(wobleEquationx, _target_camera_translation.y * 0.1 + wobleEquationy, 0) * 2)
	
	if averageMovement > 0.2:
		stepVal = camera.translation.y
		if stepVal <= 0: if stepPos == true:step(stepPos, delta)
		else : if stepPos == false:step(stepPos, delta)

func step(_stepPos, delta):
	$Foot / FootStep.play = true
	camera.rotation.z = rand_range( - 0.02, 0.02)
	hand.translation.x = hand.translation.x + rand_range( - 0.2, 0.2) * delta * 10
	return not _stepPos


