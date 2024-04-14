extends Node

class_name StickController

signal stick_drag (stick_center : Vector2, stick_vector : Vector2)

@onready var screen_size : Vector2 = DisplayServer.window_get_size_with_decorations()

var stick_sensivity : float = 0.5
var stick_death_zone : float = 0.15
var stick_vector : Vector2 = Vector2.ZERO
var stick_center : Vector2 = Vector2.ZERO
var stick_touch_index : int = -1

func set_stick_parameters(sensivity_arg : float, death_zone_arg : float):
	stick_sensivity = sensivity_arg
	stick_death_zone = death_zone_arg

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if event.position.x < screen_size.x/2:
				if event.index != stick_touch_index:
					stick_center = event.position
					stick_touch_index = event.index
		if event.is_released() and event.index == stick_touch_index:
			stick_vector = Vector2.ZERO
			stick_center = Vector2.ZERO
			stick_touch_index = -1
			emit_signal("stick_drag", Vector2.ZERO, Vector2.ZERO)
	if event is InputEventScreenDrag:
		if event.position.x < screen_size.x/2:
			if event.index == stick_touch_index:
				stick_vector.x = ((event.relative.x + event.position.x) - stick_center.x) / 64
				stick_vector.y = ((event.relative.y + event.position.y) - stick_center.y) / 64
				stick_vector = stick_vector.limit_length(1.0)
				print(stick_vector)
				if stick_vector.length() > stick_death_zone:
					emit_signal("stick_drag", stick_center, stick_vector)
				else:
					emit_signal("stick_drag", Vector2.ZERO, Vector2.ZERO)
	
