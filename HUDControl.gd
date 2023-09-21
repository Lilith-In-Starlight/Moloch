extends Node


onready var controller := $"../InputController"

func _process(delta: float) -> void:
	if not Config.last_input_was_controller and not Items.player_wands.empty():
		if Input.is_action_just_released("scrollup"):
			Items.selected_wand -= 1
			if Items.selected_wand < 0:
				Items.selected_wand = Items.player_wands.size()-1

		elif Input.is_action_just_released("scrolldown"):
			Items.selected_wand = (Items.selected_wand + 1) % Items.player_wands.size()
	
	if Input.is_action_just_pressed("hotbar1"):
		Items.selected_wand = 0
	elif Input.is_action_just_pressed("hotbar2"):
		Items.selected_wand = 1
	elif Input.is_action_just_pressed("hotbar3"):
		Items.selected_wand = 2
	elif Input.is_action_just_pressed("hotbar4"):
		Items.selected_wand = 3
	elif Input.is_action_just_pressed("hotbar5"):
		Items.selected_wand = 4
	elif Input.is_action_just_pressed("hotbar6"):
		Items.selected_wand = 5
