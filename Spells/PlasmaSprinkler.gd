extends Area2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var sprinkler := true

var speed_multiplier := 1.0
var next_shoot_angle := 0.0
var spell_behavior := ProjectileBehavior.new()


func _ready() -> void:
	var Map : TileMap = get_tree().get_nodes_in_group("World")[0]
	if sprinkler:
		$ShootTimer.start()
		CastInfo.set_position(self)
		angle = CastInfo.get_angle(self)
		next_shoot_angle = angle
		
	spell_behavior.velocity = Vector2(cos(angle), sin(angle)) * 3
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _process(delta: float) -> void:
	if sprinkler:
		speed_multiplier = move_toward(speed_multiplier, 0, 0.03 * delta * 60)
	spell_behavior.velocity *= speed_multiplier
	
	for body in get_overlapping_bodies():
		if body.has_method("health_object"):
			body.health_object().temp_change(8, CastInfo.Caster)
		queue_free()
	position += spell_behavior.move(0, CastInfo)


func _on_ShootTimer_timeout() -> void:
	$ShootTimer.wait_time = 0.1
	var new_cast :Area2D = load("res://Spells/PlasmaSprinkler.tscn").instance()
	new_cast.sprinkler = false
	new_cast.position = position
	new_cast.angle = next_shoot_angle
	new_cast.CastInfo = CastInfo
	next_shoot_angle += TAU / 12.0
	get_parent().add_child(new_cast)


func _on_DespawnTimer_timeout() -> void:
	queue_free()
