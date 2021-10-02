extends CanvasLayer

onready var UsefulAdvice := $HUD/Generating/UsefulAdvice
onready var LastItem := $HUD/LastItem
onready var HotHUD := $HUD/Hot
onready var ColdHUD := $HUD/Cold
onready var DeathScreen := $HUD/Death
onready var GeneratingScreen := $HUD/Generating
onready var DeathScreenInfo := $HUD/Death/Info
onready var MessageHUD := $HUD/Messages
onready var ScrapsAmount := $HUD/Scraps/Amount
onready var WandHUD := $HUD/Wands
onready var SpellBagHUD := $HUD/SpellBag
onready var WandSpellHUD := $HUD/Spells
onready var DescriptionBox := $HUD/Description
onready var ShortDescriptionBox := $HUD/ShortDesc
onready var DescriptionBoxName := $HUD/Description/Name
onready var DescriptionBoxInfo := $HUD/Description/Description
onready var MouseSpellSlot := $HUD/MouseSlot
onready var MouseWandSlot := $HUD/MouseWand

var Player :KinematicBody2D


var messages := []
var message_timer := 0.0
var mouse_spell = null
var mouse_wand = null
var generated := false
var block_cast := false
var level_ended := false
var advice := [
	"Avoid breaking your knees by not falling long distances",
	"The best way for your runs to last longer is to reduce the amount of times you're hit",
	"Finish the levels to progress through the game",
	"If you're getting bad items, try having better luck",
	"Get power ups to become able to finish the game",
	"You need at least one leg to be able to jump, make sure not to break both",
	"Kill the last boss to finish the game",
	"Blood is useful! Try and keep as much of it as possible inside your body",
	"In order to stay alive, survive a long as possible",
	"If you get lost, try to remember where you are",
	"If an enemy attacks you, dodge",
	"Use the controls to maneuver your character",
	"If you find yourself surrounded by enemies, get out of there",
	"If you find yourself surrounded by enemies, get out of there",
]
var player_died := false
var end_times : String # How long did the run last


func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	if Items.level == 1:
		Items.using_seed = Items.WorldRNG.seed
	UsefulAdvice.text = advice[randi()%advice.size()] + "\n"
	UsefulAdvice.text += "Seed: " + str(Items.using_seed)


