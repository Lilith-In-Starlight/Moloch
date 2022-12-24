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

const EXPLOSION_SOUNDS := [preload("res://Sfx/explosions/explosion01.wav"), preload("res://Sfx/explosions/explosion02.wav"),preload("res://Sfx/explosions/explosion08.wav")]

const PIERCED_FLESH_SOUNDS := [preload("res://Sfx/pierced_flesh/piercing-1a.wav"), preload("res://Sfx/pierced_flesh/piercing-1b.wav")]

var player_items := {}

var player_spells := []
var player_wands := []
var selected_wand := 0

var Player :KinematicBody2D
var player_health := Flesh.new()

var run_start_time :int

var cloth_scraps := 3

var WorldRNG := RandomNumberGenerator.new()
var LootRNG := RandomNumberGenerator.new()
var custom_seed := 0

var level := 1

var using_seed := 0 # WorldRNG's seed changes, this one doesn't

var last_pickup :Item = null

var running_wands := []

var spell_mods := []

var companions := []

var all_items := {}
var all_spells := {}

var base_spell_mods := {}

var last_items := []
var last_spells := []

func _ready():
	var generator_seed := hash(OS.get_time())
	print("Generator seed: ", generator_seed)
	seed(generator_seed)
	WorldRNG.seed = generator_seed
	# Register items and spells
	register_item(2, "heal", "Growth", "Return the flesh to a state previous", preload("res://Sprites/Items/Heal.png"))
	register_item(1, "ironknees", "Iron Knees", "Fear the ground no more", preload("res://Sprites/Items/IronKnees.png"))
	register_item(1, "thickblood", "Thick Blood", "Higher amounts of blood", preload("res://Sprites/Items/ThickBlood.png"))
	register_item(3, "wings", "Butterfly Wings", "Defy gravitational attraction", preload("res://Sprites/Items/Wings.png"))
	register_item(1, "gasolineblood", "Blood To Nitroglycerine", "Your insides become volatile", preload("res://Sprites/Items/BloodToGasoline.png"))
	register_item(2, "waterblood", "Blood To Water", "Your insides become water", preload("res://Sprites/Items/BloodToWater.png"))
	register_item(1, "scraps", "Cloth Scraps", "Can be used to seal your wounds", preload("res://Sprites/Items/Scraps.png"))
	register_item(1, "soulfulpill", "Soulful Pill", "Heals the mind and soul", preload("res://Sprites/Items/SoulfulPill.png"))
	register_item(2, "monocle", "Pig's Eye", "Become richer", preload("res://Sprites/Items/PigsMonocle.png"))
	register_item(2, "bandaid", "Band-aid", "Bleeding has more chances to stop on its own", preload("res://Sprites/Items/Bandaid.png"))
	register_item(1, "icecube", "Ice Cube", "Lowers your temperature", preload("res://Sprites/Items/IceCube.png"))
	register_item(3, "dissipator", "Black Body Radiation", "Emit your body heat as radiation", preload("res://Sprites/Items/DissipateHeat.png"))
	register_item(2, "heatadapt", "Heat Adaptation", "Adapt to greater temperatures", preload("res://Sprites/Items/SurviveHeat.png"))
	register_item(2, ".9", "Point Nine", "Displays the current state of the bearer's body", preload("res://Sprites/Items/pointnine.png"))
	register_item(1, "gluestone", "Gluestone", "Small entity that tries to act as a shield", preload("res://Sprites/Items/Gluestone.png"))
