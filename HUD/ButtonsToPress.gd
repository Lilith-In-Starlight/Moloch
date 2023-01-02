extends Node2D


export var action := "interact_world"
export var text := "Interact"
export var radius := 26
export var text_height := -41.0

onready var Animations := $Tween


func _ready() -> void:
	$Control.rect_position.y = text_height
	$Control.modulate.a = 0.0
	$Control/Label.text = text
	$Control/KeyLabel.text = Config.get_input_name(Config.keyboard_binds[action])
	if compare_actions(Config.keyboard_binds[action], Config.keyboard_binds["left"]):
		$Control/DownArrow.set_rotation(PI/2.0)
	elif compare_actions(Config.keyboard_binds[action], Config.keyboard_binds["right"]):
		$Control/DownArrow.set_rotation(-PI/2.0)
	elif compare_actions(Config.keyboard_binds[action], Config.keyboard_binds["up"]):
		$Control/DownArrow.set_rotation(PI)
	elif not compare_actions(Config.keyboard_binds[action], Config.keyboard_binds["down"]):
		$Control/DownArrow.visible = false
		$Control/KeyLabel.visible = true
	
	if radius != 26:
		$CollisionShape.shape = CircleShape2D.new()
		$CollisionShape.shape.radius = radius


func compare_actions(action, action2):
	if action[1] != action2[1]:
		return false
	if action[0] != action2[0]:
		return false
	return true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.stop_all()
		Animations.interpolate_property($Control, "modulate", $Control.modulate, Color(1.0,1.0,1.0,1.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		Animations.start()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		Animations.stop_all()
		Animations.interpolate_property($Control, "modulate", $Control.modulate, Color(1.0,1.0,1.0,0.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		Animations.start()
