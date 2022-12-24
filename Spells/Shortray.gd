extends Node2D


onready var Ray := $Ray1
onready var Line := $Line2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()


func _ready() -> void:
	var Map :TileMap = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	spell_behavior.get_angle(CastInfo.goal + CastInfo.goal_offset, position, CastInfo)
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)
	 
	var point := CastInfo.vector_from_angle(spell_behavior.angle, 100)
	Ray.cast_to = point
	CastInfo.set_position(self)
	Ray.force_raycast_update()
	if Ray.is_colliding():
		point = Ray.get_collision_point() - position
		var collider :Node2D = Ray.get_collider()
		if collider.has_method("health_object"):
			collider.health_object().shatter_soul(0.2)
			if randf() < 0.25:
				collider.health_object().poke_hole()
	Line.points = [Vector2(0, 0), point]


func _on_Timer_timeout() -> void:
	queue_free()
