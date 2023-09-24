extends Control

var player_health :Flesh


func _ready():
	player_health = Items.player_health


func _process(_delta):
	visible = Items.count_player_items(".9") > 0
	var maximum :float = player_health.quantify_best_status()
	var height := get_viewport_rect().size.y - 12
	if player_health.soul_module: $Soul.rect_size.y = (player_health.soul_module.amount / maximum) * 12
	if player_health.temperature_module: $Heat.rect_size.y = (player_health.temperature_module.temperature / maximum) *0.3
	if player_health.blood_module: $Blood.rect_size.y = (player_health.blood_module.amount / maximum) * 12
	
	var c_height = height/($Soul.rect_size.y + $Heat.rect_size.y + $Blood.rect_size.y)
	$Soul.rect_size.y *= c_height
	$Heat.rect_size.y *= c_height
	$Blood.rect_size.y *= c_height
	$Soul.rect_position.y = 6.0
	$Heat.rect_position.y = $Soul.rect_position.y + $Soul.rect_size.y
	$Blood.rect_position.y = $Heat.rect_position.y + $Heat.rect_size.y
	
	
	$Border.rect_position.y = 5
	$Border.rect_size.y = height + 2.0
	
