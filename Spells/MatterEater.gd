extends Sprite

const AREA := 4

var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()
var Map :TileMap

func _ready() -> void:
	spell_behavior.velocity = Vector2(0, 0)
	if randf() > 0.5:
		scale.x = -1
	if randf() > 0.5:
		scale.y = -1
	Map = get_tree().get_nodes_in_group("World")[0]
	CastInfo.set_position(self)

	var point := Vector2(int(position.x/8), int(position.y/8))
	Map.update_bitmask_region(point-Vector2(AREA,AREA), point+Vector2(AREA,AREA))
	$Tween.interpolate_property(self, "modulate", Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0.0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.08)
	$Tween.start()
	CastInfo.heat_caster(2.0)


func _process(delta: float) -> void:
	position += spell_behavior.move(0.0, CastInfo)
	for x in range(-AREA,AREA+1):
		for y in range(-AREA,AREA+1):
			var vec := Vector2(x+int(position.x/8), y+int(position.y/8))
			if Vector2(x,y).length()<=AREA:
				Map.set_cellv(vec, Items.break_block(Map.get_cellv(vec), 0.5))
				CastInfo.heat_caster((0.01 * delta * 60) / (0.08 + 0.3))


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	queue_free()
