extends CanvasLayer


var messages := []
var message_timer := 0.0

func _process(delta):
	if not messages.empty():
		$HUD/Messages.visible = true
		message_timer += delta
		$HUD/Messages.bbcode_text = "[center]" + messages[0] + "[/center]"
		if message_timer > messages[0].length()*0.4:
			message_timer = 0.0
			messages.pop_front()
	else:
		$HUD/Messages.visible = false
	
	for i in $HUD/Wands.get_child_count():
		if Items.player_wands[i] != null:
			$HUD/Wands.get_child(i).modulate = "#ffc741"
			if Items.selected_wand == i:
				$HUD/Wands.get_child(i).modulate = "#ffbdeb"
		else:
			$HUD/Wands.get_child(i).modulate = "2a2a2a"
			if Items.selected_wand == i:
				$HUD/Wands.get_child(i).modulate = "#795887"
	
	for i in $HUD/Spells.get_child_count():
		if Items.player_wands[Items.selected_wand] != null:
			$HUD/Spells.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			if i < wand.spell_capacity:
				$HUD/Spells.get_child(i).visible = true
				if i < wand.spells.size():
					match wand.spells[i]:
						"fuck you":
							$HUD/Spells.get_child(i).modulate = "#ffe2ff"
						"evilsight":
							$HUD/Spells.get_child(i).modulate = "#45ff80"
						"shatter":
							$HUD/Spells.get_child(i).modulate = "#0faa68"
						"ray":
							$HUD/Spells.get_child(i).modulate = "#00f3ff"
				else:
					$HUD/Spells.get_child(i).modulate = "2a2a2a"
			else:
				$HUD/Spells.get_child(i).visible = false
		else:
			$HUD/Spells.visible = false

func add_message(message:String):
	messages.append(message)
