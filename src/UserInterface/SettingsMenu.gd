extends Popup

onready var settingsTab = $Tabs
onready var displayOptionBtn = $Tabs/STOPTIONS/Margin/Grid/DisplayOptions
onready var bloomBtn = $Tabs/STOPTIONS/Margin/Grid/BloomBtn
onready var vsyncBtn = $Tabs/STOPTIONS/Margin/Grid/VsyncBtn
onready var brightValue = $Tabs/STOPTIONS/Margin/Grid/HBox/BgtValue
onready var brightSlider = $Tabs/STOPTIONS/Margin/Grid/HBox/BgtSlider
onready var masterValue = $Tabs/STOPTIONS/Margin/Grid/HBox2/VolValue
onready var masterSlider = $Tabs/STOPTIONS/Margin/Grid/HBox2/VolSlider
onready var languageBtn = $Tabs/STOPTIONS/Margin/Grid/Languages
onready var fovValue = $Tabs/STOPTIONS/Margin/Grid/HBox3/Label
onready var fovSlider = $Tabs/STOPTIONS/Margin/Grid/HBox3/HSlider
onready var mouseValue = $Tabs/STOPTIONS/Margin/Grid/HBox4/Label
onready var mouseSlider = $Tabs/STOPTIONS/Margin/Grid/HBox4/HSlider
onready var keyGrid = $Tabs/STKEYS/Margin/Grid
onready var controllerGrid = $Tabs/STCONTROLLER/Margin/Grid
onready var btnScript = load("res://src/UserInterface/KeyButton.gd")
onready var joybtnScript = load("res://src/UserInterface/JoyButton.gd")

var buttons = {}
var keybinds
var joybinds

func _ready():
	displayOptionBtn.select(1 if Save.game_data.fullscreen_on else 0)
	GlobalSettings.toggle_fullscreen(Save.game_data.fullscreen_on)
	bloomBtn.pressed = Save.game_data.bloom_on
	vsyncBtn.pressed = Save.game_data.vsync_on
	brightSlider.value = Save.game_data.brightness
	fovSlider.value = Save.game_data.fov
	mouseSlider.value = Save.game_data.mouse_sens
	masterSlider.value = Save.game_data.master_vol
	
	if Save.game_data.language == "en":
		TranslationServer.set_locale("en")
		languageBtn.selected = 1
	elif Save.game_data.language == "pt":
		TranslationServer.set_locale("pt")
		languageBtn.selected = 2
	
	GlobalSettings.set_keybinds()
	#GlobalSettings.set_joykeybinds()
	keybinds = Save.keybinds.duplicate()
	for key in keybinds.keys():
		var label = Label.new()
		var button = Button.new()
		
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND)
		button.set_h_size_flags(Control.SIZE_SHRINK_END)
		
		label.set_text(tr(str(key)))
		
		var button_value = keybinds[key]
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text.set_text(tr("STKUNASSIGNED"))
		
		button.set_script(btnScript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		keyGrid.add_child(label)
		keyGrid.add_child(button)
		
		buttons[key] = button
	
	if false:
		joybinds = Save.controller.duplicate()
		for key in joybinds.keys():
			var label = Label.new()
			var button = Button.new()
			
			label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			button.set_h_size_flags(Control.SIZE_EXPAND)
			button.set_h_size_flags(Control.SIZE_SHRINK_END)
			
			label.set_text(tr(str(key)))
			
			var button_value = joybinds[key]
			if button_value != null:
				button.text = joy_int_to_str(button_value)
				#Input.get_joy_button_string(button_value)
				#Input.get_joy_button_index_from_string(String)
			else:
				button.text.set_text(tr("STKUNASSIGNED"))
			
			button.set_script(joybtnScript)
			button.key = key
			button.value = button_value
			button.menu = self
			button.toggle_mode = true
			#button.focus_mode = Control.FOCUS_NONE
			
			controllerGrid.add_child(label)
			controllerGrid.add_child(button)
			
			buttons[key] = button
		var label = Label.new()
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_text(tr("USEMOUSE"))
		controllerGrid.add_child(label)

func _on_DisplayOptions_item_selected(index):
	GlobalSettings.toggle_fullscreen(true if index == 1 else false)

func _on_BloomBtn_toggled(button_pressed):
	GlobalSettings.toggle_bloom(button_pressed)

func _on_VsyncBtn_toggled(button_pressed):
	GlobalSettings.toggle_vsync(button_pressed)

func _on_BgtSlider_value_changed(value):
	GlobalSettings.update_brightness(value)
	brightValue.text = str(Save.game_data.brightness)

func _on_VolSlider_value_changed(value):
	GlobalSettings.update_vol(value)
	masterValue.text = str(Save.game_data.master_vol)

func _on_FOV_value_changed(value):
	GlobalSettings.update_fov(value)
	fovValue.text = str(Save.game_data.fov)

func _on_MouseSens_value_changed(value):
	GlobalSettings.update_mouse_sens(value)
	mouseValue.text = str(Save.game_data.mouse_sens)

func _on_Languages_item_selected(index):
	if index == 1:
		TranslationServer.set_locale("en")
		Save.game_data.language = "en"
	elif index == 2:
		TranslationServer.set_locale("pt")
		Save.game_data.language = "pt"
	Save.save_data()

func _on_Reset_button_up():
	keybinds = Save.standard_keybinds.duplicate()
	Save.keybinds = Save.standard_keybinds.duplicate()
	for k in keybinds.keys():
		buttons[k].value = keybinds[k]
		buttons[k].text = OS.get_scancode_string(keybinds[k])
	GlobalSettings.set_keybinds()
	GlobalSettings.write_config()

func _on_Save_button_up():
	Save.keybinds = keybinds.duplicate()
	GlobalSettings.set_keybinds()
	GlobalSettings.write_config()

func _on_joyReset_button_up():
	joybinds = Save.standard_controller.duplicate()
	Save.controller = Save.standard_controller.duplicate()
	for k in joybinds.keys():
		buttons[k].value = joybinds[k]
		buttons[k].text = joy_int_to_str(joybinds[k])
	GlobalSettings.set_joykeybinds()
	GlobalSettings.write_config()

func _on_joySave_button_up():
	Save.controller = joybinds.duplicate()
	GlobalSettings.set_joykeybinds()
	GlobalSettings.write_config()

func joy_int_to_str(value: int):
	var text = Input.get_joy_button_string(value)
	match value:
		0:
			text = "A"
		1:
			text = "B"
		2:
			text = "X"
		3:
			text = "Y"
		10:
			text = "Select"
		11:
			text = "Start"
		12:
			text = "DPadUp"
		13:
			text = "DPadDown"
		14:
			text = "DPadLeft"
		15:
			text = "DPadRight"
	return text

func change_bind(key, value):
	keybinds[key] = value
	for k in keybinds.keys():
		if k != key and value != null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[k].set_text(tr("STKUNASSIGNED"))

func change_bind_joy(key, value):
	joybinds[key] = value
	for k in joybinds.keys():
		if k != key and value != null and joybinds[k] == value:
			joybinds[k] = null
			buttons[k].value = null
			buttons[k].set_text(tr("STKUNASSIGNED"))

func _on_Tabs_tab_selected(tab):
	if tab == 2:
		settingsTab.current_tab = 0
		self.visible = false
