extends KinematicBody

onready var sceneTree: = get_tree()
onready var bodyAnim: AnimationPlayer = $Michelle/RootNode/AnimationPlayer
onready var collisionStand: CollisionShape = $CollisionShape
onready var collisionCrouch: CollisionShape = $CollisionShapeCrouched
onready var springArm: SpringArm = $SpringArm
onready var camera: Camera = $SpringArm/Camera
onready var tween = $Tween
onready var headRays = $HeadRays
onready var chestRay = $Chest
onready var ltimer = $CanvasLayer/Control/Timer
onready var lscore = $CanvasLayer/Control/Score

export(String, FILE) var screen_path: = ""

export var speed = 7.0
export var walkSpeed = 7.0
export var runSpeed = 14.0
export var jumpStrength = 20.0
export var jumpGravity = 50.0
export var floorGravity = 250.0

var velocity = Vector3.ZERO
var snapVector = Vector3.DOWN
var gravity

var canJump = true
var isCrouching = false

var score = 0
var timer = 0

# States
var IDLE = false
var RUN = false
var JUMP = false
var CROUCHED = false
var HANGING = false
var SLIDE = false

func _ready():
	if GlobalSettings.gameMode == 1:
		# Max time, 2m
		timer = 2 * 60.0
		ltimer.set_text("2:00")
	elif GlobalSettings.gameMode == 2:
		timer = 0
		ltimer.set_text("0:00")
	gravity = jumpGravity
	bodyAnim.play("Idle")
	var err = bodyAnim.connect("animation_finished", self, "on_animation_finished")
	if err != OK:
		print("ERROR: Connection with bodyAnim")

func _physics_process(delta: float) -> void:
	lscore.set_text(str(score))
	if GlobalSettings.gameMode == 1:
		timer -= delta
		var minute = int(timer / 60)
		var second = int(timer - minute * 60)
		if second < 10:
			ltimer.set_text(str(minute, ":0", second))
		else:
			ltimer.set_text(str(minute, ":", second))
		
		if timer <= 0:
			end_level()
	elif GlobalSettings.gameMode == 2:
		timer += delta
		var minute = int(timer / 60)
		var second = int(timer - minute * 60)
		if second < 10:
			ltimer.set_text(str(minute, ":0", second))
		else:
			ltimer.set_text(str(minute, ":", second))
		
		if score >= 1:
			end_level()
	
	var moveDirection = Vector3.ZERO
	
	if not HANGING:
		moveDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		moveDirection.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
		moveDirection = moveDirection.rotated(Vector3.UP, springArm.rotation.y).normalized()
	
	if Input.is_action_pressed("run") and not CROUCHED:
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
				collisionStand.set_disabled(false)
				collisionCrouch.set_disabled(true)
			elif speed == walkSpeed:
				CROUCHED = true
				collisionStand.set_disabled(true)
				collisionCrouch.set_disabled(false)
			else:
				SLIDE = true
				collisionStand.set_disabled(true)
				collisionCrouch.set_disabled(false)
				bodyAnim.play("Slide")

	velocity.x = moveDirection.x * speed
	velocity.z = moveDirection.z * speed
	velocity.y -= gravity * delta
	
	
	if JUMP and is_on_floor():
		JUMP = false

	var justLanded = is_on_floor() and snapVector == Vector3.ZERO
	var isJumping = is_on_floor() and Input.is_action_just_pressed("jump")
	if isJumping and not SLIDE:
		velocity.y = jumpStrength
		snapVector = Vector3.ZERO
		JUMP = true
		if speed == walkSpeed:
			bodyAnim.play("Jump")
		else:
			bodyAnim.play("RunJump")
	elif justLanded:
		snapVector = Vector3.DOWN
	if not is_on_floor() and not JUMP:
		gravity = floorGravity
	else:
		gravity = jumpGravity
		
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, true)
	
	if Input.is_action_pressed("jump") and can_climb():
		bodyAnim.play("HangToCrouch")
		grab_ledge()
	
	if velocity.length() > 0.2:
		var lookDirection = Vector2(moveDirection.z, moveDirection.x)
		if lookDirection.angle() != 0:
			rotation.y = lookDirection.angle()
	
	handle_body_anim()

func _process(_delta: float) -> void:
	springArm.translation = translation

func handle_body_anim():
	#if bodyAnim.current_animation != "Jump" and bodyAnim.current_animation != "RunJump" and bodyAnim.current_animation != "HangToCrouch" and bodyAnim.current_animation != "Slide":
	if not JUMP and not HANGING and bodyAnim.current_animation != "Slide":
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

func getPoint():
	score += 1

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
	if HANGING:
		return
	HANGING = true
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
	HANGING = false

func on_animation_finished(anim_name):
	if anim_name == "Jump" or anim_name == "RunJump" or anim_name == "HangToCrouch" or anim_name == "Slide":
		if SLIDE:
			collisionStand.set_disabled(false)
			collisionCrouch.set_disabled(true)
		if JUMP and not is_on_floor():
			pass
		else:
			JUMP = false
			CROUCHED = false
			SLIDE = false
			bodyAnim.play("Idle")

func end_level():
	if GlobalSettings.gameMode == 1:
		GlobalSettings.ballsOnTime = score
	elif GlobalSettings.gameMode == 2:
		GlobalSettings.bestTime = timer
	var err
	err = sceneTree.change_scene(screen_path)
	if err != OK:
		print("Error change_scene Player to ", screen_path)
