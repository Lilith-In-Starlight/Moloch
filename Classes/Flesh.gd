extends Reference

class_name Flesh


signal hole_poked
signal holes_poked(amount)
signal full_healed
signal bled
signal died
signal was_damaged(type)
signal effect_changed(effect, added)

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
var needed_soul := 1.0

var is_players := false

var effects := []

var fire_timer := 0.0



func shatter_soul(freq :float) -> void:
	soul -= freq
	if freq > 0.0:
		emit_signal("was_damaged", "soul")


func poke_hole(holes := 1) -> void:
	poked_holes += holes
	emit_signal("hole_poked")
	emit_signal("holes_poked", holes)
	if holes > 0:
		emit_signal("was_damaged", "hole")


func temp_change(deg :float) -> void:
	temperature += deg
	if deg > 0:
		emit_signal("was_damaged", "heat")
	elif deg < 0:
		emit_signal("was_damaged", "cold")


func full_heal():
	broken_moving_appendages = 0
	poked_holes = 0
	blood = max_blood
	temperature = normal_temperature
	soul = 1.0
	emit_signal("full_healed")


func process_health(delta:float) -> void:
	blood -= poked_holes * (0.5+randf())*0.0005 * 60*delta
	if effects.has("onfire"):
		if fire_timer <= 0.0:
			emit_signal("effect_changed", "onfire", false)
			effects.erase("onfire")
		else:
			fire_timer -= delta
			temp_change(60*delta*2.0)
			emit_signal("was_damaged", "heat")
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


func _instakill_pressed():
		emit_signal("died")


func add_effect(effect:String):
	effects.append(effect)
	emit_signal("effect_changed", effect, true)
	if effect == "onfire":
		fire_timer += 30 + randf()*(60*3)
