extends EntityController

class_name HumanController

onready var Player :Character = get_tree().get_nodes_in_group("Player")[0]
onready var raycast_one := $"../RayCast2D"
onready var raycast_two := $"../RayCast2D2"
onready var raycast_three := $"../PlayerFinder"
onready var aim := $"../AimRay"
onready var line := $"../Line2D"
var held_jump := 0.0

var last_seen := Vector2(0, 0)


func _process(delta: float) -> void:
	var speed :Vector2 = get_parent().speed
	var position :Vector2 = get_parent().position
	raycast_one.position.x = speed.x * delta
	raycast_two.cast_to.x = speed.x * delta
	raycast_three.cast_to = (Player.position - position).normalized() * 250
	aim.position = Vector2.ZERO
	var aa :Vector2 = aim.cast_to
	if aim.is_colliding():
		aa = aim.get_collision_point() - position
	
	if raycast_three.is_colliding() and raycast_three.get_collider() == Player:
		if not get_parent().wand.running:
			get_parent().wand.run(get_parent())
		
		aim.cast_to = Vector2.RIGHT.rotated(lerp_angle(aim.cast_to.angle(), (Player.position - position).angle(), 0.05)) * 1000
		line.visible = true
		line.points[1] = aa
		line.points[0] = get_parent().cast_from() - position
		last_seen = Player.position
		get_parent().looking_at = Player.position
		if Player.position.x > position.x + 60:
			pressed_inputs.right = true
			pressed_inputs.left = false
		elif Player.position.x < position.x - 60:
			pressed_inputs.right = false
			pressed_inputs.left = true
		else:
			pressed_inputs.right = false
			pressed_inputs.left = false
		if (!raycast_one.is_colliding() and !raycast_two.is_colliding()) and get_parent().is_on_floor():
			pressed_inputs.move_action = true
		elif Player.position.y < position.y - 5 and (get_parent().is_on_floor() or get_parent().state == get_parent().STATES.WALL) and not pressed_inputs.move_action:
			pressed_inputs.move_action = true
			held_jump = 0.4
		elif held_jump <= 0.0:
			pressed_inputs.move_action = false
	else:
		line.visible = false
		get_parent().looking_at = last_seen
		if last_seen.x > position.x:
			pressed_inputs.right = true
			pressed_inputs.left = false
		elif last_seen.x < position.x:
			pressed_inputs.right = false
			pressed_inputs.left = true
		else:
			pressed_inputs.right = false
			pressed_inputs.left = false
		if (!raycast_one.is_colliding() and !raycast_two.is_colliding()) and get_parent().is_on_floor():
			pressed_inputs.move_action = true
		elif last_seen.y < position.y - 2 and (get_parent().is_on_floor() or get_parent().state == get_parent().STATES.WALL) and not pressed_inputs.move_action:
			pressed_inputs.move_action = true
			held_jump = 0.4
		elif held_jump <= 0.0:
			pressed_inputs.move_action = false
	
	held_jump -= delta
	
	pressed_inputs.down = Player.position.y > position.y + 10


func get_movement_axis() -> Vector2:
	return Vector2.ZERO


func get_eye_direction() -> Vector2:
	return aim.cast_to.normalized()


func get_eye_specific_direction() -> Vector2:
	return aim.cast_to
