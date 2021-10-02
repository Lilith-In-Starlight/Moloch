extends Control

var player_health :Flesh


func _ready():
	player_health = get_tree().get_nodes_in_group("Player")[0].health_object()


func _process(delta):
	visible = Items.player_items.has(".9")
	var maximum := max(player_health.death_hypertemperature, player_health.temperature) + abs(player_health.death_hypotemperature) + player_health.soul + max(player_health.blood, player_health.max_blood)
	var height := get_viewport_rect().size.y - 12
	$Soul.rect_size.y = (player_health.soul / maximum) * 12
	$Heat.rect_size.y = (player_health.temperature / maximum) *0.3
	$Blood.rect_size.y = (player_health.blood / maximum) * 12
	
	var c_height = height/($Soul.rect_size.y + $Heat.rect_size.y + $Blood.rect_size.y)
	$Soul.rect_size.y *= c_height
	$Heat.rect_size.y *= c_height
	$Blood.rect_size.y *= c_height
	$Soul.rect_position.y = 6.0
	$Heat.rect_position.y = $Soul.rect_position.y + $Soul.rect_size.y
	$Blood.rect_position.y = $Heat.rect_position.y + $Heat.rect_size.y
	
	
	$Border.rect_position.y = 5
	$Border.rect_size.y = height + 2.0
	
	
