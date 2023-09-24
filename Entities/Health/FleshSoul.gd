extends Node

class_name FleshSoul

signal ran_out_of_soul

const DEFAULT_AMT := 1.0
const DEFAULT_MAX := 1.0

var amount := DEFAULT_AMT
var maximum := DEFAULT_MAX

var is_vital := true


func _process(delta: float) -> void:
	var parent = get_parent()
	
	if amount <= 0.0:
		amount = 0.0
		emit_signal("ran_out_of_soul")


func change_soul(amt: float):
	amount -= amt

func full_heal():
	amount = maximum
