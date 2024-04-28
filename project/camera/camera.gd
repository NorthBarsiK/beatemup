extends Node3D

@export var target_node_path : NodePath
@export var is_follow : bool = true

var target_node : Node3D = null

func _ready():
	target_node = get_node(target_node_path)
	
func _physics_process(delta):
	if is_follow and target_node != null:
		global_position = target_node.global_position
