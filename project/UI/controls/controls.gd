extends Control

signal jump
signal move (movement_vector : Vector2)

@export var stick_sensivity : float = 4
@export var stick_death_zone : float = 0.15

@onready var touch_input : StickController = get_node("StickInput")
@onready var stick_frame : TextureRect = get_node("StickFrame")
@onready var stick_point : TextureRect = get_node("StickPoint")

var stick_center : Vector2 = Vector2.ZERO
var stick_vector : Vector2 = Vector2.ZERO

func _ready():
	touch_input.set_stick_parameters(stick_sensivity, stick_death_zone)
	
func emit_jump():
	emit_signal("jump")

func _on_stick_drag(stick_center_arg : Vector2, stick_vector_arg : Vector2):
	emit_signal("move", stick_vector_arg)
	stick_center = stick_center_arg
	stick_vector = stick_vector_arg

func _process(delta):
	#print(stick_vector)
	if stick_center != Vector2.ZERO:
		if not stick_frame.visible:
			stick_frame.visible = true
		if not stick_point.visible:
			stick_point.visible = true
		
		stick_frame.position = stick_center - stick_frame.size/2
		stick_point.position = (stick_frame.position + stick_frame.size/2 - stick_point.size/2) + ((stick_frame.size.x + stick_point.size.x) / stick_sensivity * stick_vector)
		
	else:
		stick_frame.visible = false
		stick_point.visible = false
