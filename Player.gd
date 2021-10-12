extends Character


func _ready() -> void:
	self.health = Items.player_health
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	self.inputs = {
		"left":Input.is_action_pressed("left"),
		"right":Input.is_action_pressed("right"),
		"up":Input.is_action_pressed("up"),
		"down":Input.is_action_pressed("down"),
		"jump":Input.is_action_pressed("jump"),
	}
	process_movement(delta)


func _on_generated_world() -> void:
	set_physics_process(true)
