extends Node2D


var thing := []
var CastInfo := SpellCastInfo.new()
var Map :TileMap


func _ready() -> void:
	Map = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)
	var next_distance := 500
	for i in get_children():
		var angle := randf()*TAU
		i.position = Vector2(cos(angle), sin(angle))*next_distance
		thing.append([0, i.position.angle()])
		next_distance += 300 + randf()*400


func _process(delta: float) -> void:
	var queue := []
	for i in get_child_count():
		var child := get_child(i)
		var dis :float = child.position.length()
		thing[i][0] += 0.5*delta*60
		var new_pos :Vector2 = child.position.normalized()*(dis-thing[i][0])
		if child.position.angle() - new_pos.angle() < 0.0001:
			child.position = new_pos
		else:
			queue.append([child, i])
			Map.summon_explosion(position, 20)
	for i in queue:
		i[0].queue_free()
		thing.remove(i[1])
