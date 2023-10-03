extends VBoxContainer



func _on_generated_world() -> void:
	var animate := false
	if Items.level == 1:
		$Title.text = "Sacrificial Floor"
		$Description.visible = false
		animate = true
	elif Items.level == 3:
		$Title.text = "The Forgotten Citadel"
		$Description.visible = false
	elif Items.level == 5:
		$Title.text = "The Tower Proper"
		$Description.visible = false
	
	if animate:
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 1.0)
		tween.tween_interval(2.0)
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		

func boss_fight(bname: String) -> void:
	if bname == "Malekarai Malekha":
		$Title.text = "Malekarai Malekha"
		$Description.text = "The Forgotten King"
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
