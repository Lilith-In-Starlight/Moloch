extends FloatingOrb

const attack := preload("res://Spells/Rage.tscn")
const small_attack := preload("res://Spells/SmallRage.tscn")

var attacking := false

var Noise := OpenSimplexNoise.new()

var eye_dir := Vector2(0, 0)

var timer := 0.0


func _ready() -> void:
	health.death_hypertemperature = 900.0
	Noise.seed = hash(self)
	health.connect("was_damaged", self, "_on_damaged")


func _process(delta: float) -> void:
	eye_dir = Vector2(-1 + randf() * 2, -1 + randf() * 2)
	direction = direction.rotated(Noise.get_noise_3d(position.x, position.y, Engine.get_frames_drawn()) * 0.1)
	speed_n = Noise.get_noise_1d(Engine.get_frames_drawn()*0.001+100) * 120 * 3
	speed_n = abs(speed_n)
	$Wings.rotation = lerp_angle($Wings.rotation, 0.01 * (speed_n * direction.x), 0.3)
	
	print(speed_n)
	if direction == Vector2(0, 0):
		direction = Vector2(0, 1)
	
	timer += delta
	
	if attacking:
		direction = (Player.position - position).normalized()
		if timer > 0.1:
			var n := small_attack.instance()
			if randf() > 0.98:
				n = attack.instance()
			n.CastInfo.goal = eye_dir * 100 + position
			n.CastInfo.Caster = self
			get_parent().add_child(n)
			timer -= 0.1
	

func _on_damaged(damage_type:String) -> void:
	attacking = true
	$VisibilityEnabler2D.process_parent = false
	$VisibilityEnabler2D.physics_process_parent = false


func looking_at() -> Vector2:
	return eye_dir
	
func cast_from() -> Vector2:
	return position + eye_dir.normalized() * 18


func health_object() -> Flesh:
	return health
