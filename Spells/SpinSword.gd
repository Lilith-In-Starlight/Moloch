extends Area2D


var CastInfo := SpellCastInfo.new()

var angle_accel := 0.0

var timer := 0.0
var lenght := 24
var fallen := 0.0
var yspeed := 0.0


func _ready():
	position = CastInfo.get_caster_position()
	CastInfo.set_goal()
	rotation = CastInfo.get_angle(self) - PI/4.0
	position = CastInfo.get_caster_position() + Vector2(cos(rotation), sin(rotation))*lenght


func _process(delta):
	angle_accel += delta*20
	rotation += angle_accel*delta*24/lenght
	if angle_accel > 0.1*60:
		angle_accel = 0.1*60
	
	if is_instance_valid(CastInfo.Caster):
		position = CastInfo.get_caster_position() + Vector2(cos(rotation), sin(rotation))*lenght + Vector2(0, fallen)
		CastInfo.push_caster(Vector2(cos(rotation), sin(rotation))*48/lenght)
	else:
		queue_free()
	
	timer += delta
	if timer > 1.0:
		lenght += delta*60*5
		yspeed += delta*2.0
		fallen += yspeed
	
	if lenght > 300:
		queue_free()
	
	for i in get_overlapping_bodies():
		if i.has_method("health_object"):
			if randi()%3 == 1:
				i.health_object().poke_hole(1, CastInfo.Caster)
