extends CharacterBody3D

@export var fight_movement_speed : float = 1.0
@export var walk_speed : float = 1.7
@export var run_speed : float = 4.0
@export var jump_velocity : float = 4.0

@onready var anim_tree : AnimationTree = get_node("AnimationTree")

var look_target : Vector3 = Vector3.ZERO
var is_can_moving : bool = true
var stick_offset : Vector2 = Vector2.ZERO
var movement_type : float = 0.0
var movement_types = {
	walk = -1.0,
	idle = 0.0,
	run = 1.0
}
var run_stick_offset_length : float = 0.7

var is_in_fight : bool = true
var fight_movement_anim : Vector2 = Vector2.ZERO
var fight_jump_anim : float = 0.0
var fight_target : Node = null

var is_in_strike : bool = false
var is_can_continue_combo : bool = false
var is_continue_combo : bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _process(delta):
	anim_tree.set("parameters/movement/blend_amount", movement_type)
	anim_tree.set("parameters/is_fight/blend_amount", is_in_fight)
	anim_tree.set("parameters/fight_movement/blend_position", fight_movement_anim)
	anim_tree.set("parameters/fight_jump/conditions/is_landing", is_on_floor())

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	look_rotation()
	movement()
	
	move_and_slide()

func look_rotation():
	if is_in_fight:
		if fight_target == null:
			printerr("FIGHT TARGET IS NULL")
		else:
			var new_fight_movement_vector : Vector2
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

func movement():
	var speed : float = 0.0
	
	if is_can_moving:
		if is_in_fight:
			if stick_offset.length() > 0.0:
				stick_offset = stick_offset.normalized()
				speed = fight_movement_speed
			else:
				fight_movement_anim = Vector2.ZERO
		else:
			if stick_offset.length() > 0.0 and stick_offset.length() < run_stick_offset_length:
				speed = walk_speed
				movement_type = movement_types.walk
			elif stick_offset.length() >= run_stick_offset_length:
				speed = run_speed
				movement_type = movement_types.run
			else:
				movement_type = movement_types.idle
		
	velocity.x = stick_offset.normalized().x * speed
	velocity.z = stick_offset.normalized().y * speed

func set_stick_offset(offset : Vector2):
	stick_offset = offset

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

func set_fight_target(new_target : Node3D):
	fight_target = new_target

func stop_moving():
	is_can_moving = false

func continue_moving():
	is_can_moving = true
