extends EntityController

class_name InputController


func _input(event: InputEvent) -> void:
	pressed_inputs.up = Input.is_action_pressed("up")
	pressed_inputs.down = Input.is_action_pressed("down")
	pressed_inputs.left = Input.is_action_pressed("left")
	pressed_inputs.right = Input.is_action_pressed("right")
	pressed_inputs.move_action = Input.is_action_pressed("jump")
	pressed_inputs.action1 = Input.is_action_pressed("Interact1")
	pressed_inputs.action3 = Input.is_action_pressed("seal_blood")
	pressed_inputs.death_action = Input.is_action_pressed("instant_death")


func _process(delta: float) -> void:
	just_pressed_inputs.up = Input.is_action_just_pressed("up")
	just_pressed_inputs.down = Input.is_action_just_pressed("down")
	just_pressed_inputs.left = Input.is_action_just_pressed("left")
	just_pressed_inputs.right = Input.is_action_just_pressed("right")
	just_pressed_inputs.move_action = Input.is_action_just_pressed("jump")
	just_pressed_inputs.action1 = Input.is_action_just_pressed("Interact1")
	just_pressed_inputs.action3 = Input.is_action_just_pressed("seal_blood")
	just_pressed_inputs.death_action = Input.is_action_just_pressed("instant_death")


func get_movement_axis() -> Vector2:
	return Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3)) * 50.0


func get_eye_direction() -> Vector2:
	return get_parent().get_local_mouse_position().normalized()


func get_eye_specific_direction() -> Vector2:
	return get_parent().get_local_mouse_position()
