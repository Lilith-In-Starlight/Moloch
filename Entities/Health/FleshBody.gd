extends Node

class_name FleshBody

signal broken_legs(amt)
signal restored_legs(amt)
signal hole_poked(amt)
signal sliced(amt)
signal max_holed()
signal impacted_body_top(amt)
signal impacted_body_bottom(amt)
signal impacted_body_side(amt)

const DEFAULT_LEGS := 2
const DEFAULT_MAX_LEGS := 2
const DEFAULT_MAX_HOLES := 200

var leg_impact_resistance := 700
var side_impact_resistance := 500

var legs := 2
var broken_legs := 0
var broken_legs_total := 0

var max_holes := DEFAULT_MAX_HOLES
var holes := 0
var slices := 0

var is_vital := true
var is_flammable := true


func _process(delta: float) -> void:
	if holes > max_holes:
		emit_signal("max_holed")

func break_legs(amt: int):
	legs -= amt
	broken_legs_total += amt
	emit_signal("broken_legs", amt)


func break_random_legs():
	var brkn_legs := 1
	if randi()%3 == 0:
		brkn_legs = 2
	var d := min(broken_legs + brkn_legs, legs) - broken_legs
	if d > 0:
		emit_signal("broken_legs", d)
		broken_legs += d
		broken_legs_total += d
	broken_legs = min(broken_legs + brkn_legs, legs)


func restore_legs(amt: int):
	broken_legs -= amt
	emit_signal("restored_legs", amt)


func poke_holes(amt: int):
	holes += amt
	emit_signal("hole_poked", amt)


func slice():
	slices += 1
	emit_signal("sliced")


func full_heal():
	broken_legs = 0
	holes = 0
	slices = 0


func handle_vertical_impact(force: Vector2):
	if force.y > leg_impact_resistance:
		break_random_legs()
		emit_signal("impacted_body_bottom", force.y)
	if force.y > leg_impact_resistance * 2:
		break_random_legs()
		poke_holes(1)
		emit_signal("impacted_body_bottom", force.y)
	

func handle_side_impact(force: Vector2):
	if abs(force.x) > side_impact_resistance:
		poke_holes(1)
		emit_signal("impacted_body_side", force.x)
	if abs(force.y) < -leg_impact_resistance:
		poke_holes(1)
		get_parent().add_effect("confused")
		emit_signal("impacted_body_top", force.y)


func get_as_dict() -> Dictionary:
	var dict := {}
	dict["leg_impact_resistance"] = leg_impact_resistance
	dict["side_impact_resistance"] = side_impact_resistance
	dict["legs"] = legs
	dict["broken_legs"] = broken_legs
	dict["broken_legs_total"] = broken_legs_total
	dict["max_holes"] = max_holes
	dict["holes"] = holes
	dict["slices"] = slices
	dict["is_vital"] = is_vital
	dict["is_flammable"] = is_flammable
	
	return dict


func set_from_dict(dict: Dictionary):
	for key in dict:
		set(key, dict[key])
