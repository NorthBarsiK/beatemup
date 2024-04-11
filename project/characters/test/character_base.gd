extends CharacterBody3D

@export var speed : float = 2.0
@export var jump_velocity : float = 4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_direction : Vector2 = Vector2.ZERO
var movement_input_point : Vector2 = Vector2.ZERO

var is_movement : bool = false


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if movement_direction.length() > 0:
		velocity.x = movement_direction.x * speed
		velocity.z = movement_direction.y * speed
		
		var look_target : Vector3 = global_position - velocity.normalized()
		look_target.y = global_position.y
		if look_target.length() > 0:
			look_at(look_target, Vector3.UP)
	else:
		velocity.x = 0#move_toward(velocity.x, 0, speed)
		velocity.z = 0#move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func set_movement_vector(movement_vector : Vector2):
	movement_direction = movement_vector

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
