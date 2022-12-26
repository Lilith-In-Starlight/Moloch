extends Node2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()

func _ready() -> void:
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 500)
	spell_behavior.connect("hit_something", self, "_on_hit_something", [], 4)
	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [], 4)
	spell_behavior.cast(CastInfo)
	CastInfo.drain_caster_soul(0.01)


func _on_hit_something():
	var goal = (spell_behavior.get_collision_point() - position) + spell_behavior.get_collision_normal()*Vector2(3,10.5)
	
	CastInfo.teleport_caster(goal)
	queue_free()


func _on_hit_nothing():
	CastInfo.teleport_caster(spell_behavior.cast_to)
	queue_free()
