extends Control

onready var sceneTree: = get_tree()
onready var lscore: Label = get_node("Score")

export(String, FILE) var screen_path: = ""

func _ready():
	if GlobalSettings.gameMode == 1:
		lscore.set_text(tr("SCORE") + " %s" % GlobalSettings.ballsOnTime)
	elif GlobalSettings.gameMode == 2:
		var timer = GlobalSettings.bestTime
		var minute = int(timer / 60)
		var second = int(timer - minute * 60)
		if second < 10:
			lscore.set_text(str(tr("SCORE"), " ", minute, ":0", second))
		else:
			lscore.set_text(str(tr("SCORE"), " ", minute, ":", second))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_MainMenu_button_up():
	var err
	err = sceneTree.change_scene(screen_path)
	if err != OK:
		print("Error change_scene MenuButton")
