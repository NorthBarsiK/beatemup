extends Control

signal jump
signal kick
signal punch
signal move (movement_vector : Vector2)

@export var stick_sensivity : float = 4
@export var stick_death_zone : float = 0.15

@onready var stick : StickController = get_node("StickInput")
@onready var stick_frame : TextureRect = get_node("StickFrame")
@onready var stick_point : TextureRect = get_node("StickPoint")

var stick_center : Vector2 = Vector2.ZERO
var stick_vector : Vector2 = Vector2.ZERO

func _ready():
	stick.set_stick_parameters(stick_sensivity, stick_death_zone)
	
func _emit_jump():
	emit_signal("jump")

func _emit_kick():
	emit_signal("kick")

func _emit_punch():
	emit_signal("punch")

func _on_stick_drag(stick_center_arg : Vector2, stick_vector_arg : Vector2):
	emit_signal("move", stick_vector_arg)
	stick_center = stick_center_arg
	stick_vector = stick_vector_arg

func _process(delta):
	set_stick_position()

func set_stick_position():
	if stick_center != Vector2.ZERO:
		if not stick_frame.visible:
			stick_frame.show()
		if not stick_point.visible:
			stick_point.show()
		
		var stick_frame_offset = stick_frame.size/2 * stick_frame.scale
		var stick_point_offset = stick_point.size/2 * stick_point.scale
		
		stick_frame.position = stick_center - stick_frame.size/2
		stick_point.position = (stick_frame.position + stick_frame_offset - stick_point_offset)\
		 + ((stick_frame.size.x + stick_point.size.x) / stick_sensivity * stick_vector)
	else:
		stick_frame.hide()
		stick_point.hide()
