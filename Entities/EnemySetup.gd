extends Node


onready var player :Character = get_tree().get_nodes_in_group("Player")[0]


func _process(delta: float) -> void:
	if player.position.distance_to(get_parent().position) < 500:
		if get_node_or_null("../EntityProperties") != null and $"../EntityProperties".has_method("get_wand"):
			$"../EntityProperties".get_wand().queue_free()
		get_parent().queue_free()
	var tcol :KinematicCollision2D = get_parent().move_and_collide(Vector2(0, 0), true, true, true)
	if tcol != null:
		if tcol.collider != self:
			get_parent().queue_free()
	set_process(false)


func _on_screen_entered():
	for i in get_parent().get_children():
		if i is RayCast2D:
			i.enabled = true

func _on_screen_exited():
	for i in get_parent().get_children():
		if i is RayCast2D:
			i.enabled = false


func _on_entity_died() -> void:
	get_parent().queue_free()
