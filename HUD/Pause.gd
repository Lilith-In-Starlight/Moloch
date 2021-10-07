extends Panel


onready var Console := $"../Console"


func _ready() -> void:
	$Options/DieInstantly.connect("pressed", Items.player_health, "_instakill_pressed")


func _on_DieInstantly_pressed() -> void:
	get_tree().paused = false


func _on_Settings_pressed() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if not Console.has_focus() and event.is_pressed():
		if event is InputEventKey:
			match event.scancode:
				KEY_ESCAPE:
					get_tree().paused = !get_tree().paused
					visible = get_tree().paused
