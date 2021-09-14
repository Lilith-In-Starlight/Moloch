extends Node

var item_names := {
	"wings" : "Wings",
	"iron knees" : "Iron Knees",
	"thickblood" : "Blod Compression",
}
var item_descriptions := {
	"wings" : "I don't fear the ground anymore.",
	"iron knees" : "Unsnappable legs.",
	"thickblood" : "Your veins and muscles become able to hold higher pressures",
}
var spell_names := {
	"fuck you" : "Fuck You",
	"evilsight" : "Sight Of Evil",
}
var spell_descriptions := {
	"fuck you" : "Fuck everything in that particular direction",
	"evilsight" : "Casts a ray of decay",
}

var rooms := []

var items := ["wings", "iron knees", "thickblood", "heal"]
var spells := ["fuck you", "evilsight"]

var player_items := []

var player_spells := []
var player_wands := [null,null,null,null,null,null]
var selected_wand := 0

var Player :KinematicBody2D
var Cam
var can_cast := true

func _ready():
	Player = get_tree().get_nodes_in_group("Player")[0]
	Cam = get_tree().get_nodes_in_group("Camera")[0]
	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()


func _process(delta):
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
			
			
