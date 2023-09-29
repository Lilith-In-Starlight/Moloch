extends Node

class_name SoulJittering

var valid_sounds := [
	preload("res://Sfx/soul/soul_deficit_1.wav"),
	preload("res://Sfx/soul/soul_deficit_2.wav"), 
	preload("res://Sfx/soul/soul_deficit_3.wav")
]
var valid_big_sounds := [
	preload("res://Sfx/soul/soul_deficit_big_1.wav"),
	preload("res://Sfx/soul/soul_deficit_big_2.wav"), 
	preload("res://Sfx/soul/soul_deficit_big_3.wav")
]

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, "timeout")


func timeout():
	var health :Flesh = get_parent().health_object()
	if not health.soul_module:
		return
	var soul_defficiency_percent := health.soul_module.amount / health.soul_module.maximum
	
	
	if soul_defficiency_percent > 0.99:
		return
	
	timer.wait_time = randf() * (soul_defficiency_percent)
	var n := preload("res://Particles/Soul.tscn").instance()
	n.position = get_parent().position
	get_parent().get_parent().add_child(n)
	var dist := Vector2(-1+randf()*2, -1+randf()*2) * (1 - soul_defficiency_percent) * 15.0
	get_parent().move_and_collide(dist)
	
	var sound_emitter := AudioStreamPlayer2D.new()
	sound_emitter.stream = valid_sounds[randi()%valid_sounds.size()]
	if dist.length() > 12:
		sound_emitter.stream = valid_big_sounds[randi()%valid_big_sounds.size()]
	sound_emitter.position = get_parent().position
	sound_emitter.pitch_scale = 0.9 + float()*0.3
	sound_emitter.volume_db = -25
	get_parent().get_parent().add_child(sound_emitter)
	sound_emitter.play()
