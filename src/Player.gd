extends KinematicBody

onready var _springArm: SpringArm = $SpringArm
onready var _model: MeshInstance = $MeshInstance
onready var tween = $Tween
onready var headRays = $HeadRays
onready var chestRay = $Chest

export var speed = 7.0
export var jumpStrength = 20.0
export var gravity = 50.0

var _velocity = Vector3.ZERO
var _snapVector = Vector3.DOWN

func _physics_process(delta: float) -> void:
	var moveDirection = Vector3.ZERO
	moveDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	moveDirection.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	moveDirection = moveDirection.rotated(Vector3.UP, _springArm.rotation.y).normalized()
	
	_velocity.x = moveDirection.x * speed
	_velocity.z = moveDirection.z * speed
	_velocity.y -= gravity * delta
	
	var justLanded = is_on_floor() and _snapVector == Vector3.ZERO
	var isJumping = is_on_floor() and Input.is_action_just_pressed("jump")
	if isJumping:
		_velocity.y = jumpStrength
		_snapVector = Vector3.ZERO
	elif justLanded:
		_snapVector = Vector3.DOWN
	_velocity = move_and_slide_with_snap(_velocity, _snapVector, Vector3.UP, true)
	
	if _velocity.length() > 0.2:
		var lookDirection = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = lookDirection.angle()

func _process(_delta: float) -> void:
	_springArm.translation = translation
