extends Node2D


var CastInfo := SpellCastInfo.new()
var angle := 0.0
var time := 0.0


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)


func _process(delta):
	time += delta
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)
	var i := 0
	if CastInfo.Caster.has_method("health_object"):
		CastInfo.Caster.health_object().temp_change(-0.08)
	for rc in get_children():
		rc.force_raycast_update()
		if randf()<0.3:
			var n := preload("res://Particles/RoundParticles.tscn").instance()
			n.position = position
			n.rotation = angle+(-3+i)*0.2
			match randi() % 3:
				0: n.modulate = "#fe8900"
				1: n.modulate = "#fe1000"
				2: n.modulate = "#feb700"
			get_parent().add_child(n)
		if rc.is_colliding():
			if is_instance_valid(CastInfo.Caster):
				CastInfo.Caster.speed -= rc.cast_to.normalized()*4.5
			if rc.get_collider().has_method("health_object"):
				rc.get_collider().health_object().temp_change(12)
			if rc.get_collider().get("speed"):
				rc.get_collider().speed += rc.cast_to.normalized()*4.5
			if rc.get_collider().get("linear_velocity"):
				rc.get_collider().linear_velocity += rc.cast_to.normalized()*4.5
		rc.cast_to = Vector2(cos(angle+(-3+i)*0.2), sin(angle+(-3+i)*0.2))*200
		i += 1
	if time > 1.5:
		queue_free()

func _draw():
	draw_circle(Vector2(0,0), 2, ColorN("orange"))