func _process(delta):	
	# Control the temperature vignettes
	if Player.health.temperature > 30:
		HotHUD.modulate.a = lerp(HotHUD.modulate.a, (Player.health.temperature-30)/110.0, 0.2)
	else:
		ColdHUD.modulate.a = lerp(ColdHUD.modulate.a, (Player.health.temperature-30)/-60.0, 0.2)
	if generated and not player_died and not level_ended:
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 0.0, 0.2)
	
	# If the player is dead, show the death screen
	if player_died:
		DeathScreen.modulate.a = move_toward(DeathScreen.modulate.a, 1.0, 0.2)
		DeathScreenInfo.text = "Run Time: " + end_times + "\n"
		var death := "Internal organs damaged by impact"
		match Player.health_object().cause_of_death:
			Flesh.DEATHS.BLED: death = "Ran out of blood"
			Flesh.DEATHS.HOLES: death = "Sliced to at least two pieces"
			Flesh.DEATHS.HYPER: death = "Extremely high temperatures"
			Flesh.DEATHS.HYPO: death = "Extremely low temperatures"
			Flesh.DEATHS.SOUL: death = "Soul leaked out of her body"
		DeathScreenInfo.text += "Cause Of Death: " + death + "\n"
		DeathScreenInfo.text += "Levels: " + str(Items.level) + "\n"
		DeathScreenInfo.text += "Seed: " + str(Items.using_seed) + "\n\n"
		DeathScreenInfo.text += "Right click to start a new run"
		# If the Generating World screen is visible on screen
		# the player's data is reset and the scene is reloaded
		if GeneratingScreen.modulate.a > 0.9:
			Items.reset_player()
			get_tree().change_scene("res://Game.tscn")
		
		# If the player right clicks, generate a new world
		if Input.is_action_just_released("Interact2"):
			Items.player_health = Flesh.new()
			GeneratingScreen.modulate.a = 1.0
	
	# If the player didn't die, and instead the level ended
	elif level_ended:
		# If the generating world screen is fully visible,
		# reload the scene without resetting the player's progress
		if GeneratingScreen.modulate.a > 0.9:
			get_tree().change_scene("res://Game.tscn")
			
		# Generating World screen fadein
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 1.0, 0.2)
		
		# The fadein must go after the check to make sure it's fully faded in
		# when the scene change begins
	
	# If there are messages to read, show them
	if not messages.empty():
		MessageHUD.visible = true
		message_timer += delta
		MessageHUD.bbcode_text = "[center]" + messages[0] + "[/center]"
		if message_timer > messages[0].length()*0.2:
			message_timer = 0.0
			messages.pop_front()
	else:
		MessageHUD.visible = false
	
	# Inventory and items in HUD
	# Control the thing that displays the last picked up item
	if Items.last_pickup == null:
		LastItem.texture = null
	else:
		LastItem.texture = Items.last_pickup.texture
	
	# Shows the amount of clothes scraps the player has
	ScrapsAmount.text = str(Items.cloth_scraps)
	
	# Show the wands the player is carrying
	for i in WandHUD.get_child_count():
		WandHUD.get_child(i).render_wand(Items.player_wands[i], i == Items.selected_wand)
	
	# Show the spells the player is carrying
	for i in SpellBagHUD.get_child_count():
		if Items.player_spells[i] != null:
			SpellBagHUD.get_child(i).texture = Items.player_spells[i].texture
		else:
			SpellBagHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
	
	# Show the spells the wand the player is using has
	for i in WandSpellHUD.get_child_count():
		# If a non-empty wand slot is selected
		if Items.player_wands[Items.selected_wand] != null:
			# Make the spell hud visible
			WandSpellHUD.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			# If the wand has this slot
			if i < wand.spell_capacity:
				# Make it visible
				WandSpellHUD.get_child(i).visible = true
				# If the isn't empty, show the spell's texture
				if wand.spells[i] != null:
					WandSpellHUD.get_child(i).texture = wand.spells[i].texture
				else: # if it is empty, show the empty slot texture
					WandSpellHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
			else: # If the wand doesn't have this slot
				WandSpellHUD.get_child(i).visible = false
		else: # If an empty wand slot is selected
			WandSpellHUD.visible = false
	
	var mouse := get_viewport().get_mouse_position()
	
	# Reset the description boxes' visibility
	DescriptionBox.visible = false
	ShortDescriptionBox.visible = false
	ShortDescriptionBox.rect_size.x = 0
	# Variables for which inventory the player click and what slot
	var clicked := -1
	var slot := -1
	block_cast = false # Also stop blocking the player's ability to
	# cast spells
	
	# If the mouse is in the wands' area
	if mouse.x < 116 and mouse.y > 4 and mouse.y < 20:
		for i in 6:
			# If a slot is selected
			if mouse.x >= 4+i*(16+4) and mouse.x < 4+(i+1)*(16+4):
				# Set the inventory and slot clicked, and don't let the
				# player cast spells
				clicked = 2
				slot = i
				block_cast = true 
				# If the slot isn't empty
				if Items.player_wands[i] != null:
					# Which information to set
					if Input.is_key_pressed(KEY_SHIFT):
						DescriptionBox.visible = true
						DescriptionBoxName.text = "Wand"
						DescriptionBoxInfo.text = "Cast Cooldown: " + str(Items.player_wands[i].spell_recharge).pad_decimals(3)
						DescriptionBoxInfo.text += "\nRecharge Time: " + str(Items.player_wands[i].full_recharge).pad_decimals(3)
						if Items.player_wands[i].shuffle:
							DescriptionBoxInfo.text += "\nShuffle"
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.text =  str(Items.player_wands[i].spell_recharge).pad_decimals(2) + "/" + str(Items.player_wands[i].full_recharge).pad_decimals(2)
				break # Stop checking for if it's in a slot, we already did all this stuff
	
	# If the mouse is in the wands' spells area and is holding a wand
	if mouse.x < 116 and mouse.y > 25 and mouse.y < 25+16 and Items.player_wands[Items.selected_wand] != null:
		var wand :Wand = Items.player_wands[Items.selected_wand]
		for i in 6:
			# If it's in a slot
			if mouse.x >= 4+i*(16+4) and mouse.x < 4+(i+1)*(16+4):
				# Don't let the player cast spells
				block_cast = true
				clicked = 1
				# If this slot is had by the wand
				if i < wand.spell_capacity:
					# Then this is the slot that was clicked (aka I didn't click an empty area)
					slot = i
					# Set the description accordingly
					if wand.spells[i] != null:
						if Input.is_key_pressed(KEY_SHIFT):
							DescriptionBox.visible = true
							DescriptionBoxName.text = wand.spells[i].name
							DescriptionBoxInfo.text = wand.spells[i].description
						else:
							ShortDescriptionBox.visible = true
							ShortDescriptionBox.text =  wand.spells[i].name
	
	# If the mouse is in the spells bag's area and is holding a wand
	elif mouse.x < 16 + 4 and mouse.y > 62 and mouse.y < 178 and mouse.x > 4:
		for i in 6:
			# If it's in a slot
			if mouse.y >= 62+i*(16+4) and mouse.y < 62+(i+1)*(16+4):
				# Set what inventory and slot was clicked, block spell casts
				block_cast = true
				clicked = 0
				slot = i
				# Descriptions
				if Items.player_spells[i] != null:
					if Input.is_key_pressed(KEY_SHIFT):
						DescriptionBox.visible = true
						DescriptionBoxName.text = Items.player_spells[i].name
						DescriptionBoxInfo.text = Items.player_spells[i].description
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.text =  Items.player_spells[i].name
	
	# If the player is hovering over the last picked_up item, handle descriptions
	elif Items.last_pickup != null and mouse.x > 4 and mouse.y > 184 and mouse.x < 20 and mouse.y < 200:
		if Input.is_key_pressed(KEY_SHIFT):
			DescriptionBox.visible = true
			DescriptionBoxName.text = Items.last_pickup.name
			DescriptionBoxInfo.text = Items.last_pickup.description
		else:
			ShortDescriptionBox.visible = true
			ShortDescriptionBox.text = Items.last_pickup.name
	
	# If the player clicks a part of the inventory, swap that slot's content
	# with the mouse slot's content
	if Input.is_action_just_pressed("Interact1") and clicked != -1:
		match clicked:
			1:
				if slot != -1:
					var wand :Wand = Items.player_wands[Items.selected_wand]
					var k :Spell = wand.spells[slot]
					Items.player_wands[Items.selected_wand].spells[slot] = mouse_spell
					mouse_spell = k
			0:
				if slot != -1:
					var k :Spell = Items.player_spells[slot]
					Items.player_spells[slot] = mouse_spell
					mouse_spell = k
			2:
				if slot != -1:
					var k :Wand = Items.player_wands[slot]
					Items.player_wands[slot] = mouse_wand
					mouse_wand = k
	
	# If the player right clicks and is not in an inventory space
	# drop the  item
	if Input.is_action_just_pressed("Interact2") and clicked == -1:
		if mouse_spell != null:
			var new := preload("res://Items/SpellEntity.tscn").instance()
			new.spell = mouse_spell
			get_parent().add_child(new)
			new.position = Player.position
			new.linear_velocity.x = -120 + randf()*240
		mouse_spell = null
		if mouse_wand != null:
			var new := preload("res://Items/WandEntity.tscn").instance()
			new.wand = mouse_wand
			get_parent().add_child(new)
			new.position = Player.position
			new.linear_velocity.x = -120 + randf()*240
		mouse_wand = null
	
	# Hide the mouse slots if they have nothing
	MouseSpellSlot.visible = mouse_spell != null
	MouseWandSlot.visible = mouse_wand != null
	if mouse_spell != null:
		MouseSpellSlot.texture = mouse_spell.texture
	if mouse_wand != null:
		MouseWandSlot.render_wand(mouse_wand, true)
	# Position them
	MouseSpellSlot.rect_position = mouse + Vector2(-16,0)
	MouseWandSlot.rect_position = mouse + Vector2(0,-16)
	
	# Set the size of the description box
	DescriptionBox.rect_size = Vector2(144, 18+DescriptionBoxInfo.rect_size.y+4)
	
	# Move the description box up if it's offscreen
	if mouse.y + DescriptionBox.rect_size.y > 225:
		DescriptionBox.rect_position = mouse - Vector2(0, DescriptionBox.rect_size.y)
	else:
		DescriptionBox.rect_position = mouse
	ShortDescriptionBox.rect_position = mouse


func add_message(message:String):
	messages.append(message)


func _on_generated_world():
	generated = true


# Calculate time in minutes and seconds
func _on_player_died():
	var msecs :int = OS.get_ticks_msec() - Items.run_start_time
	var secs = float(msecs) / 1000.0
	var isecs = int(secs) 
	var csecs =  isecs % 60
	var cmsecs = secs - isecs
	var mins = (isecs / 60) % 60
	end_times = str(mins) + "m" + str(csecs) + "s"
	player_died = true

func _on_level_ended():
	level_ended = true
	Items.level += 1

