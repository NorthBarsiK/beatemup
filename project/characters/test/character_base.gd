extends CharacterBody3D

@export var speed : float = 2.0
@export var jump_velocity : float = 4.0
@export var stick_sensivity : float = 0.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_input_direction : Vector2 = Vector2.ZERO
var movement_input_point : Vector2 = Vector2.ZERO

var is_movement : bool = false

@onready var screen_size : Vector2 = get_viewport().size

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if movement_input_direction.length() >= 0.15:
		velocity.x = movement_input_direction.x * speed
		velocity.z = movement_input_direction.y * speed
		
		var look_target : Vector3 = global_position - velocity.normalized()
		look_target.y = 0
	
		if look_target.length() > 0:
			look_at(look_target, Vector3.UP)
	else:
		velocity.x = 0#move_toward(velocity.x, 0, speed)
		velocity.z = 0#move_toward(velocity.z, 0, speed)
	
	move_and_slide()

var touch_index = 0

func _input(event):
	#if OS.get_name() == "Android" or OS.get_name() == "iOS":
	if event is InputEventScreenTouch:
		if event.is_pressed():
			touch_index = event.index
			print("Touch")
			if event.position.x < screen_size.x/2:
				is_movement = true
				movement_input_point = event.position
		elif event.index == touch_index:
			print("Release")
			movement_input_direction = Vector2.ZERO
			is_movement = false
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			if is_movement:
				movement_input_direction = ((abs(event.relative - event.position) - movement_input_point) * stick_sensivity).normalized()
				print(movement_input_direction)
	#else:
		#if event.index == touch_index:
	#else:
		#Потом тут напишем управление для ПК
	#	pass

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
