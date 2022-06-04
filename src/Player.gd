extends KinematicBody

onready var _springArm: SpringArm = $SpringArm
onready var _model: MeshInstance = $MeshInstance
onready var camera: Camera = $SpringArm/Camera
onready var tween = $Tween
onready var headRays = $HeadRays
onready var chestRay = $Chest

onready var body_to_move = self

export var speed = 7.0
export var jumpStrength = 20.0
export var gravity = 50.0

var _velocity = Vector3.ZERO
var _snapVector = Vector3.DOWN

var canJump = true
var camInputFrozen = false
var isCrouching = false
var calledClimb = false

enum STATES {IDLE, HANGING}
var cur_state = STATES.HANGING

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
	
	if Input.is_action_pressed("jump") and can_climb():
		grab_ledge()
	
	if _velocity.length() > 0.2:
		var lookDirection = Vector2(_velocity.z, _velocity.x)
		_model.rotation.y = lookDirection.angle()
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(_delta: float) -> void:
	_springArm.translation = translation

func can_climb() -> bool:
	if not chestRay.is_colliding():
		return false
	for ray in headRays.get_children():
		if ray.is_colliding():
			return false
	return true

func climb():
	canJump = false
	camInputFrozen = true
	var vMoveTime = 0.4
	var hMoveTime = 0.2
	if not isCrouching:
		var verticalMovement = global_transform.origin + Vector3(0, 1.85, 0)
		tween.interpolate_property(self, "global_transform:origin", null, verticalMovement, vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(camera, "rotation_degrees:x", null, clamp(camera.rotation_degress.x - 20.0, -90, 90), vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(camera, "rotation_degrees:z", null, (-5.0 * sign(rand_range(-10000, 10000))), vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		
		yield(tween, "tween_all_completed")
		var forwardMovement = global_transform.origin + (-global_transform.basis.z * 1.2)
		tween.interpolate_property(self, "global_transform:origin", null, forwardMovement, hMoveTime, Tween.TRANS_LINEAR)
		tween.interpolate_property(camera, "rotation_degrees:x", null, 0.0, hMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(camera, "rotation_degrees:z", null, 0.0, hMoveTime, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		var verticalMovement = global_transform.origin + Vector3(0, 1.05, 0)
		tween.interpolate_property(self, "global_transform:origin", null, verticalMovement, vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_all_completed")
		var forwardMovement = global_transform.origin + (-global_transform.basis.z * 1.2)
		tween.interpolate_property(self, "global_transform:origin", null, forwardMovement, hMoveTime, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_all_completed")
	ledge_climb_completed()
	canJump = true
	camInputFrozen = false

func disable_ledge_grabbing():
	chestRay.enabled = false

func enable_ledge_grabbing():
	chestRay.enabled = true

func grab_ledge():
	_velocity = Vector3.ZERO
	cur_state = STATES.HANGING
	climb_ledge()

func climb_ledge():
	if calledClimb:
		return
	calledClimb = true
	body_to_move.climb()

func ledge_climb_completed():
	calledClimb = false
	cur_state = STATES.IDLE

func release_ledge():
	body_to_move.disable_ledge_grabling()
