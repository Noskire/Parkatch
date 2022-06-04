extends KinematicBody

onready var bodyAnim: AnimationPlayer = $Michelle/RootNode/AnimationPlayer
onready var springArm: SpringArm = $SpringArm
onready var camera: Camera = $SpringArm/Camera
onready var tween = $Tween
onready var headRays = $HeadRays
onready var chestRay = $Chest

onready var body_to_move = self

export var speed = 7.0
export var walkSpeed = 7.0
export var runSpeed = 14.0
export var jumpStrength = 20.0
export var gravity = 50.0

var velocity = Vector3.ZERO
var snapVector = Vector3.DOWN

var canJump = true
var isCrouching = false
var calledClimb = false

# States
var IDLE = false
var RUN = false
var JUMP = false
var CROUCHED = false
var HANGING = false
var SLIDE = false

func _ready():
	bodyAnim.play("Idle")
	var err = bodyAnim.connect("animation_finished", self, "on_animation_finished")
	if err != OK:
		print("ERROR: Connection with bodyAnim")

func _physics_process(delta: float) -> void:
	var moveDirection = Vector3.ZERO

	moveDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	moveDirection.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	moveDirection = moveDirection.rotated(Vector3.UP, springArm.rotation.y).normalized()
	
	if Input.is_action_pressed("run"):
		speed = runSpeed
		RUN = true
	else:
		speed = walkSpeed
		RUN = false
	
	IDLE = true if moveDirection.x == 0 and moveDirection.z == 0 else false
	
	if Input.is_action_just_pressed("crouch"):
		if not JUMP and not SLIDE:
			if CROUCHED:
				CROUCHED = false
			elif speed == walkSpeed:
				CROUCHED = true
			else:
				SLIDE = true
				bodyAnim.play("Slide")

	velocity.x = moveDirection.x * speed
	velocity.z = moveDirection.z * speed
	velocity.y -= gravity * delta
	
	var justLanded = is_on_floor() and snapVector == Vector3.ZERO
	var isJumping = is_on_floor() and Input.is_action_just_pressed("jump")
	if isJumping:
		velocity.y = jumpStrength
		snapVector = Vector3.ZERO
		JUMP = true
		if speed == walkSpeed:
			bodyAnim.play("Jump")
		else:
			bodyAnim.play("RunJump")
	elif justLanded:
		snapVector = Vector3.DOWN
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, true)
	
	if Input.is_action_pressed("jump") and can_climb():
		bodyAnim.play("HangToCrouch")
		grab_ledge()
	
	if velocity.length() > 0.2:
		var lookDirection = Vector2(moveDirection.z, moveDirection.x)
		if lookDirection.angle() != 0:
			rotation.y = lookDirection.angle()
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	handle_body_anim()

func _process(_delta: float) -> void:
	springArm.translation = translation

func handle_body_anim():
	#if JUMP:
		#if speed == walkSpeed:
			#bodyAnim.play("Jump")
		#else:
			#bodyAnim.play("RunJump")
	#elif HANGING:
		#bodyAnim.play("HangToCrouch")
	#elif SLIDE:
		#bodyAnim.play("Slide")
	#else:
	if bodyAnim.current_animation != "Jump" and bodyAnim.current_animation != "RunJump" and bodyAnim.current_animation != "HangToCrouch" and bodyAnim.current_animation != "Slide":
		if CROUCHED:
			if IDLE:
				bodyAnim.play("Crouched")
			else:
				bodyAnim.play("CrouchedWalk")
		else:
			if IDLE:
				bodyAnim.play("Idle")
			elif RUN:
				bodyAnim.play("FastRun")
			else:
				bodyAnim.play("Walking")

func can_climb() -> bool:
	if not chestRay.is_colliding():
		return false
	for ray in headRays.get_children():
		if ray.is_colliding():
			return false
	return true

func grab_ledge():
	velocity = Vector3.ZERO
	climb_ledge()

func climb_ledge():
	if calledClimb:
		return
	calledClimb = true
	climb()

func climb():
	canJump = false
	springArm.camInputFrozen = true
	var vMoveTime = 0.733
	var hMoveTime = 0.4
	if not isCrouching:
		var verticalMovement = global_transform.origin + Vector3(0, 1.70, 0)
		tween.interpolate_property(self, "global_transform:origin", null, verticalMovement, vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(camera, "rotation_degrees:x", null, clamp(camera.rotation_degrees.x - 20.0, -90, 90), vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(camera, "rotation_degrees:z", null, (-5.0 * sign(rand_range(-10000, 10000))), vMoveTime, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_all_completed")
		var forwardMovement = global_transform.origin + (global_transform.basis.z * 1.2)
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
	springArm.camInputFrozen = false

func ledge_climb_completed():
	calledClimb = false

func on_animation_finished(anim_name):
	if anim_name == "Jump" or anim_name == "RunJump" or anim_name == "HangToCrouch" or anim_name == "Slide":
		JUMP = false
		CROUCHED = false
		SLIDE = false
		bodyAnim.play("Idle")

# Not Used
func disable_ledge_grabbing():
	chestRay.enabled = false

func enable_ledge_grabbing():
	chestRay.enabled = true

func release_ledge():
	disable_ledge_grabbing()
