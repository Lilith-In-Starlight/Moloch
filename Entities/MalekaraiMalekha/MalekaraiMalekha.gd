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

func _process(delta: float) -> void:
	match controller.spellcast_mode:
		controller.WAND_MODES.surround_rotate:
			spellcast_rotation += 0.05
			var point := Vector2.RIGHT.rotated(spellcast_rotation) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.position = point
				point = point.rotated(PI/2.0)
