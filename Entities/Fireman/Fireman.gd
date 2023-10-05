extends KinematicBody2D


export var player_detector_path :NodePath
onready var player_detector := get_node_or_null(player_detector_path)

export var properties_path :NodePath
onready var properties :EntityProperties = get_node_or_null(properties_path)

export var controller_path :NodePath
onready var controller :EntityController = get_node_or_null(controller_path)

var velocity :Vector2
var angle := 0.0
onready var wands := [$SpellCastingPoint, $SpellCastingPoint2]

var noise := OpenSimplexNoise.new()
var prepare_for_setup := {}

func _ready() -> void:
	noise.seed = randi()
	update_children_paths()
	if not prepare_for_setup.empty(): set_data(prepare_for_setup)


func update_children_paths() -> void:
	if controller:
		controller.player_detector = player_detector


func _physics_process(delta: float) -> void:
	angle += 0.5 * TAU * delta
	if controller.pressed_inputs.right:
		velocity.x = lerp(velocity.x, 900.0, 0.5 * delta * 60.0)
	elif controller.pressed_inputs.left:
		velocity.x = lerp(velocity.x, -900.0, 0.5 * delta * 60.0)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2 * delta * 60.0)
	
	if controller.pressed_inputs.down:
		velocity.y = lerp(velocity.y, 900.0, 0.5 * delta * 60.0)
	elif controller.pressed_inputs.up:
		velocity.y = lerp(velocity.y, -900.0, 0.5 * delta * 60.0)
	else:
		velocity.y = lerp(velocity.y, 0.0, 0.2 * delta * 60.0)
	
	for i in wands.size():
		var wand = wands[i]
		wand.target_position = Vector2.RIGHT.rotated(angle + PI * i) * 200 + position
		wand.position = Vector2.RIGHT.rotated(angle + PI * i) * 50
		wand.cast_wand()
	
	velocity.x += noise.get_noise_3d(position.x, position.y, Time.get_ticks_msec() / 10.0) * 50
	velocity.y += noise.get_noise_3d(position.y, position.x, Time.get_ticks_msec() / 10.0 + 200) * 50
	move_and_slide(velocity * delta * 60)


func health_object() -> Flesh:
	return properties.health


func _on_died() -> void:
	queue_free()


func set_data(data: Dictionary) -> void:
	if not properties:
		prepare_for_setup = data
	else:
		properties.set_data(prepare_for_setup)
		data.clear()
