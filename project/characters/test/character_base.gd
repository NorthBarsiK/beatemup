extends CharacterBody3D

@export var speed : float = 1.0
@export var jump_velocity : float = 4.0

@onready var anim_tree : AnimationTree = get_node("AnimationTree")

var movement_anim : float = 0.0 # -1 - Ходьба, 0 - idle, 1 - бег
var fight_movement_anim : Vector2 = Vector2.ZERO
var fight_jump_anim : float = 0.0

var fight_target : Node = null
var is_in_fight : bool = true

var is_can_moving : bool = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_direction : Vector2 = Vector2.ZERO
	
func _process(delta):
	anim_tree.set("parameters/movement/blend_amount", movement_anim)
	anim_tree.set("parameters/is_fight/blend_amount", is_in_fight)
	anim_tree.set("parameters/fight_movement/blend_position", fight_movement_anim)
	anim_tree.set("parameters/fight_jump/conditions/is_landing", is_on_floor())

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if movement_direction.length() > 0 and is_can_moving:
		velocity.x = movement_direction.x * speed
		velocity.z = movement_direction.y * speed
		
		var look_target : Vector3 = Vector3.ZERO
		
		if is_in_fight:
			if fight_target == null:
				printerr("FIGHT TARGET IS NULL")
			else:
				look_target = fight_target.global_position
			
			var rotation_sin = sin(transform.basis.get_euler().y)
			var rotation_cos = cos(transform.basis.get_euler().y)
		
			fight_movement_anim.x = velocity.x * rotation_cos - velocity.z * rotation_sin
			fight_movement_anim.y = -(velocity.x * rotation_sin + velocity.z * rotation_cos)
			fight_movement_anim = fight_movement_anim.limit_length()
		else:
			look_target = global_position + velocity.normalized()
			
			movement_anim = -1.0
		
		look_target.y = global_position.y
		if look_target.length() > 0:
			look_at(look_target, Vector3.UP, true)
		
	else:
		velocity.x = 0
		velocity.z = 0
		
		if is_in_fight:
			fight_movement_anim = Vector2.ZERO
		else:
			movement_anim = 0.0
	
	move_and_slide()


func move(movement_vector : Vector2):
	movement_direction = movement_vector

func jump():
	if is_on_floor():
		anim_tree.set("parameters/fight_jump_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		velocity.y = jump_velocity

func set_target(new_target : Node3D):
	fight_target = new_target

func stop_moving():
	is_can_moving = false

func continue_moving():
	is_can_moving = true
