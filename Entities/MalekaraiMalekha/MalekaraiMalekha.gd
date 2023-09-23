extends KinematicBody2D

const SPELLCAST_POINT_DIST := 35.0

var spellcast_rotation := 0.0
var spellcast_focus := 0


onready var controller :MalekaraiMalekhaController = $MalekaraiMalekhaController
onready var properties :MalekaraiMalekhaProperties = $MalekaraiMalekhaProperties

onready var spell_casting_points := [
	$SpellCastingPoint,
	$SpellCastingPoint2,
	$SpellCastingPoint3,
	$SpellCastingPoint4,
]


func _ready() -> void:
	var n := 0
	properties.health.soul = 80.0
	properties.health.blood = 18.0
	properties.health.max_blood = 18.0
	properties.health.death_hypertemperature = 10000.0
	properties.health.max_holes = 2000.0
	properties.health.connect("died", self, "_died")
	
	for i in spell_casting_points:
		i.wand_slot = n
		n += 1

func _process(delta: float) -> void:
	properties.health.process_health(delta)
	match controller.spellcast_mode:
		controller.WAND_MODES.surround_rotate:
			if not controller.spin_counter_clockwise: spellcast_rotation += PI/2.0 * delta
			else: spellcast_rotation -= PI/2.0 * delta
			var point := Vector2.RIGHT.rotated(spellcast_rotation) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.position = lerp(node.position, point, 0.2 * delta * 60)
				node.target_position = position + node.position * 2
				point = point.rotated(PI/2.0)
		
		controller.WAND_MODES.point:
			var current_wand_offset := -spellcast_focus
			var point := Vector2.RIGHT.rotated(controller.point_at.angle() - spellcast_focus * PI/6.0) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.position = lerp(node.position, point, 0.2 * delta * 60)
				node.target_position = position + node.position * 2
				point = point.rotated(PI/6.0)
				
		controller.WAND_MODES.surround_point:
			var current_wand_offset := -spellcast_focus
			var point := Vector2.RIGHT.rotated(controller.point_at.angle() - spellcast_focus * PI/2.0) * SPELLCAST_POINT_DIST
			for node in spell_casting_points:
				node.position = lerp(node.position, point, 0.2 * delta * 60)
				node.target_position = position + node.position * 2
				point = point.rotated(PI/2.0)
	
	if controller.pressed_inputs.action1:
		spell_casting_points[spellcast_focus].cast_wand()


func health_object() -> Flesh:
	return properties.health


func _on_StopAllWounds_timeout() -> void:
	health_object().poked_holes = 0


func _died():
	controller._died()
	queue_free()
