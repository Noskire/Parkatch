extends Control

onready var sceneTree: = get_tree()
onready var lscore: Label = get_node("Score")

export(String, FILE) var screen_path: = ""

func _ready():
	lscore.set_text(tr("SCORE") + " %s" % GlobalSettings.ballsOnTime)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_MainMenu_button_up():
	var err
	err = sceneTree.change_scene(screen_path)
	if err != OK:
		print("Error change_scene MenuButton")
