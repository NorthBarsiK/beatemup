extends CharacterBody3D

@export var fight_movement_speed : float = 1.0
@export var walk_speed : float = 1.7
@export var run_speed : float = 4.0
@export var jump_velocity : float = 4.0

@onready var anim_tree : AnimationTree = get_node("AnimationTree")

var movement_anim : float = 0.0 # -1 - Ходьба, 0 - idle, 1 - бег
var fight_movement_anim : Vector2 = Vector2.ZERO
var fight_jump_anim : float = 0.0

var fight_target : Node = null
var is_in_fight : bool = true
var is_continue_combo : bool = false
var is_can_continue_combo : bool = false
var is_in_strike : bool = false

var is_can_moving : bool = true
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_direction : Vector2 = Vector2.ZERO

var look_target : Vector3 = Vector3.ZERO

func _process(delta):
	anim_tree.set("parameters/movement/blend_amount", movement_anim)
	anim_tree.set("parameters/is_fight/blend_amount", is_in_fight)
	anim_tree.set("parameters/fight_movement/blend_position", fight_movement_anim)
	anim_tree.set("parameters/fight_jump/conditions/is_landing", is_on_floor())

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var new_fight_movement_vector : Vector2
	
	if is_in_fight:
		if fight_target == null:
			printerr("FIGHT TARGET IS NULL")
		else:
			look_target = lerp(look_target, fight_target.global_position, 0.05)
		
		var rotation_sin = sin(transform.basis.get_euler().y)
		var rotation_cos = cos(transform.basis.get_euler().y)
	
		new_fight_movement_vector.x = velocity.x * rotation_cos - velocity.z * rotation_sin
		new_fight_movement_vector.y = -(velocity.x * rotation_sin + velocity.z * rotation_cos)
		new_fight_movement_vector = new_fight_movement_vector.limit_length()
		
		fight_movement_anim = lerp(fight_movement_anim, new_fight_movement_vector, 0.05)
	else:
		look_target = lerp(look_target, global_position + velocity, 0.15)
	
	
	look_target.y = global_position.y
	if (look_target - global_position).length() > 0:
		look_at(look_target, Vector3.UP, true)
	
	if is_can_moving:
		if is_in_fight:
			if movement_direction.length() > 0.0:
				movement_direction = movement_direction.normalized()
				velocity.x = movement_direction.x * fight_movement_speed
				velocity.z = movement_direction.y * fight_movement_speed
			else:
				velocity.x = 0
				velocity.z = 0
				
				if is_in_fight:
					fight_movement_anim = Vector2.ZERO
				else:
					movement_anim = lerp(movement_anim, 0.0, 0.1)
		else:
			print(movement_direction.length())
			if movement_direction.length() > 0.0 and movement_direction.length() < 0.7:
				#movement_direction = movement_direction.normalized()
				velocity.x = movement_direction.normalized().x * walk_speed
				velocity.z = movement_direction.normalized().y * walk_speed
				movement_anim = -1.0#lerp(movement_anim, 0.0, 0.1)
			elif movement_direction.length() >= 0.7:
				#movement_direction = movement_direction.normalized()
				velocity.x = movement_direction.normalized().x * run_speed
				velocity.z = movement_direction.normalized().y * run_speed
				movement_anim = 1.0#lerp(movement_anim, 0.0, 0.1)
			else:
				velocity.x = 0
				velocity.z = 0
				
				if is_in_fight:
					fight_movement_anim = Vector2.ZERO
				else:
					movement_anim = 0.0#lerp(movement_anim, 0.0, 0.1)
	else:
		velocity.x = 0
		velocity.z = 0
		
		if is_in_fight:
			fight_movement_anim = Vector2.ZERO
		else:
			movement_anim = lerp(movement_anim, 0.0, 0.1)
	
	move_and_slide()


func move(movement_vector : Vector2):
	movement_direction = movement_vector

func jump():
	if is_on_floor():
		anim_tree.set("parameters/fight_jump_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		velocity.y = jump_velocity

func kick():
	if is_on_floor():
		if not is_in_strike:
			anim_tree.set("parameters/strike_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			is_in_strike = true
		elif is_can_continue_combo:
			continue_combo()

func punch():
	pass

func continue_combo():
	if is_can_continue_combo:
		anim_tree.set("parameters/strikes/conditions/is_continue_combo", true)
		is_continue_combo = true

func allow_continuation_combo():
	is_continue_combo = false
	is_can_continue_combo = true

func deny_continuation_combo():
	if not is_continue_combo:
		combo_end()
	
	is_can_continue_combo = false
	
func combo_end():
	anim_tree.set("parameters/strikes/conditions/is_continue_combo", false)
	is_in_strike = false

func set_target(new_target : Node3D):
	fight_target = new_target

func stop_moving():
	is_can_moving = false

func continue_moving():
	is_can_moving = true
