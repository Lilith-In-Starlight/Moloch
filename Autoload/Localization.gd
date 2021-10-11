extends Node

var languages := {}
var current_language := "es"

func _ready() -> void:
	var languages_directory := Directory.new()
	var err := languages_directory.open("res://Lang")
	if err == OK:
		languages_directory.list_dir_begin(true)
		var language_folder := languages_directory.get_next()
		while language_folder != "":
			if languages_directory.dir_exists("res://Lang/"+language_folder): # Makes sure it's opening a folder, not a file
				var language_directory := Directory.new()
				language_directory.open("res://Lang/"+language_folder)
				if language_directory.file_exists("lang.txt"):
					var language := {}
					var lang_file := File.new()
					lang_file.open("res://Lang/"+language_folder+"/lang.txt", File.READ)
					var line := lang_file.get_line()
					while line != "":
						var data := line.split("=", true, 1)
						language[data[0]] = data[1]
						line = lang_file.get_line()
					lang_file.close()
					languages[language_folder] = language
			language_folder = languages_directory.get_next()
	print(get_line("play-button"))


func get_line(line_name:String) -> String:
	if not current_language in languages:
		current_language = "en"
	if line_name in languages[current_language]:
		return languages[current_language][line_name]
	elif line_name in languages["en"]:
		return languages["en"][line_name]
	return line_name
