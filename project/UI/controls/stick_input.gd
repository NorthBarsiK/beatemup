extends Node

class_name StickController

signal stick_drag (stick_center : Vector2, stick_vector : Vector2)

@onready var screen_size : Vector2 = DisplayServer.window_get_size_with_decorations()

var stick_sensivity : float = 0.5
var stick_death_zone : float = 0.15
var stick_vector : Vector2 = Vector2.ZERO
var stick_center : Vector2 = Vector2.ZERO
var stick_tap_index : int = -1

func set_stick_parameters(sensivity_arg : float, death_zone_arg : float):
	stick_sensivity = sensivity_arg
	stick_death_zone = death_zone_arg

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			print("Event position: %s - Screen size: %s" % [event.position, screen_size])
			if event.position.x < screen_size.x/2:
				if event.index != stick_tap_index:
					stick_center = event.position
					stick_tap_index = event.index
				#print("Stick index: %s - Touch index: %s" % [event.index, stick_tap_index])
		if event.is_released() and event.index == stick_tap_index:
			stick_vector = Vector2.ZERO
			stick_center = Vector2.ZERO
			stick_tap_index = -1
			emit_signal("stick_drag", Vector2.ZERO, Vector2.ZERO)
	if event is InputEventScreenDrag:
		if event.position.x < screen_size.x/2:
			if event.index == stick_tap_index:
				stick_vector.x = ((event.relative.x + event.position.x) - stick_center.x) / 64
				stick_vector.y = ((event.relative.y + event.position.y) - stick_center.y) / 64
				#stick_vector.x = clamp(stick_vector.x, -1.0, 1.0)
				#stick_vector.y = clamp(stick_vector.y, -1.0, 1.0)
				stick_vector = stick_vector.limit_length(1.0)
				print(stick_vector)
				if stick_vector.length() > stick_death_zone:
					emit_signal("stick_drag", stick_center, stick_vector)
				else:
					emit_signal("stick_drag", Vector2.ZERO, Vector2.ZERO)
	