#	register_item(3, "egg", "Magic Egg", "If it hatches, it will summon a surprise", preload("res://Sprites/Items/Egg.png"))
	register_item(3, "shance", "Second Chance", "Provides a chance of being revived", preload("res://Sprites/Items/SecondChance.png"))
	register_item(3, "suarantee", "Second Guarantee", "Provides a guarantee of being revived", preload("res://Sprites/Items/SecondGuarantee.png"))
	register_item(2, "legs", "Pocket Leg", "Put these on if you lose the old ones", preload("res://Sprites/Items/PocketLegs.png"))
	register_item(3, "bloodless", "Bloodless", "Blood Unnecessary", preload("res://Sprites/Items/Bloodless.png"))
	register_item(4, "soulfulengine", "Soulful Engine", "Passive Soul Generation", preload("res://Sprites/Items/SoulfulEngine.png"))
	register_item(3, "DE4L", "DE4L W1TH THE D3VIL", "IRRESIT1BLE DE4L$ that will FUCK1NG KILL Y0U", preload("res://Sprites/Items/DEAL.png"))
	
	register_spell(4, "fuckyou", "Fuck You", "Fuck everything in that particular direction", preload("res://Sprites/Spells/FuckYou.png"), preload("res://Spells/FuckYou.tscn"))
	register_spell(2, "evilsight", "Evil Eye", "Casts a shortlived ray that tears things apart", preload("res://Sprites/Spells/EvilEye.png"), preload("res://Spells/EvilSight.tscn"))
	register_spell(1, "shatter", "Unstable Shattering", "Summon orbs that vibrate in frequencies that disturb souls", preload("res://Sprites/Spells/Unstable.png"), preload("res://Spells/ShatteringOrb.tscn"))
	register_spell(1, "ray", "Generic Ray", "Pew pew!", preload("res://Sprites/Spells/Ray.png"), preload("res://Spells/Ray.tscn"))
	register_spell(4, "push", "Push", "Away, away...", preload("res://Sprites/Spells/Push.png"), preload("res://Spells/Push.tscn"))
	register_spell(4, "pull", "Pull", "Together, together...", preload("res://Sprites/Spells/Pull.png"), preload("res://Spells/Pull.tscn"))
	register_spell(3, "r", "Alveolar Trill", "RRRRRRRRRRRRRRRR", preload("res://Sprites/Spells/R.png"), preload("res://Spells/AlveolarTrill.tscn"))
	register_spell(1, "fireball", "Fireball", "Like an ice ball, but made of fire", preload("res://Sprites/Spells/Fireball.png"), preload("res://Spells/Fireball.tscn"))
	register_spell(1, "iceball", "Iceball", "Like a fire ball, but made of ice", preload("res://Sprites/Spells/Iceball.png"), preload("res://Spells/Iceball.tscn"))
	register_spell(3, "palejoy", "Pale Joy", "As self destructive as this spell is, I assure you, it's essential", preload("res://Sprites/Spells/PaleJoy.png"), preload("res://Spells/PaleJoy.tscn"))
	register_spell(2, "xblast", "Crossblast", "Summons a small X-shaped explosion", preload("res://Sprites/Spells/CrossBlast.png"), preload("res://Spells/CrossBlast.tscn"))
	register_spell(1, "bouncysoul", "Ball Of Soul", "Creates a ball of soul that bounces on every surface", preload("res://Sprites/Spells/BouncySoul.png"), preload("res://Spells/BouncySoul.tscn"))
	register_spell(3, "souleater", "Soul Eater", "If it hits something with soul, it steals it for you, hurts you otherwise", preload("res://Sprites/Spells/SoulEater.png"), preload("res://Spells/SoulEater.tscn"))
	register_spell(2, "bouncyray", "Bouncing Lightray", "Casts a ray of magical light that bounces through the room", preload("res://Sprites/Spells/BouncyRay.png"), preload("res://Spells/BouncyRay.tscn"))
	register_spell(2, "spinsword", "Haunted Sword", "Summons a sword that cuts everything around you", preload("res://Sprites/Spells/SpinSword.png"), preload("res://Spells/SpinSword.tscn"))
	register_spell(1, "windsetter", "Windsetter", "Summons a gust of wind that pushes you away", preload("res://Sprites/Spells/Windsetter.png"), preload("res://Spells/Windsetter.tscn"))
	register_spell(3, "westdragon", "Dragon Of The West", "They call him that for a reason", preload("res://Sprites/Spells/WestDragon.png"), preload("res://Spells/WestDragon.tscn"))
	register_spell(4, "lightning", "Lightning", "Uncontrollable wrath", preload("res://Sprites/Spells/Lightning.png"), preload("res://Spells/Lightning.tscn"))
	register_spell(3, "relocator", "Relocator", "Relocates your body in a particular place", preload("res://Sprites/Spells/Teleport.png"), preload("res://Spells/TeleportWand.tscn"))
	register_spell(3, "mattereater", "Matter Eater", "Eats the world", preload("res://Sprites/Spells/MatterEater.png"), preload("res://Spells/MatterEater.tscn"))
	register_spell(3, "eidosanchor", "Eidos Anchor", "First cast stores, second cast recalls", preload("res://Sprites/Spells/Return.png"), preload("res://Spells/Return.tscn"))
	register_spell(2, "soulwave", "Soul Wave", "Hurts things in a expanding radius", preload("res://Sprites/Spells/SoulWave.png"), preload("res://Spells/SoulWave.tscn"))
	register_spell(3, "internalrage", "Internal Rage", "Comes towards you from far away", preload("res://Sprites/Spells/InternalRage.png"), preload("res://Spells/InternalRage.tscn"))
	register_spell(2, "rage", "Rage", "Fireball summoned from anger itself", preload("res://Sprites/Spells/Rage.png"), preload("res://Spells/Rage.tscn"))
	register_spell(5, "fuckeverything", "Fuck Everything", "Fuck all of you.", preload("res://Sprites/Spells/FuckEverything.png"), preload("res://Spells/FuckEverything.tscn"))
	register_spell(5, "castlight", "Casting Light", "The next casts will appear halfway through this ray", preload("res://Sprites/Spells/CastingRay.png"), preload("res://Spells/CastingLight.tscn"))
	register_spell(1, "plasmasprinkler", "Plasma Sprinkler", "Balls of heat ejected from a single point", preload("res://Sprites/Spells/PlasmaSprinkler.png"), preload("res://Spells/PlasmaSprinkler.tscn"))
	register_spell(1, "shortray", "Short Ray", "A shortlived ray with a chance of piercing", preload("res://Sprites/Spells/Shortray.png"), preload("res://Spells/Shortray.tscn"))
	
	register_base_mod("multiply", "Multiplicative Cast", "Cast next spell %s times", preload("res://Sprites/Spells/Modifiers/Multiplicative.png"), 1, [2, 6])
	register_base_mod("unify", "Unifying Cast", "Cast the next %s spells at once", preload("res://Sprites/Spells/Modifiers/UnifyingM.png"), 2, [2, 6])
	register_behavior_mod("orthogonal", "Orthogonal Cast", "The next spell only moves orthogonally", preload("res://Sprites/Spells/Modifiers/Orthogonal.png"))
