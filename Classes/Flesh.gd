extends Reference

class_name Flesh


signal hole_poked
signal holes_poked(amount)
signal full_healed
signal bled
signal died
signal was_damaged(type)
signal effect_changed(effect, added)
signal broken_leg(amount)

enum DEATHS {
	BLED,
	HYPER,
	HYPO,
	SOUL,
	HOLES,
}

var moving_appendages := 2
var broken_moving_appendages := 0
var total_broken_appendages := 0

var needs_blood := true
var max_blood := 1.0
var poked_holes := 0
var max_holes := 200
var blood := 1.0
var blood_substance := "blood"

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
var confusion_timer := 0.0

var damaged_from_side_effect := false
var bleeding_from_side_effect := false

var last_damaged_by :Node2D
var bleeding_by :Node2D

var dead := false

var chances := 0
var guarantees := 0


func shatter_soul(freq :float, from: Node2D = null, side := false) -> void:
	soul -= freq
	if freq > 0.0:
		emit_signal("was_damaged", "soul")
	damaged_from_side_effect = side
	last_damaged_by = from


func poke_hole(holes := 1, from: Node2D = null, side := false) -> void:
	poked_holes += holes
	emit_signal("hole_poked")
	emit_signal("holes_poked", holes)
	if holes > 0:
		emit_signal("was_damaged", "hole")
	damaged_from_side_effect = side
	last_damaged_by = from
	bleeding_from_side_effect = side
	bleeding_by = from


func temp_change(deg :float, from: Node2D = null, side := false) -> void:
	temperature += deg
	if deg > 0:
		emit_signal("was_damaged", "heat")
	elif deg < 0:
		emit_signal("was_damaged", "cold")
	damaged_from_side_effect = side
	last_damaged_by = from


func full_heal():
	broken_moving_appendages = 0
	poked_holes = 0
	blood = max_blood
	temperature = normal_temperature
	soul = 1.0
	emit_signal("full_healed")


func process_health(delta:float, speed:Vector2 = Vector2(0, 0)) -> void:
	temperature = move_toward(temperature, normal_temperature, temp_regulation)
	blood -= poked_holes * (0.5+randf())*0.0005 * 60*delta
	if effects.has("onfire"):
		if fire_timer <= 0.0:
			emit_signal("effect_changed", "onfire", false)
			effects.erase("onfire")
		else:
			fire_timer -= delta
			temp_change(60*delta*0.05)
			emit_signal("was_damaged", "heat")
	if confusion_timer <= 0.0:
		emit_signal("effect_changed", "confused", false)
		effects.erase("confused")
	else:
		confusion_timer -= delta
	if weak_to_temp and temperature > death_hypertemperature * 0.8 and not "confused" in effects:
		add_effect("confused")
	if ((temperature > death_hypertemperature or temperature < death_hypotemperature) and weak_to_temp) or (soul <= 0.0 and has_soul) or (blood <= 0.0 and needs_blood) or poked_holes > max_holes:
		if (guarantees == 0 and chances == 0) or (chances > 0 and randi()%3 > 0):
			if not dead:
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
					
				dead = true
				emit_signal("died")
		else:
			if guarantees > 0:
				guarantees -= 1
			elif chances > 0:
				chances -= 1
			temperature = normal_temperature
			broken_moving_appendages = 0
			soul = 1.0
			blood = max_blood
			poked_holes = 0


func _instakill_pressed():
	dead = true
	emit_signal("died")


func add_effect(effect:String):
	effects.append(effect)
	emit_signal("effect_changed", effect, true)
	if effect == "onfire":
		fire_timer += 2 + randf()*10
	elif effect == "confused":
		confusion_timer += 2 + randf()*10


func break_legs():
	var brkn_legs := 1
	if randi()%3 == 0:
		brkn_legs = 2
	var d := min(broken_moving_appendages + brkn_legs, 2) - broken_moving_appendages
	if d > 0:
		emit_signal("broken_leg", d)
		total_broken_appendages += d
	broken_moving_appendages = min(broken_moving_appendages + brkn_legs, 2)
