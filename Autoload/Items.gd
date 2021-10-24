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
const CHANCE_TIER2 := 0.19
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
	register_item(2, ".9", "Point Nine", "Displays the current state of the bearer's body.", preload("res://Sprites/Items/pointnine.png"))
	register_item(1, "gluestone", "Gluestone", "Small entity that tries to act as a shield.", preload("res://Sprites/Items/Gluestone.png"))
	register_item(3, "egg", "Magic Egg", "If it hatches, it will summon a surprise.", preload("res://Sprites/Items/Egg.png"))
	register_item(3, "shance", "Second Chance", "You have a chance of coming back to life.", preload("res://Sprites/Items/SecondChance.png"))
	register_item(3, "suarantee", "Second Guarantee", "You have a guarantee of coming back to life.", preload("res://Sprites/Items/SecondGuarantee.png"))
	register_item(2, "legs", "Pocket Leg", "Throw the old one away.", preload("res://Sprites/Items/PocketLegs.png"))
	
	register_spell(4, "fuckyou", "Fuck You", "Fuck everything in that particular direction", preload("res://Sprites/Spells/FuckYou.png"), preload("res://Spells/FuckYou.tscn"))
	register_spell(2, "evilsight", "Evil Eye", "Look at things so fiercely you tear them apart", preload("res://Sprites/Spells/EvilEye.png"), preload("res://Spells/EvilSight.tscn"))
	register_spell(1, "shatter", "Unstable Shattering", "Summon orbs that vibrate in frequencies that disturb souls", preload("res://Sprites/Spells/Unstable.png"), preload("res://Spells/ShatteringOrb.tscn"))
	register_spell(1, "ray", "Generic Ray", "Pew pew!", preload("res://Sprites/Spells/Ray.png"), preload("res://Spells/Ray.tscn"))
	register_spell(4, "push", "Push", "Away, away...", preload("res://Sprites/Spells/Push.png"), preload("res://Spells/Push.tscn"))
	register_spell(4, "pull", "Pull", "Together, together...", preload("res://Sprites/Spells/Pull.png"), preload("res://Spells/Pull.tscn"))
	register_spell(3, "r", "Alveolar Trill", "RRRRRRRRRRRRRRRR", preload("res://Sprites/Spells/R.png"), preload("res://Spells/AlveolarTrill.tscn"))
	register_spell(1, "fireball", "Fireball", "Like an ice ball, but made of fire", preload("res://Sprites/Spells/Fireball.png"), preload("res://Spells/Fireball.tscn"))
	register_spell(1, "iceball", "Iceball", "Like a fire ball, but made of ice", preload("res://Sprites/Spells/Iceball.png"), preload("res://Spells/Iceball.tscn"))
	register_spell(3, "palejoy", "Pale Joy", "I assure you, it's essential", preload("res://Sprites/Spells/PaleJoy.png"), preload("res://Spells/PaleJoy.tscn"))
	register_spell(2, "xblast", "Crossblast", "Summons a small X-shaped explosion", preload("res://Sprites/Spells/CrossBlast.png"), preload("res://Spells/CrossBlast.tscn"))
	register_spell(1, "bouncysoul", "Ball Of Soul", "Creates a ball of soul that bounces on every surface", preload("res://Sprites/Spells/BouncySoul.png"), preload("res://Spells/BouncySoul.tscn"))
	register_spell(2, "souleater", "Soul Eater", "If it hits something with soul, it steals it for you, hurts you otherwise", preload("res://Sprites/Spells/SoulEater.png"), preload("res://Spells/SoulEater.tscn"))
	register_spell(2, "bouncyray", "Bouncing Lightray", "Casts a ray of magical light that bounces through the room", preload("res://Sprites/Spells/BouncyRay.png"), preload("res://Spells/BouncyRay.tscn"))
	register_spell(1, "spinsword", "Haunted Sword", "Summons a sword that cuts everything around you", preload("res://Sprites/Spells/SpinSword.png"), preload("res://Spells/SpinSword.tscn"))
	register_spell(1, "windsetter", "Windsetter", "Summons a gust of wind", preload("res://Sprites/Spells/Windsetter.png"), preload("res://Spells/Windsetter.tscn"))
	register_spell(3, "westdragon", "Dragon Of The West", "They call him that for a reason.", preload("res://Sprites/Spells/WestDragon.png"), preload("res://Spells/WestDragon.tscn"))
	register_spell(3, "lightning", "Lightning", "Uncontrollable wrath.", preload("res://Sprites/Spells/Lightning.png"), preload("res://Spells/Lightning.tscn"))
	register_spell(3, "relocator", "Relocator", "Relocates your body.", preload("res://Sprites/Spells/Teleport.png"), preload("res://Spells/TeleportWand.tscn"))
	register_spell(3, "eidosanchor", "Eidos Anchor", "First cast stores, second cast recalls.", preload("res://Sprites/Spells/Return.png"), preload("res://Spells/Return.tscn"))
	register_spell(2, "soulwave", "Soul Wave", "Hurts things in a expanding radius.", preload("res://Sprites/Spells/SoulWave.png"), preload("res://Spells/SoulWave.tscn"))
	register_spell(3, "internalrage", "Internal Rage", "Coming for you.", preload("res://Sprites/Spells/InternalRage.png"), preload("res://Spells/InternalRage.tscn"))
	register_spell(2, "rage", "Rage", "Fireball summoned from anger.", preload("res://Sprites/Spells/Rage.png"), preload("res://Spells/Rage.tscn"))
	register_spell(5, "fuckeverything", "Fuck Everything", "Fuck all of you.", preload("res://Sprites/Spells/FuckEverything.png"), preload("res://Spells/FuckEverything.tscn"))
	register_spell(5, "castlight", "Casting Light", "The next casts will appear halfway through this ray", preload("res://Sprites/Spells/CastingRay.png"), preload("res://Spells/CastingLight.tscn"))
	register_spell(1, "plasmasprinkler", "Plasma Sprinkler", "Balls of heat ejected from a single point", preload("res://Sprites/Spells/PlasmaSprinkler.png"), preload("res://Spells/PlasmaSprinkler.tscn"))
	register_spell(1, "shortray", "Short Ray", "A shortlived ray with a chance of piercing", preload("res://Sprites/Spells/Shortray.png"), preload("res://Spells/Shortray.tscn"))
	
	register_base_mod("multiplicative", "Multiplicative Cast", "Many from alterations of one\nIterations: ", preload("res://Sprites/Spells/Modifiers/Multiplicative.png"))
	register_base_mod("unifying", "Unifying Cast", "One from alterations of many\nAmalgamations: ", preload("res://Sprites/Spells/Modifiers/UnifyingM.png"))
	register_base_mod("grenade", "Grenade Cast", "Copies spells into a grenade wand\nCopied Spells: ", preload("res://Sprites/Spells/Modifiers/Grenade.png"))
	register_base_mod("landmine", "Landmine Cast", "Copies spells into a landmine wand\nCopied Spells: ", preload("res://Sprites/Spells/Modifiers/Landmine.png"))
	
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
					wand.current_spell += cast_spell(wand, caster)
				# Cast cooldown
				if (wand.current_spell >= wand.spell_capacity-1 or wand.spells[wand.current_spell] == null) and wand.recharge >= wand.full_recharge:
					wand.recharge = 0.0
					wand.can_cast = true
					wand.current_spell = 0
					wand.unrun()
					running_wands.erase(run)
					continue
				# Recharge
				elif wand.recharge >= wand.spell_recharge and (wand.current_spell < wand.spell_capacity and wand.spells[wand.current_spell] != null):
					wand.recharge = 0.0
					wand.current_spell += 1
					wand.can_cast = true
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