#	register_base_mod("grenade", "Grenade Cast", "Copies spells into a grenade wand\nCopied Spells: %s", preload("res://Sprites/Spells/Modifiers/Grenade.png"), [1, 6])
#	register_base_mod("landmine", "Landmine Cast", "Copies spells into a landmine wand\nCopied Spells: %s", preload("res://Sprites/Spells/Modifiers/Landmine.png"), [1, 6])
#	register_base_mod("limited", "Limited Cast", "When applicable, casts will only have effect at the end of the wand", preload("res://Sprites/Spells/Modifiers/Limited.png"), [1, 1])
	register_wand_mod("fast_cast", "Faster Cast", "The following spells will be cast %s times faster", preload("res://Sprites/Spells/Modifiers/Faster.png"), [2, 6])
	register_wand_mod("slow_cast", "Slower Cast", "The following spells will be cast %s times slower", preload("res://Sprites/Spells/Modifiers/Slower.png"), [2, 6])
	register_wand_mod("fast_recharge", "Faster Recharge Time", "The wand will recharge %s times faster", preload("res://Sprites/Spells/Modifiers/FastWand.png"), [2, 6])
	
	# If the player is in the tree, set the Player variable of this node to it
	if not get_tree().get_nodes_in_group("Player").empty():
		Player = get_tree().get_nodes_in_group("Player")[0]
	player_health = Flesh.new()
	
	player_wands.append(new_player_wand())
	player_wands.append(new_player_wand())

var simplex_noise := OpenSimplexNoise.new()

func _process(delta):
	# Fullscreen
	if Input.is_action_just_pressed("ui_end"):
		OS.window_fullscreen = !OS.window_fullscreen
		OS.window_borderless = OS.window_fullscreen
	


func register_item(tier:int, name_id:String, name:String, desc:String, texture:Texture):
	var new := Item.new()
	new.name = name
	new.description = desc
	new.texture = texture
	new.id = name_id
	items[tier][name_id] = new
	all_items[name_id] = new


func register_spell(tier:int, name_id:String, name:String, desc:String, texture :Texture, entity :PackedScene):
	var new := Spell.new()
	new.name = name
	new.description = desc
	new.id = name_id
	new.texture = texture
	new.entity = entity
	new.tier = tier
	spells[tier][name_id] = new
	all_spells[name_id] = new


