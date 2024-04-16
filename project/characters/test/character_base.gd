extends CharacterBody3D

@export var speed : float = 2.0
@export var jump_velocity : float = 4.0
@export var fight_target_node : NodePath

@onready var animation_player : AnimationPlayer = $Mesh/AnimationPlayer

var fight_target : Node = null

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_direction : Vector2 = Vector2.ZERO

func _ready():
	animation_player.add_animation_library("hero_animations", load("res://characters/hero/animations/hero_animations.tres"))
	if not fight_target_node.is_empty():
		fight_target = get_node(fight_target_node)
	

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if movement_direction.length() > 0:
		velocity.x = movement_direction.x * speed
		velocity.z = movement_direction.y * speed
		animation_player.play("hero_animations/walk_1")
		
		var look_target : Vector3 = Vector3.ZERO
		
		if fight_target == null:
			look_target = global_position + velocity.normalized()
		else:
			look_target = fight_target.global_position
		
		look_target.y = global_position.y
		
		if look_target.length() > 0:
			look_at(look_target, Vector3.UP, true)
	else:
		velocity.x = 0
		velocity.z = 0
		animation_player.play("hero_animations/idle_1")
	
	move_and_slide()

func move(movement_vector : Vector2):
	movement_direction = movement_vector

func jump():
	if is_on_floor():
		velocity.y = jump_velocity

func set_target(new_target : Node3D):
	fight_target = new_target
