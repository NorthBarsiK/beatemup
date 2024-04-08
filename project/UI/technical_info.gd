extends Control

@onready var info : Label = $Info

func _physics_process(delta):
	var info_text : String = "\n"
	info_text += "OS: %s\n" % OS.get_name()
	info_text += "FPS: %.0f\n" % Engine.get_frames_per_second()
	info.text = info_text
