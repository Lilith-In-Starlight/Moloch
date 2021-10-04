extends KinematicBody2D


var number := 1
var health := Flesh.new()
var Player :KinematicBody2D


func _ready() -> void:
	Player = get_tree().get_nodes_in_group("Player")[0]
	position = Player.position
	health.max_holes = 3
	health.needs_blood = false
	health.blood = 0.0
	health.soul = 0.4
	health.death_hypertemperature = 60.0
	health.death_hypotemperature = 0.0
	health.connect("died", self, "_on_broken_gluestone")


func _process(delta: float) -> void:
	health.process_health()
	number = get_tree().get_nodes_in_group("Gluestone").find(self)
	if Items.player_items.count("gluestone") >= number and Items.player_items.count("gluestone") > 0:
		var angle :float = Engine.get_frames_drawn()/float(Items.player_items.count("gluestone"))*0.08
		var extra :float = TAU/float(Items.player_items.count("gluestone")) * number
		var goal := Player.position + Vector2(cos(angle+extra), sin(angle+extra)) * 50.0
		position = lerp(position, goal, 0.5)
	else:
		queue_free()


func _on_broken_gluestone():
	queue_free()
	Items.player_items.erase("gluestone")


func health_object():
	return health
