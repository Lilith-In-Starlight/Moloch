extends Node

var items := {}

var spell_names := {
	"fuck you" : "Fuck You",
	"evilsight" : "Sight Of Evil",
	"shatter" : "Shattering Orbs",
	"ray" : "Generic Gun",
}
var spell_descriptions := {
	"fuck you" : "Fuck everything in that particular direction",
	"evilsight" : "Casts a ray of decay",
	"shatter" : "Induces vibrations that shatter the soul",
	"ray" : "Summons a generic ray",
}

var rooms := []

var spells := ["fuck you", "evilsight", "shatter", "ray"]

var player_items := []

var player_spells := []
var player_wands := [null,null,null,null,null,null]
var selected_wand := 0

var Player :KinematicBody2D
var player_health := Flesh.new()
var Cam :Camera2D
var can_cast := true

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	var selected_wand := 0
	player_health = Flesh.new()

	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()
	
	register_item("heal", "Heal", "Return the flesh to a state previous", preload("res://Sprites/Items/Heal.png"))
	register_item("ironknees", "Iron Knees", "Fear the ground no more", preload("res://Sprites/Items/IronKnees.png"))
	register_item("thickblood", "Thick Blood", "Pressurized Veins", preload("res://Sprites/Items/ThickBlood.png"))
	register_item("wings", "Butterfly Wings", "Metamorphosis", preload("res://Sprites/Items/Wings.png"))
	register_item("gasolineblood", "Blood To Gasoline", "Your insides become volatile", preload("res://Sprites/Items/BloodToGasoline.png"))
	


func register_item(name_id:String, name:String, desc:String, texture:Texture):
	var new := Item.new()
	new.name = name
	new.description = desc
	new.texture = texture
	new.id = name_id
	items[name_id] = new


func _process(delta):
	if not is_instance_valid(Player):
		player_health = Flesh.new()
		Player = get_tree().get_nodes_in_group("Player")[0]
		Cam = get_tree().get_nodes_in_group("Camera")[0]
		player_items = []
		player_spells = []
		player_wands = [null,null,null,null,null,null]
		player_wands[0] = Wand.new()
		player_wands[1] = Wand.new()
	for wand in player_wands:
		if wand is Wand:
			if wand.running:
				if can_cast:
					can_cast = false
					match wand.spells[wand.current_spell]:
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
				if wand.current_spell >= wand.spells.size()-1 and wand.recharge >= wand.full_recharge:
					wand.recharge = 0.0
					wand.running = false
					can_cast = true
					wand.current_spell = 0
				elif wand.recharge >= wand.full_recharge:
					wand.recharge = 0.0
					wand.current_spell += 1
					can_cast = true
				else:
					wand.recharge += delta
			
			
