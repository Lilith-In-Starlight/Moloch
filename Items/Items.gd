extends Node

var items := {}

var rooms := []

var spells := {}

var player_items := []

var player_spells := [null,null,null,null,null,null]
var player_wands := [null,null,null,null,null,null]
var selected_wand := 0

var Player :KinematicBody2D
var player_health := Flesh.new()
var Cam :Camera2D
var can_cast := true

var run_start_time :int

var cloth_scraps := 2

func _ready():
	register_item("heal", "Heal", "Return the flesh to a state previous", preload("res://Sprites/Items/Heal.png"))
	register_item("ironknees", "Iron Knees", "Fear the ground no more", preload("res://Sprites/Items/IronKnees.png"))
	register_item("thickblood", "Thick Blood", "Pressurized Veins", preload("res://Sprites/Items/ThickBlood.png"))
	register_item("wings", "Butterfly Wings", "Metamorphosis", preload("res://Sprites/Items/Wings.png"))
	register_item("gasolineblood", "Blood To Gasoline", "Your insides become volatile", preload("res://Sprites/Items/BloodToGasoline.png"))
	register_item("scraps", "Cloth Scraps", "Seal your wounds, somewhat", preload("res://Sprites/Items/Scraps.png"))
	register_spell("fuck you", "Fuck You", "Fuck everything in that particular direction", preload("res://Sprites/Spells/FuckYou.png"))
	register_spell("evilsight", "Evil Eye", "Look at things so fiercely you tear them apart", preload("res://Sprites/Spells/EvilEye.png"))
	register_spell("shatter", "Unstable Shattering", "Summon orbs that vibrate in frequencies that disturb souls", preload("res://Sprites/Spells/Unstable.png"))
	register_spell("ray", "Generic Ray", "Pew pew!", preload("res://Sprites/Spells/Ray.png"))
	register_spell("push", "Push", "Away, away...", preload("res://Sprites/Spells/Push.png"))
	register_spell("pull", "Pull", "Together, together...", preload("res://Sprites/Spells/Pull.png"))
	register_spell("r", "Alveolar Trill", "RRRRRRRRRRRRRRRR", preload("res://Sprites/Spells/R.png"))
	
	if not get_tree().get_nodes_in_group("Player").empty():
		Player = get_tree().get_nodes_in_group("Player")[0]
		Cam = get_tree().get_nodes_in_group("Camera")[0]
	var selected_wand := 0
	player_health = Flesh.new()

	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()


func register_item(name_id:String, name:String, desc:String, texture:Texture):
	var new := Item.new()
	new.name = name
	new.description = desc
	new.texture = texture
	new.id = name_id
	items[name_id] = new
	
func register_spell(name_id:String, name:String, desc:String, texture :Texture):
	var new := Spell.new()
	new.name = name
	new.description = desc
	new.id = name_id
	new.texture = texture
	spells[name_id] = new


func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		OS.window_fullscreen = !OS.window_fullscreen
	if not is_instance_valid(Player) and not get_tree().get_nodes_in_group("Player").empty():
		player_health = Flesh.new()
		cloth_scraps = 2
		Player = get_tree().get_nodes_in_group("Player")[0]
		Cam = get_tree().get_nodes_in_group("Camera")[0]
		player_items = []
		player_spells = [null,null,null,null,null,null]
		player_wands = [null,null,null,null,null,null]
		player_wands[0] = Wand.new()
		player_wands[1] = Wand.new()
	for wand in player_wands:
		if wand is Wand:
			if wand.running:
				if can_cast:
					can_cast = false
					if wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null:
						match wand.spells[wand.current_spell].id:
							"fuck you":
								var spell := preload("res://Spells/FuckYou.tscn").instance()
								spell.position = Player.position
								Player.get_parent().add_child(spell)
							"evilsight":
								var spell := preload("res://Spells/EvilSight.tscn").instance()
								spell.position = Player.position
								Player.get_parent().add_child(spell)
							"shatter":
								var spell := preload("res://Spells/ShatteringOrb.tscn").instance()
								spell.position = Player.position
								Player.get_parent().add_child(spell)
							"ray":
								var spell := preload("res://Spells/Ray.tscn").instance()
								spell.position = Player.position
								Player.get_parent().add_child(spell)
							"push":
								var spell := preload("res://Spells/Push.tscn").instance()
								spell.position = Player.position + Player.get_local_mouse_position()
								Player.get_parent().add_child(spell)
							"pull":
								var spell := preload("res://Spells/Pull.tscn").instance()
								spell.position = Player.position + Player.get_local_mouse_position()
								Player.get_parent().add_child(spell)
							"r":
								var spell := preload("res://Spells/AlveolarTrill.tscn").instance()
								spell.position = Player.position
								Player.get_parent().add_child(spell)
				if (wand.current_spell >= wand.spell_capacity-1 or wand.spells[wand.current_spell] == null) and wand.recharge >= wand.full_recharge:
					wand.recharge = 0.0
					wand.running = false
					can_cast = true
					wand.current_spell = 0
				elif wand.recharge >= wand.spell_recharge and (wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null):
					wand.recharge = 0.0
					wand.current_spell += 1
					can_cast = true
				else:
					wand.recharge += delta
			else:
				wand.current_spell = 0



