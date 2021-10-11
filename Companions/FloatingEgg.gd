extends KinematicBody2D


var number := 1
var health := Flesh.new()
var Player :KinematicBody2D
var old_player_position := []


func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	old_player_position = [Player.position]
	position = Player.position
	health.max_holes = 1
	health.blood = 0.3
	health.death_hypertemperature = 60.0
	health.death_hypotemperature = 10.0
	health.connect("died", self, "_on_broken_egg")
	$Timer.wait_time = 120.0 + randf() * 180.0
	$Timer.start()


func _process(delta: float) -> void:
	health.process_health(delta)
	number = get_tree().get_nodes_in_group("Egg").find(self)
	if Items.player_items.count("egg") >= number and Items.player_items.count("egg") > 0:
		if Player.position.distance_to(old_player_position[0]) > 16:
			 old_player_position.push_front(Player.position)
		while old_player_position.size() > number + 1:
			old_player_position.pop_back()
		var goal = old_player_position[old_player_position.size() - 1]
		position = lerp(position, goal, 0.1)
	else:
		queue_free()


func _on_broken_egg() -> void:
	queue_free()
	Items.player_items.erase("egg")


func health_object() -> Flesh:
	return health


func _on_hatch() -> void:
	Items.player_items.erase("egg")
	if randf()<0.4 and Items.companions.size() <= 6:
		Items.companions.append([Flesh.new(), null])
	queue_free()
