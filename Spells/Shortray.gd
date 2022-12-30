extends Node2D


onready var Line := $Line2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()


func _ready() -> void:
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 124)
	spell_behavior.connect("hit_something", self, "_on_hit_something", [], 4)
	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [], 4)
	var Map :Node2D = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)
	 
	CastInfo.set_position(self)
	spell_behavior.cast(CastInfo)


func _on_hit_something():
	var point = spell_behavior.get_collision_point() - position
	var collider :Node2D = spell_behavior.get_collider()
	if collider.has_method("health_object"):
		collider.health_object().shatter_soul(0.2)
		if randf() < 0.25:
			collider.health_object().poke_hole()
	Line.points = [Vector2(0, 0), point]


func _on_hit_nothing():
	Line.points = [Vector2(0, 0), spell_behavior.cast_to]


func _on_Timer_timeout() -> void:
	queue_free()
