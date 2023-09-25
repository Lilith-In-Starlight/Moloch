extends Node2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := RayBehavior.new()
var timer := 0.0
var did := false

func _ready():
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 1000)
	spell_behavior.connect("hit_something", self, "_on_hit_something", [], 4)
	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing", [], 4)
	var Map :Node2D = get_tree().get_nodes_in_group("World")[0]
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)

func _physics_process(delta):
	timer += delta
	CastInfo.set_position(self)
	spell_behavior.cast(CastInfo)
	
	if timer > 0.05:
		queue_free()


func _on_hit_something():
	var col = spell_behavior.get_collider()
	if col.has_method("health_object") and not did and col.health_object().soul_module.amount > 0.0:
		did = true
		if is_instance_valid(CastInfo.Caster):
			var shatter := min(col.health_object().soul_module.amount, 0.025)
			CastInfo.Caster.health_object().shatter_soul(-shatter)
			col.health_object().shatter_soul(shatter, CastInfo.Caster)
	elif not did:
		CastInfo.drain_caster_soul(0.05)
		did = true
	$Line2D.points = [Vector2(0, 0), spell_behavior.get_collision_point() - position]


func _on_hit_nothing():
	$Line2D.points = [Vector2(0, 0), spell_behavior.cast_to]
