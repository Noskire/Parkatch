extends Control

onready var playButton = $Margin/VBox/Menu/PlayButton
onready var settingsMenu = $SettingsMenu
onready var gameModes = $GameModes

export(String, FILE) var modeScoreScenePath: = ""
export(String, FILE) var modeTimeTrialScenePath: = ""

func _ready():
	playButton.grab_focus()

func _on_PlayButton_button_up():
	gameModes.set_visible(not gameModes.visible)

func _on_SettingsButton_button_up():
	settingsMenu.popup()

func _on_QuitButton_button_up():
	get_tree().quit()

func _on_ModeScore_button_up():
	GlobalSettings.gameMode = 1
	var err = get_tree().change_scene(modeScoreScenePath)
	if err != OK:
		print("Error MainScreen")

func _on_ModeTraining_button_up():
	GlobalSettings.gameMode = 0
	var err = get_tree().change_scene(modeScoreScenePath)
	if err != OK:
		print("Error MainScreen")

func _on_ModeTime_button_up():
	GlobalSettings.gameMode = 2
	var err = get_tree().change_scene(modeTimeTrialScenePath)
	if err != OK:
		print("Error MainScreen")

func _on_TimeTraining_button_up():
	GlobalSettings.gameMode = 0
	var err = get_tree().change_scene(modeTimeTrialScenePath)
	if err != OK:
		print("Error MainScreen")
