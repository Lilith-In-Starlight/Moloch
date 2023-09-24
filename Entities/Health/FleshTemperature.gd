extends Node


class_name FleshTemperature

signal hypothermia
signal hyperthermia
signal hypothermia_died
signal hyperthermia_died
signal temperature_state_changed(previous, new)

signal temperature_changed(amt)

const MAX_TEMPERATURE := 140.0
const MIN_TEMPERATURE := -40.0
const MID_MAX_TEMPERATURE := 45.0
const MID_MIN_TEMPERATURE := 5.0
const DEFAULT := 30.0


var max_temperature := MAX_TEMPERATURE
var min_temperature := MIN_TEMPERATURE
var mid_max_temperature := MID_MAX_TEMPERATURE
var mid_min_temperature := MID_MIN_TEMPERATURE
var normal := DEFAULT
var regulation := 1.2

var temperature := DEFAULT

var temp_state := 0
var previous_temp_state := 0

var is_vital := true


func _process(delta: float) -> void:
	temperature = move_toward(temperature, normal, regulation * delta)
	
	if temperature < 2 * (normal + min_temperature) / 3.0:
		temp_state = -2
	elif temperature < (normal + min_temperature) / 3.0:
		temp_state = -1
	elif temperature > (normal + min_temperature) / 3.0 and temperature < (normal + max_temperature) / 3.0:
		temp_state = -1
	elif temperature > (normal + max_temperature) / 3.0:
		temp_state = 1
	elif temperature > 2 * (normal + max_temperature) / 3.0:
		temp_state = 2
	
	if temp_state != previous_temp_state:
		emit_signal("temperature_state_changed", previous_temp_state, temp_state)
		previous_temp_state = temp_state
	
	if temperature > max_temperature:
		emit_signal("hyperthermia_died")
	elif temperature < min_temperature:
		emit_signal("hypothermia_died")
	

func temp_change(amt: float) -> void:
	temperature += amt
	emit_signal("temperature_changed", amt)
