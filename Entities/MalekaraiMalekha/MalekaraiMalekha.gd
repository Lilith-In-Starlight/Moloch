extends KinematicBody2D

const SPELLCAST_POINT_DIST := 35.0

var spellcast_rotation := 0.0
var spellcast_focus := 0


onready var controller :MalekaraiMalekhaController = $MalekaraiMalekhaController

onready var spell_casting_points := [
	$SpellCastingPoint,
	$SpellCastingPoint2,
	$SpellCastingPoint3,
	$SpellCastingPoint4,
]

func _ready() -> void:
	var n := 0
	for i in spell_casting_points:
		i.wand_slot = n
		n += 1

func _process(delta: float) -> void:
	match controller.spellcast_mode:
		controller.WAND_MODES.surround_rotate:
			spellcast_rotation += 0.05
			var point := Vector2.RIGHT.rotated(spellcast_rotation) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.target_position = position + point * 2
				node.position = point
				point = point.rotated(PI/2.0)
		
		controller.WAND_MODES.point:
			var current_wand_offset := -spellcast_focus
			var point := Vector2.RIGHT.rotated(controller.point_at.angle()) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.target_position = position + point * 2
				node.position = point
				point = point.rotated(current_wand_offset * PI/6.0)
				current_wand_offset += 1
	
	if controller.pressed_inputs.action1:
		spell_casting_points[spellcast_focus].cast_wand()
