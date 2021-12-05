extends KinematicBody2D

class_name FloatingOrb

var Player :Character

var health := Flesh.new()

var direction := Vector2(1, 0)
var speed_n := 0.0

var first_check := false

func _ready() -> void:
	health.needs_blood = false
	Player = get_tree().get_nodes_in_group("Player")[0]
	health.connect("died", self, "on_death")


func _physics_process(delta: float) -> void:
	health.process_health(delta)
	if not first_check:
		if Player.position.distance_to(position) < 500:
			queue_free()
		var tcol :KinematicCollision2D = move_and_collide(Vector2(0, 0), true, true, true)
		if tcol != null:
			if tcol.collider != self:
				queue_free()
		first_check = true
	
	var velocity = move_and_slide(direction * abs(speed_n))
	speed_n = velocity.length()
	if speed_n != 0:
		direction = velocity.normalized()


func on_death():
	queue_free()