func register_base_mod(name_id:String, name:String, desc:String, texture:Texture) -> void:
	var mod := SpellMod.new()
	mod.id = name_id
	mod.name = name
	mod.description = desc
	mod.texture = texture
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
	match rng.randi()%4:
		0:
			mod.level = 2 + rng.randi() % 4
			mod.id = "multiplicative"
			mod.name = "Multiplicative Cast"
			mod.description = "Many from alterations of one\nIterations: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/Multiplicative.png")
		1:
			mod.level = 2 + rng.randi() % 4
			mod.id = "unifying"
			mod.name = "Unifying Cast"
			mod.description = "One from alterations of many\nAmalgamations: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/UnifyingM.png")
		2:
			mod.level = 1 + rng.randi() % 5
			mod.id = "grenade"
			mod.name = "Grenade Cast"
			mod.description = "Copies spells into a grenade wand\nCopied Spells: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/Grenade.png")
		3:
			mod.level = 1 + rng.randi() % 5
			mod.id = "landmine"
			mod.name = "Landmine Cast"
			mod.description = "Copies spells into a landmine wand\nCopied Spells: " + str(mod.level)
			mod.texture = preload("res://Sprites/Spells/Modifiers/Landmine.png")
	spell_mods.append(mod)
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


func cast_spell(wand:Wand, caster:Node2D, slot_offset := 0, goal_offset := Vector2(0, 0)):
	var away := 0
	if wand.current_spell+slot_offset < wand.spell_capacity and wand.spells[wand.current_spell+slot_offset] != null:
		var c_spell :Spell = wand.spells[wand.current_spell+slot_offset] 
		if not c_spell is SpellMod:
			var spell :Node2D = wand.spells[wand.current_spell+slot_offset].entity.instance()
			spell.CastInfo.Caster = caster
			spell.CastInfo.goal = caster.looking_at()
			spell.CastInfo.goal_offset = goal_offset
			spell.CastInfo.wand = wand
			caster.get_parent().add_child(spell)
		elif wand.current_spell + slot_offset + 1 < wand.spell_capacity and wand.spells[wand.current_spell+slot_offset+1] != null:
			match c_spell.id:
				"multiplicative":
					away += 1
					for i in c_spell.level:
						if slot_offset + 1 >= wand.spell_capacity:
							break
						var offset :Vector2 = (caster.looking_at()-caster.position).rotated(-2+randf()*4)
						if i == 0:
							offset *= 0
						away = max(cast_spell(wand, caster, slot_offset + 1, offset), away)
				"unifying":
					away += c_spell.level
					for i in c_spell.level:
						if i + slot_offset + 1 >= wand.spell_capacity:
							break
						away = max(cast_spell(wand, caster, slot_offset + i + 1, goal_offset), away)
				"grenade":
					away += c_spell.level
					var spell :Node2D = preload("res://Spells/CastGrenade.tscn").instance()
					spell.CastInfo.Caster = caster
					spell.CastInfo.goal = caster.looking_at()
					spell.CastInfo.goal_offset = goal_offset
					spell.wand = wand.duplicate()
					var spells_to_cast := []
					for i in c_spell.level:
						if wand.current_spell+slot_offset+1+i >= wand.spell_capacity:
							break
						spells_to_cast.append(wand.spells[wand.current_spell+slot_offset+1+i])
					spell.wand.spells = spells_to_cast
					spell.wand.spell_capacity = c_spell.level
					caster.get_parent().add_child(spell)
				"landmine":
					away += c_spell.level
					var spell :Node2D = preload("res://Spells/CastLandmine.tscn").instance()
					spell.CastInfo.Caster = caster
					spell.CastInfo.goal = caster.looking_at()
					spell.CastInfo.goal_offset = goal_offset
					spell.wand = wand.duplicate()
					var spells_to_cast := []
					for i in c_spell.level:
						if wand.current_spell+slot_offset+1+i >= wand.spell_capacity:
							break
						spells_to_cast.append(wand.spells[wand.current_spell+slot_offset+1+i])
					spell.wand.spells = spells_to_cast
					spell.wand.spell_capacity = c_spell.level
					caster.get_parent().add_child(spell)
					
	return away + slot_offset


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
