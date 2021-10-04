extends Reference

class_name Flesh


signal hole_poked
signal full_healed
signal bled
signal died

enum DEATHS {
	BLED,
	HYPER,
	HYPO,
	SOUL,
	HOLES,
}

var moving_appendages := 2
var broken_moving_appendages := 0

var needs_blood := true
var max_blood := 1.0
var poked_holes := 0
var max_holes := 200
var blood := 1.0

var weak_to_temp := true
var temperature := 30.0
var normal_temperature := 30.0
var hypertemperature := 45.0
var hypotemperature := 5.0
var death_hypertemperature := 140.0
var death_hypotemperature := -40.0
var temp_regulation := 0.002

var cause_of_death := -1


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


func process_health():
	blood -= poked_holes * (0.5+randf())*0.0005
	if ((temperature > death_hypertemperature or temperature < death_hypotemperature) and weak_to_temp) or (soul <= 0.0 and has_soul) or (blood <= 0.0 and needs_blood) or poked_holes > max_holes:
		if cause_of_death == -1:
			if temperature > death_hypertemperature and weak_to_temp:
				cause_of_death = DEATHS.HYPER
			elif temperature < death_hypotemperature and weak_to_temp:
				cause_of_death = DEATHS.HYPO
			elif soul <= 0.0 and has_soul:
				cause_of_death = DEATHS.SOUL
			elif poked_holes > max_holes:
				cause_of_death = DEATHS.HOLES
			elif blood <= 0.0 and needs_blood:
				cause_of_death = DEATHS.BLED
				
		emit_signal("died")

