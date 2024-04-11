extends TextureButton

var tap_index : int = -1

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		print("Touch node %s with index %s" % [name, event.index])
		if event.is_pressed():
			if event.index != tap_index:
				tap_index = event.index
				emit_signal("button_down")
		if event.is_released():
			if event.index == tap_index:
				tap_index = -1
				emit_signal("button_up")
			
