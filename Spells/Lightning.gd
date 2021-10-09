extends RayCast2D


var CastInfo := SpellCastInfo.new()
var angle :float

var attack_area := Area2D.new()

func _ready() -> void:
	CastInfo.set_position(self)
	CastInfo.set_goal()
	angle = CastInfo.get_angle(self)
	var active_ray :RayCast2D = self
	var found_earth := false
	active_ray.cast_to = Vector2(cos(angle), sin(angle)) * randf() * 64.0
	var tries := 0
	var p := [Vector2(0, 0)]
	while not found_earth and tries < 24: 
		active_ray.force_raycast_update()
		if active_ray.is_colliding():
			found_earth = true
			p.append(active_ray.get_collision_point()-position)
		else:
			var new_ray := RayCast2D.new()
			new_ray.position = active_ray.cast_to + active_ray.position
			if active_ray == self:
				new_ray.position = active_ray.cast_to
			p.append(new_ray.position)
			new_ray.cast_to = active_ray.cast_to.rotated(-PI/4.0 + randf()*PI/2.0).normalized() * randf() * 64.0
			var thing := get_tree().get_nodes_in_group("Player") + get_tree().get_nodes_in_group("Enemy")
			if tries == 0 and is_instance_valid(CastInfo.Caster):
				if CastInfo.Caster in thing:
					thing.erase(CastInfo.Caster)
			add_child(new_ray)
			for bit in 8:
				new_ray.set_collision_mask_bit(bit, get_collision_mask_bit(bit))
			active_ray = new_ray
		tries += 1
	$Line.points = p
	var collision_shape := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 32
	collision_shape.shape = shape
	attack_area.add_child(collision_shape)
	add_child(attack_area)
	attack_area.position = p[p.size()-1]
	for bit in 8:
		attack_area.set_collision_mask_bit(bit, get_collision_mask_bit(bit))
	$Timer.start()




func _on_Timer_timeout() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("health_object"):
			body.health_object().temp_change(1000)
	queue_free()
