extends CharacterBody3D

@export var speed : float = 2.0
@export var jump_velocity : float = 4.0
@export var stick_sensivity : float = 100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_input_direction : Vector2 = Vector2.ZERO
var movement_input_point : Vector2 = Vector2.ZERO

var is_movement : bool = false

@onready var screen_size : Vector2 = get_viewport().size

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = (transform.basis * Vector3(movement_input_direction.x, 0, movement_input_direction.y)).normalized()
	
	if movement_input_direction.length() >= 0.15:
		velocity.x = movement_input_direction.x * speed
		velocity.z = movement_input_direction.y * speed
	else:
		velocity.x = 0#move_toward(velocity.x, 0, speed)
		velocity.z = 0#move_toward(velocity.z, 0, speed)
	
	var look_target : Vector3 = global_position - velocity.normalized()
	look_target.y = 0
	
	if look_target.length() > 0:
		look_at(look_target, Vector3.UP)
	
	move_and_slide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.position.x < screen_size.x/2:
			is_movement = true
			movement_input_point = event.position
	if event is InputEventScreenDrag:
		if is_movement:
			movement_input_direction = ((abs(event.relative - event.position) - movement_input_point) / 100 * stick_sensivity).normalized()
	else:
		movement_input_direction = Vector2.ZERO
		is_movement = false

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
