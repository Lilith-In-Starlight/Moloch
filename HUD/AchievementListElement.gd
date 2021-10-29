extends HBoxContainer


export var achievement := ""

func _ready() -> void:
	$TextureRect.texture = Config.ach_info[achievement]["texture"]
	$VBoxContainer/Label.text = Config.ach_info[achievement]["text"]
	$VBoxContainer/Label2.text = Config.ach_info[achievement]["desc"]
	visible = Config.achievements[achievement]
