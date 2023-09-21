extends Node


export var properties_path: NodePath
onready var properties :Node = get_node_or_null(properties_path)

export var controller_path: NodePath
onready var controller :EntityController = get_node_or_null(controller_path)


func _process(delta: float) -> void:
	if properties.get_wands().empty():
		return
	
	if properties.is_cast_blocked():
		return
	
	if properties.get_wand() is Wand and controller.pressed_inputs.action1:
		properties.get_wand().shuffle()
		properties.get_wand().run(get_parent())
