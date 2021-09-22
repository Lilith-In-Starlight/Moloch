extends CanvasLayer


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
var last_pickup :Item = null
func _ready():
	if Items.level == 1:
		Items.using_seed = Items.WorldRNG.seed
	$HUD/Generating/UsefulAdvice.text = advice[randi()%advice.size()] + "\n"
	$HUD/Generating/UsefulAdvice.text += "Seed: " + str(Items.using_seed)
var end_times : String
func _process(delta):
	if last_pickup == null:
		$HUD/LastItem.texture = null
	else:
		$HUD/LastItem.texture = last_pickup.texture
	if get_tree().get_nodes_in_group("Player")[0].health.temperature > 30:
		$HUD/Hot.modulate.a = lerp($HUD/Hot.modulate.a, (get_tree().get_nodes_in_group("Player")[0].health.temperature-30)/110.0, 0.2)
	else:
		$HUD/Cold.modulate.a = lerp($HUD/Cold.modulate.a, (get_tree().get_nodes_in_group("Player")[0].health.temperature-30)/-60.0, 0.2)
	if generated and not player_died and not level_ended:
		$HUD/Generating.modulate.a = move_toward($HUD/Generating.modulate.a, 0.0, 0.2)
		
	if player_died:
		$HUD/Death.modulate.a = move_toward($HUD/Death.modulate.a, 1.0, 0.2)
		$HUD/Death/Info.text = "Run Time: " + end_times + "\n"
		$HUD/Death/Info.text += "Levels: " + str(Items.level) + "\n"
		$HUD/Death/Info.text += "Seed: " + str(Items.using_seed) + "\n\n"
		$HUD/Death/Info.text += "Right click to start a new run"
		if $HUD/Generating.modulate.a > 0.9:
			Items.reset_player()
			get_tree().change_scene("res://Game.tscn")
		if Input.is_action_just_released("Interact2"):
			Items.player_health = Flesh.new()
			$HUD/Generating.modulate.a = 1.0
	elif level_ended:
		if $HUD/Generating.modulate.a > 0.9:
			get_tree().change_scene("res://Game.tscn")
		$HUD/Generating.modulate.a = move_toward($HUD/Generating.modulate.a, 1.0, 0.2)
	if not messages.empty():
		$HUD/Messages.visible = true
		message_timer += delta
		$HUD/Messages.bbcode_text = "[center]" + messages[0] + "[/center]"
		if message_timer > messages[0].length()*0.2:
			message_timer = 0.0
			messages.pop_front()
	else:
		$HUD/Messages.visible = false
	
	$HUD/Scraps/Amount.text = str(Items.cloth_scraps)
	for i in $HUD/Wands.get_child_count():
		$HUD/Wands.get_child(i).render_wand(Items.player_wands[i], i == Items.selected_wand)
				
	for i in $HUD/SpellBag.get_child_count():
		if Items.player_spells[i] != null:
			$HUD/SpellBag.get_child(i).texture = Items.player_spells[i].texture
		else:
			$HUD/SpellBag.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
	
	for i in $HUD/Spells.get_child_count():
		if Items.player_wands[Items.selected_wand] != null:
			$HUD/Spells.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			if i < wand.spell_capacity:
				$HUD/Spells.get_child(i).visible = true
				if wand.spells[i] != null:
					$HUD/Spells.get_child(i).texture = wand.spells[i].texture
				else:
					$HUD/Spells.get_child(i).texture = preload("res://Sprites/Spells/Empty.png")
			else:
				$HUD/Spells.get_child(i).visible = false
		else:
			$HUD/Spells.visible = false
	
	var mouse := get_viewport().get_mouse_position()
	
	$HUD/Description.visible = false
	$HUD/ShortDesc.visible = false
	$HUD/ShortDesc.rect_size.x = 0
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
						$HUD/Description.visible = true
						$HUD/Description/Name.text = "Wand"
						$HUD/Description/Description.text = "Cast Cooldown: " + str(Items.player_wands[i].spell_recharge).pad_decimals(3)
						$HUD/Description/Description.text += "\nCooldown: " + str(Items.player_wands[i].full_recharge).pad_decimals(3)
					else:
						$HUD/ShortDesc.visible = true
						var a :=  0.25
						$HUD/ShortDesc.text =  str(Items.player_wands[i].spell_recharge).pad_decimals(2) + "/" + str(Items.player_wands[i].full_recharge).pad_decimals(2)
	
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
							$HUD/Description.visible = true
							$HUD/Description/Name.text = wand.spells[i].name
							$HUD/Description/Description.text = wand.spells[i].description
						else:
							$HUD/ShortDesc.visible = true
							$HUD/ShortDesc.text =  wand.spells[i].name
	
	if mouse.x < 16 + 4 and mouse.y > 62 and mouse.y < 178 and mouse.x > 4:
		for i in 6:
			if mouse.y >= 62+i*(16+4) and mouse.y < 62+(i+1)*(16+4):
				block_cast = true
				clicked = 0
				slot = i
				if Items.player_spells[i] != null:
					if Input.is_key_pressed(KEY_SHIFT):
						$HUD/Description.visible = true
						$HUD/Description/Name.text = Items.player_spells[i].name
						$HUD/Description/Description.text = Items.player_spells[i].description
					else:
						$HUD/ShortDesc.visible = true
						$HUD/ShortDesc.text =  Items.player_spells[i].name
	
	if last_pickup != null and mouse.x > 4 and mouse.y > 184 and mouse.x < 20 and mouse.y < 200:
		if Input.is_key_pressed(KEY_SHIFT):
			$HUD/Description.visible = true
			$HUD/Description/Name.text = last_pickup.name
			$HUD/Description/Description.text = last_pickup.description
		else:
			$HUD/ShortDesc.visible = true
			$HUD/ShortDesc.text = last_pickup.name
	
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
			new.position = get_tree().get_nodes_in_group("Player")[0].position
			new.linear_velocity.x = -120 + randf()*240
		mouse_spell = null
		if mouse_wand != null:
			var new := preload("res://Items/WandEntity.tscn").instance()
			new.wand = mouse_wand
			get_parent().add_child(new)
			new.position = get_tree().get_nodes_in_group("Player")[0].position
			new.linear_velocity.x = -120 + randf()*240
		mouse_wand = null
	
	$HUD/MouseSlot.visible = mouse_spell != null
	$HUD/MouseWand.visible = mouse_wand != null
	$HUD/MouseSlot.rect_position = mouse + Vector2(-16,0)
	$HUD/MouseWand.rect_position = mouse + Vector2(0,-16)
	if mouse_spell != null:
		$HUD/MouseSlot.texture = mouse_spell.texture
	if mouse_wand != null:
		$HUD/MouseWand.render_wand(mouse_wand, true)
		
	
	$HUD/Description.rect_size = Vector2(144, 18+$HUD/Description/Description.rect_size.y+4)
	if mouse.y + $HUD/Description.rect_size.y > 225:
		$HUD/Description.rect_position = mouse - Vector2(0, $HUD/Description.rect_size.y)
	else:
		$HUD/Description.rect_position = mouse
	$HUD/ShortDesc.rect_position = mouse


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

