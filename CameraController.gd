extends Node


onready var cam :Camera2D = get_tree().get_nodes_in_group("Camera")[0]


func shake_camera(amt: float) -> void:
	cam.shake_camera(amt)
