extends VBoxContainer

var finished_gen := false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and finished_gen and Config.config_file.get_value("debug", "console", false):
		match event.scancode:
			KEY_F12:
				$Input.grab_focus()
				visible = true
			KEY_ENTER:
				var input :String = $Input.text
				output("> " + input)
				$Input.text = ""
				var cmd := input.split(" ")
				
				if cmd.size() != 0:
					match cmd[0]:
						"giveitem":
							match cmd.size():
								1:
									output("[color=red]Expected structure:[/color] giveitem <itemname> <amount = 1>")
								2:
									if cmd[1] in Items.all_items:
										Items.add_item(cmd[1])
										output("Given 1 unit of " + Items.all_items[cmd[1]].name)
										Items.last_pickup = Items.all_items[cmd[1]]
									else:
										output("[color=red]Name doesn't match any registered item[/color]")
								3:
									if cmd[1] in Items.all_items:
										if cmd[2].is_valid_integer():
											for i in cmd[2] as int:
												Items.add_item(cmd[1])
											output("Given " + cmd[2] + " units of " + Items.all_items[cmd[1]].name)
											Items.last_pickup = Items.all_items[cmd[1]]
										else:
											output("[color=red]<amount> expected an integer[/color]")
									else:
										output("[color=red]Name doesn't match any registered item[/color]")
						"tkitem":
							match cmd.size():
								1:
									output("[color=red]Expected structure:[/color] tkitem <itemname> <amount = 1>")
								2:
									if Items.count_player_items(cmd[1]) > 0:
										Items.player_items[cmd[1]] -= 1
										output("Taken 1 unit of " + Items.all_items[cmd[1]].name)
									else:
										output("[color=red]Name doesn't match any item in the inventory[/color]")
								3:
									if Items.count_player_items(cmd[1]) > 0:
										if cmd[2].is_valid_integer():
											var rm := 0
											for i in cmd[2] as int:
												rm += 1
												Items.player_items[cmd[1]] -= 1
												if Items.count_player_items(cmd[1]) <= 0:
													break
											output("Taken " + str(rm) + " units of " + Items.all_items[cmd[1]].name)
											Items.last_pickup = Items.all_items[cmd[1]]
										else:
											output("[color=red]<amount> expected an integer[/color]")
									else:
										output("[color=red]Name doesn't match any registered item[/color]")
						"givespell":
							match cmd.size():
								1:
									output("[color=red]Expected structure:[/color] givespell <spellname> <amount = 1>")
								2:
									if cmd[1] in Items.all_spells:
										if Items.player_spells.size() < 6:
											Items.player_spells.append(Items.all_spells[cmd[1]])
											output("Given 1 unit of " + Items.all_spells[cmd[1]].name)
										else:
											output("[color=red]Not enough space[/color]")
									else:
										output("[color=red]Name doesn't match any registered spell[/color]")
								3:
									if cmd[1] in Items.all_spells:
										if cmd[2].is_valid_integer():
											var gv := 0
											for i in cmd[2] as int:
												if Items.player_spells.size() < 6:
													gv += 1
													Items.player_spells.append(Items.all_spells[cmd[1]])
												else:
													output("[color=red]Not enough space[/color]")
													break
											output("Given " + str(gv) + " units of " + Items.all_spells[cmd[1]].name)
										else:
											output("[color=red]<amount> expected an integer[/color]")
									else:
										output("[color=red]Name doesn't match any registered spell[/color]")
						"givewand":
							match cmd.size():
								1:
									output("[color=red]Expected structure:[/color] givewand {data}")
								2:
									var parse_result := JSON.parse(cmd[1])
									if parse_result.error != OK:
										print(parse_result.error_string)
									else:
										if Items.player_wands.find(null) != -1:
											var new_wand := Wand.new()
											Items.add_child(new_wand)
											Items.append_player_wand(new_wand)
											var tags :Dictionary = parse_result.result
											new_wand.set_from_dict(tags)
										else:
											output("[color=red]No inventory space[/color]")
						"wandjson": 
							if Items.get_player_wand() != null:
								OS.set_clipboard(Items.get_player_wand().get_json())
						"givemod":
							if cmd.size() == 3:
								if Items.base_spell_mods.has(cmd[1]):
									if cmd[2].is_valid_integer():
										if  Items.player_spells.size() < 6:
											var base :Spell = Items.base_spell_mods[cmd[1]]
											var new_spell :Spell = base.duplicate()
											if "%s" in new_spell.description:
												new_spell.description = base.description % cmd[2]
											new_spell.level = clamp(cmd[2] as int,2,6)
											Items.player_spells.append(new_spell)
											Items.spell_mods.append(new_spell)
										else:
											output("[color=red]No inventory space[/color]")
									else:
										output("[color=red]Level is not a valid integer[/color]")
								else:
									output("[color=red]Modifier not found[/color]")
							else:
								output("[color=red]givemod <modname> <level>[/color]")
											
									
			KEY_F1, KEY_ESCAPE:
				$Input.release_focus()
				visible = false


func output(text:String) -> void:
	$Output.bbcode_text += text + "\n"


func _on_Input_focus_entered() -> void:
	get_tree().paused = true


func _on_Input_focus_exited() -> void:
	get_tree().paused = false


func _on_World_generated_world() -> void:
	finished_gen = true
