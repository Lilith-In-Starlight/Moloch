extends Node

class_name FleshBlood

signal ran_out_of_blood
signal bleeding_tick

const DEFAULT_AMT := 1.0
const DEFAULT_MAX := 1.0
const DEFAULT_SUBSTANCE := "blood"

var amount := DEFAULT_AMT
var maximum := DEFAULT_MAX
var substance := DEFAULT_SUBSTANCE

var ran_out := false

var is_vital := true


func _process(delta: float) -> void:
	var parent = get_parent()
	if parent.body_module:
		if parent.body_module.holes > 0:
			amount -= parent.body_module.holes * (0.015 + randf() * 0.03) * delta
			emit_signal("bleeding_tick")
	
	if amount <= 0.0:
		amount = 0.0
		if not ran_out:
			ran_out = true
			emit_signal("ran_out_of_blood")


func get_as_dict() -> Dictionary:
	var dict := {}
	dict["amount"] = amount
	dict["maximum"] = maximum
	dict["substance"] = substance
	dict["ran_out"] = ran_out
	dict["is_vital"] = is_vital
	
	return dict


func set_from_dict(dict: Dictionary):
	for key in dict:
		set(key, dict[key])


func full_heal():
	amount = maximum
