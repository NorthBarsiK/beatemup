extends CharacterBody3D

@export var speed : float = 2.0
@export var jump_velocity : float = 4.0

@onready var animation_player : AnimationPlayer = $Mesh/AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_direction : Vector2 = Vector2.ZERO
var movement_input_point : Vector2 = Vector2.ZERO

var is_movement : bool = false

func _ready():
	animation_player.add_animation_library("hero_animations", load("res://characters/hero/animations/hero_animations.tres"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if movement_direction.length() > 0:
		velocity.x = movement_direction.x * speed
		velocity.z = movement_direction.y * speed
		animation_player.play("hero_animations/walk_1")
		
		var look_target : Vector3 = global_position - velocity.normalized()
		look_target.y = global_position.y
		if look_target.length() > 0:
			look_at(look_target, Vector3.UP)
	else:
		velocity.x = 0#move_toward(velocity.x, 0, speed)
		velocity.z = 0#move_toward(velocity.z, 0, speed)
		animation_player.play("hero_animations/idle_1")
	
	move_and_slide()

func set_movement_vector(movement_vector : Vector2):
	movement_direction = movement_vector

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
