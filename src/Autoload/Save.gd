extends Node

const SAVEFILE = "user://saveFile.save"
const SAVEKEYS = "user://keyBinds.ini"
const SAVECONTROLLER = "user://controllerBinds.ini"

var standard_keybinds = {
	"forward": 87,
	"left": 65,
	"back": 83,
	"right": 68,
	"jump": 32,
	"run": 16777237,
	"crouch": 67,
	"pause": 82
}

var standard_controller = {
	"jump": JOY_XBOX_Y,
	"run": JOY_XBOX_B,
	"crouch": JOY_XBOX_A,
	"pause": JOY_START
}

var game_data = {}
var keybinds = {}
var controller = {}
var configfile
var joyconfigfile

func _ready():
	load_data()
	load_keys()
	load_joykeys()

func load_data():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		game_data = {
			"fullscreen_on": false,
			"bloom_on": true,
			"vsync_on": true,
			"brightness": 1,
			"master_vol": -10,
			"language": "en",
			"fov": 70,
			"mouse_sens": 0.05
		}
		save_data()
	file.open(SAVEFILE, File.READ)
	game_data = file.get_var()
	file.close()

func load_keys():
	configfile = ConfigFile.new()
	if configfile.load(SAVEKEYS) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		# Create .ini file
		for key in standard_keybinds.keys():
			var key_value = standard_keybinds[key]
			configfile.set_value("keybinds", key, key_value)
		configfile.save(SAVEKEYS)
		keybinds = standard_keybinds.duplicate()

func load_joykeys():
	joyconfigfile = ConfigFile.new()
	if joyconfigfile.load(SAVECONTROLLER) == OK:
		for key in joyconfigfile.get_section_keys("keybinds"):
			var key_value = joyconfigfile.get_value("keybinds", key)
			if str(key_value) != "":
				controller[key] = key_value
			else:
				controller[key] = null
	else:
		# Create .ini file
		for key in standard_controller.keys():
			var key_value = standard_controller[key]
			joyconfigfile.set_value("keybinds", key, key_value)
		joyconfigfile.save(SAVECONTROLLER)
		controller = standard_controller.duplicate()

func save_data():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(game_data)
	file.close()

func save_keys():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(SAVEKEYS)

func save_joykeys():
	for key in controller.keys():
		var key_value = controller[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(SAVECONTROLLER)
