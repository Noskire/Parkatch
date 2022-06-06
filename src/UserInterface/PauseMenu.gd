extends Control

onready var sceneTree: = get_tree()
onready var pauseOverlay: ColorRect = get_node("PauseOverlay")
onready var camera: SpringArm = get_parent().get_parent().get_node("SpringArm")
onready var settingsMenu = get_node("SettingsMenu")

export(String, FILE) var next_scene_path: = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if pauseOverlay.visible: # Paused
			camera.capture_mouse()
			sceneTree.paused = false
			pauseOverlay.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			sceneTree.paused = true
			pauseOverlay.visible = true
			$PauseOverlay/VBox/Resume.grab_focus()
		sceneTree.set_input_as_handled()

func _on_Resume_button_up():
	camera.capture_mouse()
	sceneTree.paused = false
	pauseOverlay.visible = false

func _on_Restart_button_up():
	sceneTree.paused = false
	var err
	err = sceneTree.reload_current_scene()
	if err != OK:
		print("Error reload_scene RestartButton")

func _on_Settings_button_up():
	settingsMenu.popup_centered()

func _on_MainMenu_button_up():
	sceneTree.paused = false
	
	var err
	err = sceneTree.change_scene(next_scene_path)
	if err != OK:
		print("Error change_scene MenuButton")
