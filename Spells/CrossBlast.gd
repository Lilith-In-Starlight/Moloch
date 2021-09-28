extends Area2D


var CastInfo := SpellCastInfo.new()
var rotate :float

var speed := 4.0


func _ready():
	CastInfo.set_position(self)
	CastInfo.set_goal()
	rotate = CastInfo.goal.angle_to_point(position)


func _physics_process(delta):
	position += Vector2(cos(rotate), sin(rotate))*speed*delta*60
	speed = move_toward(speed, 0, delta*60*0.08)
	
	if speed < 0.002:
		queue_free()


func _draw():
	draw_circle(Vector2(0, 0), 6, "#ffb5f8")
	draw_circle(Vector2(0, 0), 4, "#ffe3fc")
	
	
