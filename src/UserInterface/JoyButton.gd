extends Button

var key
var value
var menu

var waiting_input = false

func _input(event):
	if waiting_input:
		if event is InputEventJoypadButton:
			value = event.get_button_index()
			if value == 0:
				text = "A"
			elif value == 1:
				text = "B"
			elif value == 3:
				text = "Y"
			elif value == 11:
				text = "Start"
			text = menu.joy_int_to_str(value)
			menu.change_bind_joy(key, value)
			pressed = false
			waiting_input = false
		if event is InputEventMouseButton:
			if value != null:
				text = menu.joy_int_to_str(value)
			else:
				text = "STKUNASSIGNED"
			pressed = false
			waiting_input = false

func _toggled(button_pressed):
	if button_pressed:
		waiting_input = true
		set_text("STKPRESSKEY")
