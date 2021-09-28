extends Reference

signal hole_poked
signal full_healed


class_name Flesh

var moving_appendages := 2
var broken_moving_appendages := 0

var needs_blood := true
var max_blood := 1.0
var poked_holes := 0
var blood := 1.0

var weak_to_temp := true
var temperature := 30.0
var normal_temperature := 30.0
var hypertemperature := 45.0
var hypotemperature := 5.0
var death_hypertemperature := 140.0
var death_hypotemperature := -40.0
var temp_regulation := 0.002


var has_soul := true
var soul := 1.0

var is_players := false

func shatter_soul(freq :float) -> void:
	soul -= freq
	
func poke_hole(holes := 1) -> void:
	poked_holes += holes
	emit_signal("hole_poked")

func temp_change(deg :float) -> void:
	temperature += deg

func full_heal():
	broken_moving_appendages = 0
	poked_holes = 0
	blood = max_blood
	temperature = normal_temperature
	soul = 1.0
	emit_signal("full_healed")
