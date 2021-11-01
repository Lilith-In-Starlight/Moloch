extends Control


const characters := "abcdefghijklmnopqrstuvwxyz!#$%&/()=123456789"

export var achievement := ""

func _ready() -> void:
	var won :bool = Config.achievements[achievement]
	$Icon.texture = Config.ach_info[achievement]["texture"]
	$Name.text = Config.ach_info[achievement]["text"]
	$Description.text = Config.ach_info[achievement]["desc"]
	if not won:
		scramble_label($Name)
		scramble_label($Description)
	
	var texmat :ShaderMaterial = $Icon.get_material().duplicate(true)
	texmat.set_shader_param("achieved", won)
	$Icon.material = texmat

func scramble_label(Child:Label):
	for letter in Child.text.length():
		var new_character :String = characters[randi() % characters.length()]
		if randf() < 0.5:
			new_character.to_upper()
		if Child.text[letter] != " " and randf()>0.6:
			Child.text[letter] = new_character