func register_base_mod(name_id:String, name:String, desc:String, texture:Texture, inputs:int = 1, level_range := [1, 6]) -> void:
	var mod := Spell.new()
	mod.id = name_id
	mod.name = name
	mod.description = desc
	mod.texture = texture
	mod.minimum_level = level_range[0]
	mod.maximum_level = level_range[1]
	mod.is_cast_mod = true
	mod.inputs = inputs
	base_spell_mods[name_id] = mod


func register_wand_mod(name_id:String, name:String, desc:String, texture:Texture, level_range := [1, 6]) -> void:
	var mod := Spell.new()
	mod.id = name_id
	mod.name = name
	mod.description = desc
	mod.texture = texture
	mod.minimum_level = level_range[0]
	mod.maximum_level = level_range[1]
	mod.is_wand_mod = true
	mod.inputs = 0
	base_spell_mods[name_id] = mod


func register_behavior_mod(name_id:String, name:String, desc:String, texture:Texture) -> void:
	var mod := Spell.new()
	mod.id = name_id
	mod.name = name
	mod.description = desc
	mod.texture = texture
	mod.inputs = 0
	mod.is_behavior_mod = true
	base_spell_mods[name_id] = mod


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
		var ret := pick_random_spell(rng)
		if ret.id in last_spells:
			return pick_random_spell(rng)
		else:
			last_spells.append(ret.id)
			if last_spells.size() > 6:
				last_spells.pop_front()
			return ret
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
		var ret := pick_random_item(rng)
		if ret.id in last_items:
			return pick_random_item(rng)
		else:
			last_items.append(ret.id)
			if last_items.size() > 6:
				last_items.pop_front()
			return ret
	return items[tier].values()[rng.randi()%items[tier].values().size()]


func pick_random_modifier(rng:RandomNumberGenerator = LootRNG) -> Spell:
	var mod :Spell = base_spell_mods.values()[rng.randi() % base_spell_mods.size()].duplicate()
	mod.level = rng.randi_range(mod.minimum_level, mod.maximum_level)

	if "%s" in mod.description:
		mod.description %= str(mod.level)

	spell_mods.append(mod)
	return mod


func reset_player():
	last_items = []
	last_spells = []
	last_pickup = null
	level = 1
	var generator_seed := hash(OS.get_time())
	print(Items.custom_seed)
	if Items.custom_seed != 0:
		generator_seed = custom_seed
	else:
		generator_seed = randi()
	spell_mods = []
	print("Generator seed: ", generator_seed)
	WorldRNG = RandomNumberGenerator.new()
	WorldRNG.seed = generator_seed
	LootRNG = RandomNumberGenerator.new()
	LootRNG.seed = generator_seed*2
	player_health = Flesh.new()
	cloth_scraps = 3
	player_items = {}
	player_spells = []
	if LootRNG.randf() < 0.2:
		player_spells.append(pick_random_modifier())
	for i in player_wands:
		i.queue_free()
	player_wands = []
	player_wands.append(new_player_wand())
	player_wands.append(new_player_wand())


func shuffle_array(array: Array) -> Array:
	var r := []
	var n := []
	while r.size() != array.size():
		var i := WorldRNG.randi()%array.size()
		if not i in n:
			n.append(i)
			r.append(array[i])
	return r


func break_block(block: int, strength: float) -> int:
	match block:
		0, 1:
			if strength > 0.2:
				return -1
	return block


func damage_visuals(entity:Node2D, timer:Timer, damage_type: String) -> void:
	if Config.damage_visuals:
		timer.start()
		match damage_type:
			"hole":
				entity.modulate = Color("#ff0000")
			"heat":
				entity.modulate = ColorN("orange")
			"cold":
				entity.modulate = Color("#00ffff")
			"soul":
				entity.modulate = Color("#00ff80")


func count_player_items(name:String) -> int:
	if name in player_items:
		return player_items[name]
	return 0


func add_item(name:String) -> void:
	if name in player_items:
		player_items[name] += 1
	else:
		player_items[name] = 1


func new_player_wand() -> Wand:
	var new_wand := Wand.new()
	add_child(new_wand)
	return new_wand



func get_player_wand():
	if player_wands.empty():
		return null
	return player_wands[selected_wand]
