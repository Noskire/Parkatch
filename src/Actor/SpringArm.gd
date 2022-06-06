extends SpringArm

export var mouseSensitivity = 0.05
export var controllerSensitivity = 2.5
export var camInputFrozen = false

func _ready() -> void:
	set_as_toplevel(true)
	capture_mouse()

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta: float) -> void:
	rotation_degrees.x -= (Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")) * controllerSensitivity
	rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 0.0)
	
	rotation_degrees.y += (Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")) * controllerSensitivity
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not camInputFrozen:
		rotation_degrees.x -= event.relative.y * mouseSensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation_degrees.y -= event.relative.x * mouseSensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
