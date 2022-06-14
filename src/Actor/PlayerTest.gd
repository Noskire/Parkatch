extends KinematicBody
export (int, 0, 100) var inertia = 1
var speed = 5
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 25
var jump = 8
var full_contact = false
var active = true

var mouse_sensitivity = 0.15
var controller_sensitivity = 5
onready var camera: Camera = get_node("Camera")

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

onready var _camera = $Camera
onready var ground_check = $GroundCheck

func _process(_delta):
		camera.rotation_degrees.x -= (Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")) * controller_sensitivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 90.0)
		
		rotation_degrees.y -= (Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")) * controller_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)


func _input(event: InputEvent):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event  is InputEventMouseMotion:
		camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 90.0)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
		
func _physics_process(delta):
	if active:
		$Camera.make_current()
		movement(delta)
	elif !active:
		hide()
		$"CollisionShape".disabled = true
		
		pass
	
func movement(delta):
	
	direction = Vector3()
	
	full_contact = ground_check.is_colliding()
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("back"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x


		
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement, Vector3.UP,
		false, 4, PI/4, false)
	
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("objects"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)
			
	if Input.is_action_pressed("pause"):
		get_tree().quit()
