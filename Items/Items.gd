extends Node

# Tiered items
var items := {
	1: {},
	2: {},
	3: {},
	4: {},
	5: {},
}

# Tiered spells
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
var can_cast := true

var run_start_time :int

var cloth_scraps := 3

var WorldRNG := RandomNumberGenerator.new()
var LootRNG := RandomNumberGenerator.new()
var custom_seed := 0

var level := 1

var using_seed := 0 # WorldRNG's seed changes, this one doesn't

var last_pickup :Item = null

func _ready():
	var generator_seed := hash(OS.get_time())
	print("Generator seed: ", generator_seed)
	seed(generator_seed)
	WorldRNG.seed = generator_seed
	# Register items and spells
	register_item(2, "heal", "Growth", "Return the flesh to a state previous", preload("res://Sprites/Items/Heal.png"))
	register_item(1, "ironknees", "Iron Knees", "Fear the ground no more", preload("res://Sprites/Items/IronKnees.png"))
	register_item(1, "thickblood", "Thick Blood", "Pressurized Veins", preload("res://Sprites/Items/ThickBlood.png"))
	register_item(3, "wings", "Butterfly Wings", "Metamorphosis", preload("res://Sprites/Items/Wings.png"))
	register_item(1, "gasolineblood", "Blood To Nitroglycerine", "Your insides become volatile", preload("res://Sprites/Items/BloodToGasoline.png"))
	register_item(1, "scraps", "Cloth Scraps", "Seal your wounds, somewhat", preload("res://Sprites/Items/Scraps.png"))
	register_item(1, "soulfulpill", "Soulful Pill", "Heals the mind", preload("res://Sprites/Items/SoulfulPill.png"))
	register_item(2, "monocle", "Pig's Monocle", "See all the shinies", preload("res://Sprites/Items/PigsMonocle.png"))
	register_item(2, "bandaid", "Band-aid", "Makes it more likely for bleeding to stop on its own", preload("res://Sprites/Items/Bandaid.png"))
	
	register_spell(4, "fuck you", "Fuck You", "Fuck everything in that particular direction", preload("res://Sprites/Spells/FuckYou.png"), preload("res://Spells/FuckYou.tscn"))
	register_spell(2, "evilsight", "Evil Eye", "Look at things so fiercely you tear them apart", preload("res://Sprites/Spells/EvilEye.png"), preload("res://Spells/EvilSight.tscn"))
	register_spell(1, "shatter", "Unstable Shattering", "Summon orbs that vibrate in frequencies that disturb souls", preload("res://Sprites/Spells/Unstable.png"), preload("res://Spells/ShatteringOrb.tscn"))
	register_spell(1, "ray", "Generic Ray", "Pew pew!", preload("res://Sprites/Spells/Ray.png"), preload("res://Spells/Ray.tscn"))
	register_spell(4, "push", "Push", "Away, away...", preload("res://Sprites/Spells/Push.png"), preload("res://Spells/Push.tscn"))
	register_spell(4, "pull", "Pull", "Together, together...", preload("res://Sprites/Spells/Pull.png"), preload("res://Spells/Pull.tscn"))
	register_spell(3, "r", "Alveolar Trill", "RRRRRRRRRRRRRRRR", preload("res://Sprites/Spells/R.png"), preload("res://Spells/AlveolarTrill.tscn"))
	register_spell(1, "fireball", "Fireball", "Like an ice ball, but made of fire", preload("res://Sprites/Spells/Fireball.png"), preload("res://Spells/Fireball.tscn"))
	register_spell(1, "iceball", "Iceball", "Like a fire ball, but made of ice", preload("res://Sprites/Spells/Iceball.png"), preload("res://Spells/Iceball.tscn"))
	register_spell(3, "palejoy", "Pale Joy", "I assure you, it's essential", preload("res://Sprites/Spells/PaleJoy.png"), preload("res://Spells/PaleJoy.tscn"))
	
	# If the player is in the tree, set the Player variable of this node to it
	if not get_tree().get_nodes_in_group("Player").empty():
		Player = get_tree().get_nodes_in_group("Player")[0]
	var selected_wand := 0
	player_health = Flesh.new()

	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()

var simplex_noise := OpenSimplexNoise.new()

func _process(delta):
	# Fullscreen
	if Input.is_action_just_pressed("ui_end"):
		OS.window_fullscreen = !OS.window_fullscreen
		OS.window_borderless = OS.window_fullscreen
	
	# Manage spell casts
	for wand in player_wands:
		if wand is Wand:
			# If the wand is being used
			if wand.running:
				# It can't cast if it's on cooldown
				if can_cast:
					can_cast = false
					if wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null:
						var spell :Node2D = wand.spells[wand.current_spell].entity.instance()
						spell.Caster = Player
						spell.goal = Player.get_local_mouse_position() + Player.position
						Player.get_parent().add_child(spell)
				# Cast cooldown
				if (wand.current_spell >= wand.spell_capacity-1 or wand.spells[wand.current_spell] == null) and wand.recharge >= wand.full_recharge:
					wand.recharge = 0.0
					wand.running = false
					can_cast = true
					wand.current_spell = 0
				# Recharge
				elif wand.recharge >= wand.spell_recharge and (wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null):
					wand.recharge = 0.0
					wand.current_spell += 1
					can_cast = true
				else:
					wand.recharge += delta
			else: # If the wand isn't being cast
				wand.current_spell = 0


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


func pick_random_spell(rng:RandomNumberGenerator = LootRNG) -> Spell:
	var random := rng.randf()
	var tier := 1
	if random < 0.68:
		tier = 1
	elif random < 0.9:
		tier = 2
	elif random < 0.998:
		tier = 3
	elif random < 1.0:
		tier = 4
	if spells[tier].empty():
		return pick_random_spell(rng)
	return spells[tier].values()[rng.randi()%spells[tier].values().size()]


func pick_random_item(rng:RandomNumberGenerator = LootRNG) -> Item:
	var random := rng.randf()
	var tier := 1
	if random < 0.68:
		tier = 1
	elif random < 0.9:
		tier = 2
	elif random < 0.998:
		tier = 3
	elif random < 1.0:
		tier = 4
	if items[tier].empty():
		return pick_random_item(rng)
	return items[tier].values()[rng.randi()%items[tier].values().size()]


func reset_player():
	last_pickup = null
	level = 1
	var generator_seed := hash(OS.get_time())
	print(Items.custom_seed)
	if Items.custom_seed != 0:
		generator_seed = custom_seed
	else:
		generator_seed = randi()
	print("Generator seed: ", generator_seed)
	WorldRNG = RandomNumberGenerator.new()
	WorldRNG.seed = generator_seed
	LootRNG = RandomNumberGenerator.new()
	LootRNG.seed = generator_seed*2
	player_health = Flesh.new()
	cloth_scraps = 3
	player_items = []
	player_spells = [null,null,null,null,null,null]
	player_wands = [null,null,null,null,null,null]
	player_wands[0] = Wand.new()
	player_wands[1] = Wand.new()


func shuffle_array(array: Array) -> Array:
	var r := []
	var n := []
	while r.size() != array.size():
		var i := WorldRNG.randi()%array.size()
		if not i in n:
			n.append(i)
			r.append(array[i])
	return r
