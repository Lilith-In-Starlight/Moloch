extends Node2D


var wand_slot := 0
var target_position := Vector2.ZERO
export var properties_path :NodePath
onready var properties: EntityProperties = get_node(properties_path)
onready var wand_renderer := get_node_or_null("WandRender")
var cast_from := global_position
export var lerp_value := 1/3.0


func _process(delta: float) -> void:
	cast_from = global_position
	if wand_renderer != null:
		wand_renderer.render_wand(get_wand(), false)
		wand_renderer.visible = get_wand() != null
		wand_renderer.rotation = lerp_angle(wand_renderer.rotation, (target_position - global_position).angle() + PI/4.0, lerp_value)


func cast_wand():
	if wand_slot < properties.wands.size():
		if properties.wands[wand_slot] != null:
			properties.wands[wand_slot].run(self)


func health_object() -> Flesh:
	return properties.health


func get_cast_from() -> Vector2:
	return global_position


func looking_at() -> Vector2:
	return target_position


func cast_from() -> Vector2:
	return global_position


func get_wand() -> Wand:
	if wand_slot < properties.wands.size():
		return properties.wands[wand_slot]
	return null
