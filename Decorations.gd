extends Node


var paintings := {}
var signs := {}

func _ready():
	register_sign(preload("res://Sprites/Elements/Decoration/Posters/Poster1.png"), "lawful")
	register_sign(preload("res://Sprites/Elements/Decoration/Posters/Poster1.png"), "rebel")
	register_sign(preload("res://Sprites/Elements/Decoration/Posters/Poster1_ripped.png"), "rebel")
	register_sign(preload("res://Sprites/Elements/Decoration/Posters/Poster1_rotten.png"), "rebel", true)
	register_sign(preload("res://Sprites/Elements/Decoration/Posters/Poster1_rotten.png"), "lawful", true)
	
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/painting1.png"), "lawful")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader2.png"), "lawful")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader2_vandalized.png"), "rebel")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized4.png"), "rebel")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized.png"), "rebel")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized3.png"), "rebel")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized2.png"), "rebel")
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_rotten.png"), "lawful", true)
	register_painting(preload("res://Sprites/Elements/Decoration/Paintings/leader_vandalized_rotten.png"), "rebel", true)

func register_painting(painting:Texture, type :String, mushroom := false):
	if not type in paintings:
		paintings[type] = {true:[], false:[]}
	paintings[type][mushroom].append(painting)
	
func register_sign(painting:Texture, type :String, mushroom := false):
	if not type in signs:
		signs[type] = {true:[], false:[]}
	signs[type][mushroom].append(painting)

func get_painting(type:String, mushroom := false) -> Texture:
	if type in paintings:
		return paintings[type][mushroom][Items.WorldRNG.randi()%paintings[type][mushroom].size()]
	return null
	
func get_sign(type:String, mushroom := false) -> Texture:
	if type in signs:
		return signs[type][mushroom][Items.WorldRNG.randi()%signs[type][mushroom].size()]
	return null
