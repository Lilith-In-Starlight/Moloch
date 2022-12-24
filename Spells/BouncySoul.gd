extends Area2D

onready var Ray := $GoingTo

var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

var rotate := 0.0
var flip := false
var dtimer := 0.0
var Map :TileMap


func _ready():
	Map = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.get_angle(self)
	spell_behavior.velocity = Vector2(cos(rotate), sin(rotate)) * CastInfo.projectile_speed
	Ray.cast_to = spell_behavior.velocity
	Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)


func _physics_process(delta):
	Ray.cast_to = spell_behavior.velocity * delta * 60
	if not Ray.is_colliding():
		position += spell_behavior.move(0, CastInfo.modifiers) * delta * 60
		flip = false
	elif not flip:
		if Ray.get_collider().has_method("health_object"):
			Ray.get_collider().health_object().shatter_soul(0.1, CastInfo.Caster)
		position = lerp(position, Ray.get_collision_point(), 0.99)
		if Ray.get_collision_normal() == Vector2(0, 0):
			queue_free()
		else:
			spell_behavior.velocity = spell_behavior.velocity.bounce(Ray.get_collision_normal().normalized())*1.02
			Map.play_sound(preload("res://Sfx/spells/laserfire01.wav"), position, 1.0, 0.8+randf()*0.4)
		position += spell_behavior.move(0, CastInfo.modifiers) * delta * 60
		flip = true
		dtimer += 0.05
		update()
	else:
		dtimer += 0.1
		update()
	
	if dtimer > 0.5:
		queue_free()

func _draw():
	draw_circle(Vector2(0, 0), (0.5-dtimer)*2*5, "#87ff69")
		
		
