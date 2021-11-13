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

var player_items := []

var player_spells := [null,null,null,null,null,null]
var player_wands := [null,null,null,null,null,null]
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
	register_item(1, "scraps", "Cloth Scraps", "Seal your wounds, somewhat", preload("res://Sprites/Items/Scraps.png"))
	register_item(1, "soulfulpill", "Soulful Pill", "Heals the mind and soul", preload("res://Sprites/Items/SoulfulPill.png"))
	register_item(2, "monocle", "Pig's Monocle", "See all the shinies", preload("res://Sprites/Items/PigsMonocle.png"))
	register_item(2, "bandaid", "Band-aid", "Bleeding has more chances to stop on its own", preload("res://Sprites/Items/Bandaid.png"))
	register_item(1, "icecube", "Ice Cube", "Lowers your temperature", preload("res://Sprites/Items/IceCube.png"))
	register_item(3, "dissipator", "Black Body Radiation", "Emit your body heat as radiation", preload("res://Sprites/Items/DissipateHeat.png"))
	register_item(2, "heatadapt", "Heat Adaptation", "Adapt to greater temperatures", preload("res://Sprites/Items/SurviveHeat.png"))
	register_item(2, ".9", "Point Nine", "Displays the current state of the bearer's body", preload("res://Sprites/Items/pointnine.png"))
	register_item(1, "gluestone", "Gluestone", "Small entity that tries to act as a shield", preload("res://Sprites/Items/Gluestone.png"))
	register_item(3, "egg", "Magic Egg", "If it hatches, it will summon a surprise", preload("res://Sprites/Items/Egg.png"))
	register_item(3, "shance", "Second Chance", "Provides a chance of being revived", preload("res://Sprites/Items/SecondChance.png"))
	register_item(3, "suarantee", "Second Guarantee", "Provides a guarantee of being revived", preload("res://Sprites/Items/SecondGuarantee.png"))
	register_item(2, "legs", "Pocket Leg", "Put these on if you lose the old ones", preload("res://Sprites/Items/PocketLegs.png"))
	register_item(3, "bloodless", "Bloodless", "Blood Unnecessary", preload("res://Sprites/Items/Bloodless.png"))
	register_item(4, "soulfulengine", "Soulful Engine", "Passive Soul Generation", preload("res://Sprites/Items/SoulfulEngine.png"))
	
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
	register_spell(2, "souleater", "Soul Eater", "If it hits something with soul, it steals it for you, hurts you otherwise", preload("res://Sprites/Spells/SoulEater.png"), preload("res://Spells/SoulEater.tscn"))
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
	
	register_base_mod("multiplicative", "Multiplicative Cast", "Many casts from one\nIterations: %s", preload("res://Sprites/Spells/Modifiers/Multiplicative.png"), [2, 6])
	register_base_mod("unifying", "Unifying Cast", "One cast from many\nAmalgamations: %s", preload("res://Sprites/Spells/Modifiers/UnifyingM.png"), [2, 6])
	register_base_mod("grenade", "Grenade Cast", "Copies spells into a grenade wand\nCopied Spells: %s", preload("res://Sprites/Spells/Modifiers/Grenade.png"), [1, 6])
	register_base_mod("landmine", "Landmine Cast", "Copies spells into a landmine wand\nCopied Spells: %s", preload("res://Sprites/Spells/Modifiers/Landmine.png"), [1, 6])
	register_base_mod("limited", "Limited Cast", "When applicable, casts will only have effect at the end of the wand", preload("res://Sprites/Spells/Modifiers/Limited.png"), [1, 1])
	register_base_mod("faster", "Faster Cast", "The following spells will be cast %s times faster", preload("res://Sprites/Spells/Modifiers/Faster.png"), [2, 6])
	register_base_mod("slower", "Slower Cast", "The following spells will be cast %s times slower", preload("res://Sprites/Spells/Modifiers/Slower.png"), [2, 6])
	register_base_mod("fasterw", "Faster Recharge Time", "The wand will recharge %s times faster", preload("res://Sprites/Spells/Modifiers/FastWand.png"), [2, 6])
	
	# If the player is in the tree, set the Player variable of this node to it
	if not get_tree().get_nodes_in_group("Player").empty():
		Player = get_tree().get_nodes_in_group("Player")[0]
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
	for run in running_wands.duplicate():
		var wand :Wand = run[0]
		var caster :Node2D = run[1]
		var spell_cooldown_time :float = run[2]
		var usage_cooldown_time :float = run[3]
		var last_spell_to_cast :float = run[4] - 1 # The wand gives position
		#											 starting from 1, not 0
		
		# Stop casting the wand if the entity that was casting it stops
		# existing
		if not is_instance_valid(caster):
			wand.unrun()
			running_wands.erase(run)
			continue
		if wand is Wand:
			# If the wand is being used
			if wand.running:
				# It can't cast if it's on cooldown
				if wand.can_cast:
					wand.can_cast = false
					var cast_result := cast_spell(wand, caster)
					wand.current_spell += cast_result[0]
					run[2] *= cast_result[1]
					spell_cooldown_time = run[2]
				
				# Usage coolodown happens if the wandr eaches the last spell
				# that it can execute, the last spell on the wand, or if
				# the current spell is null
				if (wand.current_spell >= wand.spell_capacity - 1 or wand.spells[wand.current_spell] == null) and wand.recharge >= usage_cooldown_time:
					wand.recharge = 0.0
					wand.can_cast = true
					wand.current_spell = 0
					wand.unrun()
					running_wands.erase(run)
					continue
				
				# Spell cooldown happens in cases opposite to the previous ones
				# aditionally, this is executed instantly if this is the last
				# spell that will be cast, so that there's no extra delay
				elif (wand.recharge >= spell_cooldown_time or wand.current_spell >= last_spell_to_cast) and (wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null):
					wand.recharge = 0.0
					wand.current_spell += 1
					wand.can_cast = true
				
				# If neither of this is the case, the timer just hasn't reached any
				else:
					wand.recharge += delta
			else: # If the wand isn't being cast
				wand.unrun()
				wand.current_spell = 0
				running_wands.erase(run)
				continue


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
	spells[tier][name_id] = new
	all_spells[name_id] = new


