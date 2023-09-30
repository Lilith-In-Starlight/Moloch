extends Node2D

var did := false

var world_areas := []
var player_in_area := 0

func _ready() -> void:
	world_areas.append(Rect2(Vector2(-3, -8) * Rooms.tile_size * 8, Vector2(7, 9) * Rooms.tile_size * 8))
	
	if randi() % 3112 == 31:
		world_areas.append(Rect2(Vector2(-2002 - randi() % 31, randi() % 2002) * Rooms.tile_size * 8, Vector2(7, 8) * Rooms.tile_size * 8))
	
	
	for i in Items.player_wands:
		if i == null: continue
		i.connect("casting_spell", self, "_on_casting_spell")
	


func _on_casting_spell(spell: Spell, wand: Wand, caster: Node2D, offset: float = 0.0):
	if !spell.is_cast_mod:
		if is_instance_valid(caster):
			var spell_instance = spell.entity.instance()
			spell_instance.CastInfo.Caster = caster
			spell_instance.CastInfo.goal_offset = Vector2(-offset + randf()*offset*2, -offset + randf()*offset*2) * 50
			spell_instance.CastInfo.goal = caster.looking_at()
			spell_instance.CastInfo.wand = wand
			spell_instance.CastInfo.modifiers = spell.behavior_modifiers
			spell_instance.CastInfo.spell = spell
			add_child(spell_instance)
		
		return
	
	for i in spell.input_contents:
		i.behavior_modifiers.append_array(spell.behavior_modifiers.duplicate())
		var counts := {}
		for j in i.behavior_modifiers:
			if counts.has(j):
				counts[j] += 1
			else:
				counts[j] = 1
			if counts[j] == 2:
				counts[j] = 0
				i.behavior_modifiers.erase(j)
				i.behavior_modifiers.erase(j)
	match spell.id:
		"multiply":
			_on_casting_spell(spell.input_contents[0], wand, caster, 0)
			for i in spell.level - 1:
				_on_casting_spell(spell.input_contents[0], wand, caster, offset - 2 + randf()*2)
		"unify":
			_on_casting_spell(spell.input_contents[0], wand, caster)
			_on_casting_spell(spell.input_contents[1], wand, caster)
		"cast_collider":
			spell.input_contents[0].behavior_modifiers.append(["cast_collider", spell.input_contents[1]])
			_on_casting_spell(spell.input_contents[0], wand, caster)
			_on_casting_spell(spell.input_contents[1], wand, caster)


func _process(delta: float) -> void:
	if !did:
		$World.ready()
	did = true
	if Items.selected_wand >= Items.player_wands.size():
		Items.selected_wand = Items.player_wands.size() - 1
	if Items.selected_wand < 0:
		Items.selected_wand = 0
	
	var player_tile :Vector2 = $World.get_round_point_to_tile($Player.position.snapped(Vector2(8, 8)) / 8)
	for x in range(-2, 2):
		for y in range(-2, 2):
			var tile := player_tile + Vector2(x, y)
			if not $World.world_tile_instances.has(tile):
				var new_tile = preload("res://Rooms/Sacrifice/Empty_room.tscn").instance()
				new_tile.position = tile * Rooms.tile_size * 8
				new_tile.add_to_group("WorldPiece")
				$World.world_tile_instances[tile] = new_tile
				$World.add_child(new_tile)
	
	var index := 0
	var previous_area = player_in_area
	player_in_area = -1
	for i in world_areas:
		if i.has_point($Player.position):
			player_in_area = index
		index += 1
	if player_in_area != previous_area:
		if player_in_area == -1:
			if previous_area == 0:
				$Player.send_message("Leving This World")
		else:
			if player_in_area == 0:
				$Player.send_message("Entering World")
			elif Time.get_datetime_dict_from_system()["month"] == 12 and Time.get_time()["day"] == 31:
				$Player.send_message("Entered godiscryinggodiscryinggodiscryinggodisc")
			else:
				$Player.send_message("Entered 20797468736321816615543854419")
