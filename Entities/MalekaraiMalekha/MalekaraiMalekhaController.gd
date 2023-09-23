extends EntityController

class_name MalekaraiMalekhaController

enum AI_STATES {
	player_outside,
	prep_time,
	sans_attack,
	generate_next_attack,
	center_attack,
	side_attack,
}

enum WAND_MODES {
	surround_rotate,
	point,
	surround_point
}

onready var player :PlayerCharacter = get_tree().get_nodes_in_group("Player")[0]
onready var map = get_tree().get_nodes_in_group("World")[0]

var boss_arena_y_start := -268 - 32
var ai_mode :int = AI_STATES.player_outside
var previous_state :int = AI_STATES.player_outside

var spellcast_mode :int = WAND_MODES.surround_rotate
var point_at := Vector2()
var spin_counter_clockwise := false

var offset := 0.0


func _physics_process(delta: float) -> void:
	offset += delta
	pressed_inputs.action1 = false
	match ai_mode:
		AI_STATES.player_outside:
			spellcast_mode = WAND_MODES.surround_rotate
			if player.position.y < boss_arena_y_start:
				ai_mode = AI_STATES.prep_time
				for x in range(22, 44):
					for y in range(-36, -33):
						map.set_tiles_cellv(Vector2(x, y), 2)
		AI_STATES.prep_time:
			spellcast_mode = WAND_MODES.point
			point_at = Vector2.LEFT * 100.0
			get_tree().create_timer(1.0).connect("timeout", self, "_on_given_prep_time")
		AI_STATES.sans_attack:
			pressed_inputs.action1 = true
			point_at = point_at.rotated(PI/9 * delta)
			get_tree().create_timer(1.0).connect("timeout", self, "_on_got_dunked_on")
		AI_STATES.generate_next_attack:
			get_tree().create_timer(1.0).connect("timeout", self, "_on_select_attack")
		AI_STATES.center_attack:
			get_parent().position = lerp(get_parent().position, Vector2(263.5, -268 - 134) + Vector2(sin(offset), cos(offset)) * 20.0, 0.05)
			pressed_inputs.action1 = true
			
			if previous_state != ai_mode:
				spellcast_mode = WAND_MODES.surround_rotate
				get_tree().create_timer(1.0).connect("timeout", self, "_random_switch_wand")
		AI_STATES.side_attack:
			get_parent().position = lerp(get_parent().position, Vector2(263.5, -268 - 134) + Vector2(sin(offset), cos(offset)) * 20.0, 0.05)
			pressed_inputs.action1 = true
			
			if previous_state != ai_mode:
				spellcast_mode = WAND_MODES.surround_rotate
				get_tree().create_timer(1.0).connect("timeout", self, "_random_switch_wand")
	previous_state = ai_mode

func _on_given_prep_time() -> void:
	ai_mode = AI_STATES.sans_attack

func _on_got_dunked_on() -> void:
	ai_mode = AI_STATES.generate_next_attack

func _on_select_attack() -> void:
	point_at = Vector2(-100, 0)
	get_parent().spellcast_focus = 0.0
	ai_mode = AI_STATES.center_attack

func _random_switch_wand() -> void:
	get_parent().spellcast_focus = randi()%4
	get_tree().create_timer(1.0).connect("timeout", self, "_random_switch_wand")


func _on_attack_finished() -> void:
	ai_mode = AI_STATES.generate_next_attack