func register_base_mod(name_id:String, name:String, desc:String, texture:Texture, level_range := [1, 6]) -> void:
	var mod := SpellMod.new()
	mod.id = name_id
	mod.name = name
	mod.description = desc
	mod.texture = texture
	mod.minimum_level = level_range[0]
	mod.maximum_level = level_range[1]
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


func pick_random_modifier(rng:RandomNumberGenerator = LootRNG) -> SpellMod:
	var mod := SpellMod.new()
	var mod_templade :SpellMod = base_spell_mods.values()[rng.randi() % base_spell_mods.size()]
	mod.id = mod_templade.id
	mod.name = mod_templade.name
	mod.description = mod_templade.description
	mod.texture = mod_templade.texture
	mod.level = rng.randi_range(mod_templade.minimum_level, mod_templade.maximum_level)
	
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
	player_items = []
	player_spells = [null,null,null,null,null,null]
	if LootRNG.randf() < 0.2:
		player_spells[0] = pick_random_modifier()
	player_wands = [null,null,null,null,null,null]
	player_wands[0] = Wand.new()
	for i in player_wands[0].spells.size():
		player_wands[0].spells[i] = null


func shuffle_array(array: Array) -> Array:
	var r := []
	var n := []
	while r.size() != array.size():
		var i := WorldRNG.randi()%array.size()
		if not i in n:
			n.append(i)
			r.append(array[i])
	return r


