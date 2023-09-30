extends Reference


class_name SpellModifierApplier

var modifiers := []

var applied_to :Node
var collision_manager :Node
var spellcastinfo: SpellCastInfo

var max_bounces :int
var max_distance: float
var max_requests :int

var speed_multiplier :float
var velocity :Vector2
var gravity :float

var ortho: bool


func apply_mods():
	for mod in modifiers:
		match mod:
			"limited":
				velocity = Vector2.ZERO
				max_requests = 1
			"acceleration":
				speed_multiplier *= 1.1
				if velocity.length() < 0.01:
					velocity = (spellcastinfo.goal - applied_to.position).normalized() * 10
			"impulse":
				if velocity.length() < 0.01:
					velocity = (spellcastinfo.goal - applied_to.position).normalized() * 200
			"orthogonal":
				ortho = true
			"soul_wave_collider":
				if not collision_manager:
					continue
				var spell_spawner := SpellSpawner.new()
				spell_spawner.spell = preload("res://Spells/SoulWave.tscn")
				spell_spawner.amount = 1
				spell_spawner.use_spell_as_caster = true
				collision_manager.connect("collision_happened", spell_spawner, "_on_collision_happened")
				applied_to.add_child(spell_spawner)
				
			"explosion_collider":
				if not collision_manager:
					continue
				var spell_spawner := ExplodeOnCollide.new()
				collision_manager.connect("collision_happened", spell_spawner, "_on_collision_happened")
				applied_to.add_child(spell_spawner)
			"bouncy":
				max_bounces = 16
				max_requests = -1
				if spellcastinfo.modifiers.has("up_gravity") or spellcastinfo.modifiers.has("down_gravity") and max_distance > 0:
					velocity = velocity.normalized() * max_distance * 10
					max_distance = -1
			"down_gravity":
				if velocity.length() > 800:
					gravity = velocity.length() * 20
				else:
					gravity = 500
			"up_gravity":
				if velocity.length() > 800:
					gravity = -velocity.length() * 20
				else:
					gravity = -500
