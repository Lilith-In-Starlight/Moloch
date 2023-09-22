extends EntityController

class_name MalekaraiMalekhaController

enum AI_STATES {
	player_outside,
	prep_time,
	sans_attack,
	real_fight,
}

enum WAND_MODES {
	surround_rotate,
	point,
	surround_point
}

onready var player :PlayerCharacter = get_tree().get_nodes_in_group("Player")[0]

var boss_arena_y_start := -268 - 32
var ai_mode :int = AI_STATES.player_outside

var spellcast_mode :int = WAND_MODES.surround_rotate
var point_at := Vector2()


func _physics_process(delta: float) -> void:
	pressed_inputs.action1 = false
	match ai_mode:
		AI_STATES.player_outside:
			spellcast_mode = WAND_MODES.surround_rotate
			if player.position.y < boss_arena_y_start:
				ai_mode = AI_STATES.prep_time
		AI_STATES.prep_time:
			spellcast_mode = WAND_MODES.point
			point_at = Vector2.LEFT * 100.0
			get_tree().create_timer(1.0).connect("timeout", self, "_on_given_prep_time")
		AI_STATES.sans_attack:
			pressed_inputs.action1 = true
			get_tree().create_timer(1.0).connect("timeout", self, "_on_got_dunked_on")


func _on_given_prep_time() -> void:
	ai_mode = AI_STATES.sans_attack

func _on_got_dunked_on() -> void:
	ai_mode = AI_STATES.real_fight
