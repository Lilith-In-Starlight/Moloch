extends CanvasLayer


var messages := []
var message_timer := 0.0
var mouse_spell = null
var mouse_wand = null
var generated := false
var block_cast := false
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
]
var player_died := false
func _ready():
	$HUD/Generating/UsefulAdvice.text = advice[randi()%advice.size()]
var end_times : String
func _process(delta):
	if generated and not player_died:
		$HUD/Generating.modulate.a = move_toward($HUD/Generating.modulate.a, 0.0, 0.2)
		
	if player_died:
		$HUD/Death.modulate.a = move_toward($HUD/Death.modulate.a, 1.0, 0.2)
		$HUD/Death/Info.text = "Run Time: " + end_times + "\n\n"
		$HUD/Death/Info.text += "Right click to start a new run"
		if $HUD/Generating.modulate.a > 0.9:
			get_tree().reload_current_scene()
		if Input.is_action_just_released("Interact2"):
			Items.player_health = Flesh.new()
			$HUD/Generating.modulate.a = 1.0
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
				
	for i in $HUD/SpellBag.get_child_count():
		if Items.player_spells[i] != null:
			$HUD/SpellBag.get_child(i).modulate = Items.player_spells[i].color
		else:
			$HUD/SpellBag.get_child(i).modulate = "2a2a2a"
	
	for i in $HUD/Spells.get_child_count():
		if Items.player_wands[Items.selected_wand] != null:
			$HUD/Spells.visible = true
			var wand :Wand = Items.player_wands[Items.selected_wand]
			if i < wand.spell_capacity:
				$HUD/Spells.get_child(i).visible = true
				if wand.spells[i] != null:
					$HUD/Spells.get_child(i).modulate = wand.spells[i].color
				else:
					$HUD/Spells.get_child(i).modulate = "2a2a2a"
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
						$HUD/Description/Description.text = "Cast Cooldown: " + str(Items.player_wands[i].spell_recharge).pad_decimals(5)
						$HUD/Description/Description.text += "\nCooldown: " + str(Items.player_wands[i].full_recharge).pad_decimals(5)
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
	
	if mouse.x < 16 and mouse.y > 62 and mouse.y < 178 and mouse.x > 4:
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
	
	$HUD/MouseSlot.visible = mouse_spell != null
	$HUD/MouseSlot.rect_position = mouse + Vector2(-16,0)
	if mouse_spell != null:
		$HUD/MouseSlot.modulate = mouse_spell.color
		
	
	$HUD/Description.rect_size = Vector2(144, 18+$HUD/Description/Description.rect_size.y+4)
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
