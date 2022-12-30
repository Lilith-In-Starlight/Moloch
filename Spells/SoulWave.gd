extends Area2D


var CastInfo := SpellCastInfo.new()
var spell_behavior := AreaBehavior.new()
var shape := CircleShape2D.new()

var frames := 0


func _ready() -> void:
	var Map :Node2D = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	shape.radius = 2.0
	$CollisionShape2D.shape = shape
	$SoulWave.scale.x = shape.radius / 250.0
	$SoulWave.scale.y = shape.radius / 250.0
	spell_behavior.projectile_side.velocity = spell_behavior.get_initial_velocity(self)
	
	Map.play_sound(preload("res://Sfx/spells/BellSound.wav"), position, 1.0, 0.8+randf()*0.4)


func _physics_process(delta: float) -> void:
	frames += 1
	shape.radius += 1.2 * delta * 60
	$SoulWave.scale.x = shape.radius / 250.0
	$SoulWave.scale.y = shape.radius / 250.0
	modulate.a -= delta / 2.0
	position += spell_behavior.projectile_side.move(0.0, CastInfo) * delta * 60
	for i in get_overlapping_bodies():
		if i.has_method("health_object"):
			var dist :float = i.position.distance_to(position)
			if dist > shape.radius*0.87:
				i.health_object().shatter_soul(5.0/(dist+0.001), CastInfo.Caster)


func _on_Timer_timeout() -> void:
	queue_free()

