extends Sprite

onready var Raycast := $Raycast

var CastInfo := SpellCastInfo.new()
var spell_behavior := ProjectileBehavior.new()

var Map : Node2D
var angle := 0.0


var already_collided := false


func _ready() -> void:
	Map = get_tree().get_nodes_in_group("World")[0]
	CastInfo.heat_caster(5.0)
	CastInfo.set_position(self)
	angle = CastInfo.get_angle(self)
	spell_behavior.velocity = spell_behavior.get_initial_velocity(self)
	Raycast.target_position = spell_behavior.velocity


func _process(delta: float) -> void:
	scale.move_toward(Vector2(1.0, 1.0),  0.03 * delta * 60)
	
	# When the ball already collides with something, it's best to make it
	# disappear one frame after, so that godot has time to render it as
	# having already got there
	if already_collided:
		Map.summon_explosion(position, 8)
		queue_free()
	else:
		for i in get_children():
			if i.is_colliding():
				position = i.get_collision_point(0) - i.position
				already_collided = true
				return
		
		position += spell_behavior.move(0, CastInfo, Vector2(cos(angle), sin(angle)) * 5) * delta * 60
		Raycast.target_position = spell_behavior.velocity * delta * 60
