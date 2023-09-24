extends Node

class_name FleshSoul

signal ran_out_of_soul
signal soul_state_changed(previous, new)

const DEFAULT_AMT := 1.0
const DEFAULT_MAX := 1.0

var amount := DEFAULT_AMT
var maximum := DEFAULT_MAX

var soul_state := 0
var previous_soul_state := 0

var is_vital := true


func _process(delta: float) -> void:
	var parent = get_parent()
	
	if amount < maximum * 1 / 3.0:
		soul_state = -2
	elif amount < maximum * 2 / 3.0:
		soul_state = -1
	elif amount < maximum * 4 / 3.0:
		soul_state = -1
	elif amount < maximum * 5 / 3.0:
		soul_state = 1
	elif amount < maximum * 6 / 3.0:
		soul_state = 2
	
	if soul_state != previous_soul_state:
		emit_signal("soul_state_changed", previous_soul_state, soul_state)
		previous_soul_state = soul_state
	
	if amount <= 0.0:
		amount = 0.0
		emit_signal("ran_out_of_soul")


func change_soul(amt: float):
	amount += amt

func full_heal():
	amount = maximum