func cast_spell(wand:Wand, caster:Node2D, slot_offset := 0, goal_offset := Vector2(0, 0), modifiers := [], cast_speed_mult := 1.0, layer := 0) -> Array:
	# slot_offset is the starting slot for this cast
	# goal_offset is used for messing with the player's aim
	# modifiers are used for things the spells are supposed to react to
	# cast_speed_mult is used for changing the cast speed through modifiers
	# layer is the current layer of recursion
	
	var spells_to_skip := 0
	var new_cast_speed := cast_speed_mult
	var largest_layer := layer
	
	var current_offset_spell := wand.current_spell + slot_offset
	
	if current_offset_spell < wand.spell_capacity and wand.spells[current_offset_spell] != null:
		var c_spell :Spell = wand.spells[current_offset_spell] 
		if not c_spell is SpellMod:
			summon_cast(wand, caster, current_offset_spell, goal_offset, modifiers)
		
		elif current_offset_spell + 1 < wand.spell_capacity and wand.spells[current_offset_spell + 1] != null:
			match c_spell.id:
				"multiplicative":
					spells_to_skip += 1
					for iteration in c_spell.level:
						if slot_offset + 1 >= wand.spell_capacity:
							break
						var offset :Vector2 = (caster.looking_at()-caster.position).rotated(-2+randf()*4)
						if iteration == 0:
							offset *= 0
						var cast := cast_spell(wand, caster, slot_offset + 1, offset, modifiers, cast_speed_mult, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
				
				"unifying":
					spells_to_skip += c_spell.level
					for next_spell in c_spell.level:
						if next_spell + slot_offset + 1 >= wand.spell_capacity:
							break
						var cast := cast_spell(wand, caster, slot_offset + next_spell + 1, goal_offset, modifiers, cast_speed_mult, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
				
				"grenade":
					spells_to_skip += c_spell.level
					summon_special_wand(preload("res://Spells/CastGrenade.tscn"), wand, caster, current_offset_spell, goal_offset, modifiers)
				
				"landmine":
					spells_to_skip += c_spell.level
					summon_special_wand(preload("res://Spells/CastLandmine.tscn"), wand, caster, current_offset_spell, goal_offset, modifiers)
				
				"limited":
					spells_to_skip += 1
					if slot_offset + 1 < wand.spell_capacity:
						var cast := cast_spell(wand, caster, slot_offset + 1, Vector2.ZERO, modifiers + ["limited"], cast_speed_mult, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
				
				"faster":
					spells_to_skip += 1
					new_cast_speed = cast_speed_mult / float(c_spell.level)
					if slot_offset + 1 < wand.spell_capacity:
						var cast := cast_spell(wand, caster, slot_offset + 1, Vector2.ZERO, modifiers, new_cast_speed, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
				
				"slower":
					spells_to_skip += 1
					new_cast_speed = cast_speed_mult * float(c_spell.level)
					if slot_offset + 1 < wand.spell_capacity:
						var cast := cast_spell(wand, caster, slot_offset + 1, Vector2.ZERO, modifiers, new_cast_speed, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
				
				_:
					spells_to_skip += 1
					if slot_offset + 1 < wand.spell_capacity:
						var cast := cast_spell(wand, caster, slot_offset + 1, Vector2.ZERO, modifiers, cast_speed_mult, layer + 1)
						spells_to_skip = max(cast[0], spells_to_skip)
						largest_layer = max(layer, cast[2])
	if layer == largest_layer:
		return [spells_to_skip + slot_offset, new_cast_speed, layer]
	
	return [spells_to_skip, new_cast_speed, layer]


func summon_cast(wand:Wand, caster:Node2D, current_offset_spell:int, goal_offset: Vector2, modifiers: Array) -> void:
	var spell :Node2D = wand.spells[current_offset_spell].entity.instance()
	spell.CastInfo.Caster = caster
	spell.CastInfo.goal = caster.looking_at()
	spell.CastInfo.goal_offset = goal_offset
	spell.CastInfo.wand = wand
	spell.CastInfo.modifiers = modifiers
	caster.get_parent().add_child(spell)


func summon_special_wand(special_wand:PackedScene, wand:Wand, caster:Node2D, current_offset_spell:int, goal_offset: Vector2, modifiers: Array) -> void:
	var c_spell :Spell = wand.spells[current_offset_spell] 
	var spells_in_wand := []
	for next_spell in c_spell.level:
		if current_offset_spell + 1 + next_spell >= wand.spell_capacity:
			break
		spells_in_wand.append(wand.spells[current_offset_spell + 1 + next_spell])
	
	var spell :Node2D = special_wand.instance()
	spell.CastInfo.Caster = caster
	spell.CastInfo.goal = caster.looking_at()
	spell.CastInfo.goal_offset = goal_offset
	spell.wand = wand.duplicate()
	spell.wand.spells = spells_in_wand
	spell.wand.spell_capacity = c_spell.level
	caster.get_parent().add_child(spell)


func break_block(block: int, strength: float) -> int:
	match block:
		0:
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
