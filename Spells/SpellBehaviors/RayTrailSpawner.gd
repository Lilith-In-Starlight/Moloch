extends Node

const PARTICLES := preload("res://Particles/MagicDustLine.tscn")

export var color := Color()
export var line_width := 1.0

func _on_request_movement(delta: Vector2):
	var t := get_tree().create_timer(0.5)
	var new_p :Particles2D = PARTICLES.instance()
	new_p.modulate = color
	new_p.lifetime = 0.5
	new_p.position = get_parent().position - delta * 0.5
	new_p.amount = max(1, delta.length() * 0.5)
	new_p.process_material = new_p.process_material.duplicate(true)
	var mat :ParticlesMaterial = new_p.process_material
	mat.emission_box_extents = Vector3(delta.length() * 0.5, line_width, 1)
	new_p.rotation = (-delta).angle()
	mat.angle = rad2deg((-delta).angle())
	new_p.emitting = true
	get_parent().get_parent().add_child(new_p)
	t.connect("timeout",new_p, "queue_free")
#	points = [-delta, Vector2.ZERO]


# 1 / x = spacing / total
# x = total / spacing
