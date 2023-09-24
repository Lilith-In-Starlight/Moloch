extends RigidBody2D

var timer := 0.0
var substance := "blood"


func _ready() -> void:
	if modulate == Color("#ffffff"):
		match substance:
			"blood" : modulate = ColorN("red")
			"nitroglycerine" : modulate = ColorN("green")
			"water" : modulate = ColorN("blue")
			"lava" : modulate = ColorN("orange")
			_ : modulate = ColorN("red")


func _physics_process(delta):
	timer += delta
	if modulate.a <= 0.0:
		queue_free()
	if timer > 1.0:
		modulate.a -= 0.02
	$Polygon2D.rotation = linear_velocity.angle()
	
	if substance == "lava":
		for i in $Area2D.get_overlapping_bodies():
			if i.has_method("health_object"):
				if i.health_object().temperature_module:
					i.health_object().temperature_module.temperature += 10.0
