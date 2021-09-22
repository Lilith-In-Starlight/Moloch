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
]
var player_died := false
func _ready():
	Player = Player
	if Items.level == 1:
		Items.using_seed = Items.WorldRNG.seed
	UsefulAdvice.text = advice[randi()%advice.size()] + "\n"
	UsefulAdvice.text += "Seed: " + str(Items.using_seed)
var end_times : String
func _process(delta):
	if Items.last_pickup == null:
		LastItem.texture = null
	else:
		LastItem.texture = Items.last_pickup.texture
	if Player.health.temperature > 30:
		HotHUD.modulate.a = lerp(HotHUD.modulate.a, (Player.health.temperature-30)/110.0, 0.2)
	else:
		ColdHUD.modulate.a = lerp(ColdHUD.modulate.a, (Player.health.temperature-30)/-60.0, 0.2)
	if generated and not player_died and not level_ended:
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 0.0, 0.2)
		
	if player_died:
		DeathScreen.modulate.a = move_toward(DeathScreen.modulate.a, 1.0, 0.2)
		DeathScreenInfo.text = "Run Time: " + end_times + "\n"
		DeathScreenInfo.text += "Levels: " + str(Items.level) + "\n"
		DeathScreenInfo.text += "Seed: " + str(Items.using_seed) + "\n\n"
		DeathScreenInfo.text += "Right click to start a new run"
		if GeneratingScreen.modulate.a > 0.9:
			Items.reset_player()
			get_tree().change_scene("res://Game.tscn")
		if Input.is_action_just_released("Interact2"):
			Items.player_health = Flesh.new()
			GeneratingScreen.modulate.a = 1.0
	elif level_ended:
		if GeneratingScreen.modulate.a > 0.9:
			get_tree().change_scene("res://Game.tscn")
		GeneratingScreen.modulate.a = move_toward(GeneratingScreen.modulate.a, 1.0, 0.2)
	if not messages.empty():
		MessageHUD.visible = true
		message_timer += delta
		MessageHUD.bbcode_text = "[center]" + messages[0] + "[/center]"
		if message_timer > messages[0].length()*0.2:
			message_timer = 0.0
			messages.pop_front()
	else:
		MessageHUD.visible = false
	
	ScrapsAmount.text = str(Items.cloth_scraps)
	for i in WandHUD.get_child_count():
		WandHUD.get_child(i).render_wand(Items.player_wands[i], i == Items.selected_wand)
				
	for i in SpellBagHUD.get_child_count():
		if Items.player_spells[i] != null:
			SpellBagHUD.get_child(i).texture = Items.player_spells[i].texture
		else:
			SpellBagHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
	
	for i in WandSpellHUD.get_child_count():
		if Items.player_wands[Items.selected_wand] != null:
			WandSpellHUD.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			if i < wand.spell_capacity:
				WandSpellHUD.get_child(i).visible = true
				if wand.spells[i] != null:
					WandSpellHUD.get_child(i).texture = wand.spells[i].texture
				else:
					WandSpellHUD.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
			else:
				WandSpellHUD.get_child(i).visible = false
		else:
			WandSpellHUD.visible = false
	
	var mouse := get_viewport().get_mouse_position()
	
	DescriptionBox.visible = false
	ShortDescriptionBox.visible = false
	ShortDescriptionBox.rect_size.x = 0
	var clicked := -1
	var slot := -1
	block_cast = false
	# Wands
	if mouse.x < 116 and mouse.y > 4 and mouse.y < 20:
		for i in 6:
			if mouse.x >= 4+i*(16+4) and mouse.x < 4+(i+1)*(16+4):
				clicked = 2
				slot = i
				block_cast = true
				if Items.player_wands[i] != null:
					if Input.is_key_pressed(KEY_SHIFT):
						DescriptionBox.visible = true
						DescriptionBoxName.text = "Wand"
						DescriptionBoxInfo.text = "Cast Cooldown: " + str(Items.player_wands[i].spell_recharge).pad_decimals(3)
						DescriptionBoxInfo.text += "\nCooldown: " + str(Items.player_wands[i].full_recharge).pad_decimals(3)
					else:
						ShortDescriptionBox.visible = true
						var a :=  0.25
						ShortDescriptionBox.text =  str(Items.player_wands[i].spell_recharge).pad_decimals(2) + "/" + str(Items.player_wands[i].full_recharge).pad_decimals(2)
	
	# Spells
	if mouse.x < 116 and mouse.y > 25 and mouse.y < 25+16 and Items.player_wands[Items.selected_wand] != null:
		var wand :Wand = Items.player_wands[Items.selected_wand]
		for i in 6:
			if mouse.x >= 4+i*(16+4) and mouse.x < 4+(i+1)*(16+4):
				block_cast = true
				clicked = 1
				if i < wand.spell_capacity:
					slot = i
					if wand.spells[i] != null:
						if Input.is_key_pressed(KEY_SHIFT):
							DescriptionBox.visible = true
							DescriptionBoxName.text = wand.spells[i].name
							DescriptionBoxInfo.text = wand.spells[i].description
						else:
							ShortDescriptionBox.visible = true
							ShortDescriptionBox.text =  wand.spells[i].name
	
	if mouse.x < 16 + 4 and mouse.y > 62 and mouse.y < 178 and mouse.x > 4:
		for i in 6:
			if mouse.y >= 62+i*(16+4) and mouse.y < 62+(i+1)*(16+4):
				block_cast = true
				clicked = 0
				slot = i
				if Items.player_spells[i] != null:
					if Input.is_key_pressed(KEY_SHIFT):
						DescriptionBox.visible = true
						DescriptionBoxName.text = Items.player_spells[i].name
						DescriptionBoxInfo.text = Items.player_spells[i].description
					else:
						ShortDescriptionBox.visible = true
						ShortDescriptionBox.text =  Items.player_spells[i].name
	
	if Items.last_pickup != null and mouse.x > 4 and mouse.y > 184 and mouse.x < 20 and mouse.y < 200:
		if Input.is_key_pressed(KEY_SHIFT):
			DescriptionBox.visible = true
			DescriptionBoxName.text = Items.last_pickup.name
			DescriptionBoxInfo.text = Items.last_pickup.description
		else:
			ShortDescriptionBox.visible = true
			ShortDescriptionBox.text = Items.last_pickup.name
	
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
	
	MouseSpellSlot.visible = mouse_spell != null
	MouseWandSlot.visible = mouse_wand != null
	MouseSpellSlot.rect_position = mouse + Vector2(-16,0)
	MouseWandSlot.rect_position = mouse + Vector2(0,-16)
	if mouse_spell != null:
		MouseSpellSlot.texture = mouse_spell.texture
	if mouse_wand != null:
		MouseWandSlot.render_wand(mouse_wand, true)
		
	
	DescriptionBox.rect_size = Vector2(144, 18+DescriptionBoxInfo.rect_size.y+4)
	if mouse.y + DescriptionBox.rect_size.y > 225:
		DescriptionBox.rect_position = mouse - Vector2(0, DescriptionBox.rect_size.y)
	else:
		DescriptionBox.rect_position = mouse
	ShortDescriptionBox.rect_position = mouse


func add_message(message:String):
	messages.append(message)


func _on_generated_world():
	generated = true


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

