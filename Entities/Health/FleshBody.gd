extends Node

class_name FleshBody

signal broken_legs(amt)
signal restored_legs(amt)
signal hole_poked(amt)

const DEFAULT_LEGS := 2
const DEFAULT_MAX_LEGS := 2
const DEFAULT_MAX_HOLES := 200

var leg_impact_resistance := 200
var side_impact_resistance := 200

var legs := 2
var broken_legs := 0

var holes := 0
var slices := 0

var is_vital := true


func break_legs(amt: int):
	legs -= amt
	emit_signal("broken_legs", amt)


func break_random_legs():
	var brkn_legs := 1
	if randi()%3 == 0:
		brkn_legs = 2
	var d := min(broken_legs + brkn_legs, legs) - broken_legs
	if d > 0:
		emit_signal("broken_leg", d)
		broken_legs += d
	broken_legs = min(broken_legs + brkn_legs, legs)


func restore_legs(amt: int):
	legs += amt
	emit_signal("restored_legs", amt)


func poke_holes(amt: int):
	holes += amt
	emit_signal("hole_poked", amt)


func full_heal():
	broken_legs = 0
	holes = 0
	slices = 0


func handle_impact(force: Vector2):
	if force.y > leg_impact_resistance:
		break_random_legs()
		emit_signal("impacted_body_bottom", force.y)
	if force.y > leg_impact_resistance * 2:
		break_random_legs()
		poke_holes(1)
		emit_signal("impacted_body_bottom", force.y)
	if abs(force.x) > side_impact_resistance:
		poke_holes(1)
		emit_signal("impacted_body_side", force.x)
	if abs(force.y) < -leg_impact_resistance:
		poke_holes(1)
		get_parent().add_effect("confused")
		emit_signal("impacted_body_top", force.y)
	
