extends Node2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()
var times_done := 0

var timer := 0.0
var casted := false
var did := false

func _ready():
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 2000)
	spell_behavior.connect("hit_something", self, "_on_hit_something", [], 4)
	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [], 4)
	spell_behavior.cast(CastInfo)
	
	var Map :Node2D = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _on_hit_something():
	var pos :Vector2 = spell_behavior.get_collision_point()
	if spell_behavior.get_collider().has_method("health_object") and not did:
		spell_behavior.get_collider().health_object().poke_hole(1, CastInfo.Caster)
		did = true
	$RayCast2D.points = [Vector2(0, 0), pos-position]
	var new_timer := Timer.new()
	new_timer.wait_time = 0.2
	new_timer.autostart = true
	if times_done < 12:
		new_timer.connect("timeout", self, "_on_new_bounce_timeout")
	else:
		new_timer.connect("timeout", self, "_on_death_timeout")
		
	add_child(new_timer)

func _on_hit_nothing():
	var new_timer := Timer.new()
	new_timer.wait_time = 0.2
	new_timer.autostart = true
	new_timer.connect("timeout", self, "_on_death_timeout")
	add_child(new_timer)
	$RayCast2D.points[1] = spell_behavior.cast_to


func _on_new_bounce_timeout():
	var new = load("res://Spells/BouncyRay.tscn").instance()
	new.CastInfo.Caster = spell_behavior
	new.times_done = times_done + 1
	get_parent().add_child(new)
	queue_free()


func _on_death_timeout():
	queue_free()
	
