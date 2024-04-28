extends Node3D

signal send_target(target : Node3D)

var enemies : Array = []
var player : Node3D = null

func _ready():
	for node in get_children():
		if node.is_in_group("enemy"):
			enemies.append(node)

func _physics_process(delta):
	if enemies.size() > 0 and player != null:
		var player_target = get_closest_enemy()
		emit_signal("send_target", player_target)
	
func get_closest_enemy():
		var distances_to_enemies = []
		
		for enemy in enemies:
			var distance = (enemy.global_position - player.global_position).length()
			distances_to_enemies.append(distance)
			
		var closest_enemy_id = distances_to_enemies.find(distances_to_enemies.min())
		
		return enemies[closest_enemy_id]

func _on_body_entered(body : Node):
	if body.is_in_group("player"):
		player = body
		send_target.connect(func(target : Node3D): player.set_fight_target(target))
