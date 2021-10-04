extends Node2D

var number := 1
var health := Flesh.new()
var Player :KinematicBody2D
var old_player_position := []
var look_at :Vector2
var wand := Wand.new()


func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	old_player_position = [Player.position]
	position = Player.position
	health.max_holes = 3
	health.needs_blood = false
	health.death_hypertemperature = 120.0
	health.death_hypotemperature = -20.0
	health.connect("died", self, "_on_dead")

func _physics_process(delta: float) -> void:
	health.process_health()
	var joined_group := get_tree().get_nodes_in_group("egg")+get_tree().get_nodes_in_group("Companion")
	number = joined_group.find(self)
	if Items.companions.size() >= number and Items.companions.size() > 0 :
		if Player.position.distance_to(old_player_position[0]) > 16:
			 old_player_position.push_front(Player.position)
		while old_player_position.size() > number + 1:
			old_player_position.pop_back()
		var goal = old_player_position[old_player_position.size() - 1]
		position = lerp(position, goal, 0.1)
		var found_any := false
		for i in get_tree().get_nodes_in_group("Enemy"):
			if Player.position.distance_to(i.position) < 150:
				look_at = i.position
				found_any = true
		if found_any:
			wand.run(self)
	else:
		queue_free()


func _on_dead() -> void:
	Items.companions.erase(self)
	queue_free()


func health_object() -> Flesh:
	return health


func looking_at() -> Vector2:
	return look_at


func cast_from() -> Vector2:
	return (look_at-position).normalized()*(64+16*number) + position
