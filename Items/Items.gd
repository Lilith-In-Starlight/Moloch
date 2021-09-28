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

const CHANCE_TIER1 := 0.78
const CHANCE_TIER2 := 0.18
const CHANCE_TIER3 := 0.038
const CHANCE_TIER4 := 0.002

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
	register_item(1, "icecube", "Ice Cube", "Lowers your temperature a bit", preload("res://Sprites/Items/IceCube.png"))
	register_item(3, "dissipator", "Black Body Radiation", "Your body temperature lowers slightly faster", preload("res://Sprites/Items/DissipateHeat.png"))
	register_item(2, "heatadapt", "Heat Adaptation", "You become able to stand slightly greater temperatures", preload("res://Sprites/Items/SurviveHeat.png"))
	
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
	register_spell(3, "xblast", "Crossblast", "Summons a small X-shaped explosion", preload("res://Sprites/Spells/CrossBlast.png"), preload("res://Spells/CrossBlast.tscn"))
	register_spell(1, "bouncysoul", "Ball Of Soul", "Creates a ball of soul that bounces on every surface", preload("res://Sprites/Spells/BouncySoul.png"), preload("res://Spells/BouncySoul.tscn"))
	register_spell(2, "souleater", "Soul Eater", "If it hits something with soul, it steals it for you, hurts you otherwise", preload("res://Sprites/Spells/SoulEater.png"), preload("res://Spells/SoulEater.tscn"))
	
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
					wand.current_spell += cast_spell(wand)
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
	var random := rng.randf()*(CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3 + CHANCE_TIER4)
	var tier := 1
	if random < CHANCE_TIER1:
		tier = 1
	elif random < CHANCE_TIER1 + CHANCE_TIER2:
		tier = 2
	elif random < CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3:
		tier = 3
	elif random < CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3 + CHANCE_TIER4:
		tier = 4
	if spells[tier].empty():
		return pick_random_spell(rng)
	return spells[tier].values()[rng.randi()%spells[tier].values().size()]


func pick_random_item(rng:RandomNumberGenerator = LootRNG) -> Item:
	var random := rng.randf()*(CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3 + CHANCE_TIER4)
	var tier := 1
	if random < CHANCE_TIER1:
		tier = 1
	elif random < CHANCE_TIER1 + CHANCE_TIER2:
		tier = 2
	elif random < CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3:
		tier = 3
	elif random < CHANCE_TIER1 + CHANCE_TIER2 + CHANCE_TIER3 + CHANCE_TIER4:
		tier = 4
	if items[tier].empty():
		return pick_random_item(rng)
	return items[tier].values()[rng.randi()%items[tier].values().size()]


func pick_random_modifier(rng:RandomNumberGenerator = LootRNG) -> SpellMod:
	var mod := SpellMod.new()
	match rng.randi()%2:
		1:
			mod.level = 1 + rng.randi() % 5
			mod.id = "multiplicative"
			mod.name = "Multiplicative Cast"
			mod.description = "Many from alterations of one\nIterations: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/Multiplicative.png")
		2:
			mod.level = 1 + rng.randi() % 5
			mod.id = "unifying"
			mod.name = "Unifying Cast"
			mod.description = "One from alterations of many\nAmalgamations: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/UnifyingM.png")
	return mod


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
	if LootRNG.randf() < 0.25:
		player_spells[0] = pick_random_modifier()
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


func cast_spell(wand:Wand, slot_offset := 0, goal_offset := Vector2(0, 0)):
	var away := 0
	if wand.current_spell+slot_offset < wand.spell_capacity and wand.spells[wand.current_spell+slot_offset] != null:
		var c_spell :Spell = wand.spells[wand.current_spell+slot_offset] 
		if not c_spell is SpellMod:
			var spell :Node2D = wand.spells[wand.current_spell+slot_offset].entity.instance()
			spell.CastInfo.Caster = Player
			spell.CastInfo.goal = Player.looking_at()
			spell.CastInfo.goal_offset = goal_offset
			Player.get_parent().add_child(spell)
		elif wand.current_spell + slot_offset + 1 < wand.spell_capacity and wand.spells[wand.current_spell+slot_offset+1] != null:
			match c_spell.id:
				"multiplicative":
					away += 1
					for i in c_spell.level:
						var offset :Vector2 = (Player.looking_at()-Player.position).rotated(-2+randf()*4)
						if i == 0:
							offset *= 0
						away = max(cast_spell(wand, slot_offset + 1, offset), away)
				"unifying":
					away += c_spell.level
					for i in c_spell.level:
						away = max(cast_spell(wand, slot_offset + i + 1, goal_offset), away)
	return away + slot_offset
