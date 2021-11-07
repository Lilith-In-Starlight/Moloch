extends Area2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var sprinkler := true

var speed := Vector2(0, 0)
var next_shoot_angle := 0.0


func _ready() -> void:
	var Map : TileMap = get_tree().get_nodes_in_group("World")[0]
	if sprinkler:
		$ShootTimer.start()
		CastInfo.set_position(self)
		angle = CastInfo.get_angle(self)
		next_shoot_angle = angle
	speed = Vector2(cos(angle), sin(angle)) * 5
	if sprinkler:
		speed = CastInfo.vector_from_angle(angle, 5)
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _process(delta: float) -> void:
	if sprinkler:
		speed = speed.move_toward(Vector2.ZERO, 0.1 * delta * 60)
	
	for body in get_overlapping_bodies():
		if body.has_method("health_object"):
			body.health_object().temp_change(8, CastInfo.Caster)
		queue_free()
	position += speed * delta * 60


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
