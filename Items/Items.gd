extends Node

var items := {
	1: {},
	2: {},
	3: {},
	4: {},
	5: {},
}

var rooms := []

var spells := {
	1: {},
	2: {},
	3: {},
	4: {},
	5: {},
}

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
	register_item(1, "heal", "Heal", "Return the flesh to a state previous", preload("res://Sprites/Items/Heal.png"))
	register_item(1, "ironknees", "Iron Knees", "Fear the ground no more", preload("res://Sprites/Items/IronKnees.png"))
	register_item(1, "thickblood", "Thick Blood", "Pressurized Veins", preload("res://Sprites/Items/ThickBlood.png"))
	register_item(2, "wings", "Butterfly Wings", "Metamorphosis", preload("res://Sprites/Items/Wings.png"))
	register_item(1, "gasolineblood", "Blood To Gasoline", "Your insides become volatile", preload("res://Sprites/Items/BloodToGasoline.png"))
	register_item(1, "scraps", "Cloth Scraps", "Seal your wounds, somewhat", preload("res://Sprites/Items/Scraps.png"))
	
	register_spell(4, "fuck you", "Fuck You", "Fuck everything in that particular direction", preload("res://Sprites/Spells/FuckYou.png"), preload("res://Spells/FuckYou.tscn"))
	register_spell(2, "evilsight", "Evil Eye", "Look at things so fiercely you tear them apart", preload("res://Sprites/Spells/EvilEye.png"), preload("res://Spells/EvilSight.tscn"))
	register_spell(1, "shatter", "Unstable Shattering", "Summon orbs that vibrate in frequencies that disturb souls", preload("res://Sprites/Spells/Unstable.png"), preload("res://Spells/ShatteringOrb.tscn"))
	register_spell(1, "ray", "Generic Ray", "Pew pew!", preload("res://Sprites/Spells/Ray.png"), preload("res://Spells/Ray.tscn"))
	register_spell(4, "push", "Push", "Away, away...", preload("res://Sprites/Spells/Push.png"), preload("res://Spells/Push.tscn"))
	register_spell(4, "pull", "Pull", "Together, together...", preload("res://Sprites/Spells/Pull.png"), preload("res://Spells/Pull.tscn"))
	register_spell(2, "r", "Alveolar Trill", "RRRRRRRRRRRRRRRR", preload("res://Sprites/Spells/R.png"), preload("res://Spells/AlveolarTrill.tscn"))
	
	if not get_tree().get_nodes_in_group("Player").empty():
		Player = get_tree().get_nodes_in_group("Player")[0]
		Cam = get_tree().get_nodes_in_group("Camera")[0]
	var selected_wand := 0
	player_health = Flesh.new()

	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()


func register_item(tier:int, name_id:String, name:String, desc:String, texture:Texture):
	var new := Item.new()
	new.name = name
	new.description = desc
	new.texture = texture
	new.id = name_id
	items[tier][name_id] = new
	
func register_spell(tier:int, name_id:String, name:String, desc:String, texture :Texture, entity :PackedScene):
	var new := Spell.new()
	new.name = name
	new.description = desc
	new.id = name_id
	new.texture = texture
	new.entity = entity
	spells[tier][name_id] = new


func _process(delta):
	if Input.is_action_just_pressed("ui_end"):
		OS.window_fullscreen = !OS.window_fullscreen
		OS.window_borderless = OS.window_fullscreen
	
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
						var spell :Node2D = wand.spells[wand.current_spell].entity.instance()
						spell.Caster = Player
						spell.goal = Player.get_local_mouse_position() + Player.position
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


func pick_random_spell() -> Spell:
	var random := randf()
	var tier := 1
	if random < 0.5:
		tier = 1
	elif random < 0.87:
		tier = 2
	elif random < 0.998:
		tier = 3
	elif random < 1.0:
		tier = 4
	if spells[tier].empty():
		return pick_random_spell()
	return spells[tier].values()[randi()%spells[tier].values().size()]

func pick_random_item() -> Item:
	var random := randf()
	var tier := 1
	if random < 0.6:
		tier = 1
	elif random < 0.87:
		tier = 2
	elif random < 0.998:
		tier = 3
	elif random < 1.0:
		tier = 4
	if items[tier].empty():
		return pick_random_item()
	return items[tier].values()[randi()%items[tier].values().size()]
