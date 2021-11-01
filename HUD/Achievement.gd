extends Panel


func _ready() -> void:
	Config.connect("achievement_unlocked", self, "_on_achievement_unlocked")


func _on_achievement_unlocked(achievement:String) -> void:
	$Name.text = Config.ach_info[achievement]["text"]
	$Image.texture = Config.ach_info[achievement]["texture"]
	$AnimationPlayer.play("Move", 1.0)
	$Timer.start()


func _on_Timer_timeout() -> void:
	$AnimationPlayer.play_backwards("Move", 1.0)
