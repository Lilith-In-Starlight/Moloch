extends Sprite

onready var Raycast := $Raycast
onready var Raycast2 := $Raycast2
onready var Raycast3 := $Raycast3

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
	Raycast.cast_to = spell_behavior.velocity
	Raycast2.cast_to = spell_behavior.velocity
	Raycast3.cast_to = spell_behavior.velocity
	
	Raycast2.position = spell_behavior.velocity.tangent().normalized() * 5
	Raycast3.position = -spell_behavior.velocity.tangent().normalized() * 5


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
				position = i.get_collision_point() - i.position
				already_collided = true
				return
		
		position += spell_behavior.move(0, CastInfo, Vector2(cos(angle), sin(angle)) * 5) * delta * 60
		Raycast.cast_to = spell_behavior.velocity
