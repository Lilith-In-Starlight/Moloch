extends Control


func _ready():
	render_wand(null)


func render_wand(wand:Wand, selected :bool = false):
	$Select.visible = selected
	if wand == null:
		$Select.modulate = ColorN("white")
		$Base.texture = preload("res://Sprites/Wands/BaseEmpty.png")
		$Slots.texture = null
		$Cast.texture = null
		$Recharge.texture = null
		$Base.modulate = ColorN("white")
		$Slots.modulate = ColorN("white")
		$Cast.modulate = ColorN("white")
		$Recharge.modulate = ColorN("white")
	else:
		$Select.modulate = wand.color1
		$Base.texture = preload("res://Sprites/Wands/Base.png")
		if not wand.shuffle:
			match wand.spell_capacity:
				1: $Slots.texture = preload("res://Sprites/Wands/Model1/1.png")
				2: $Slots.texture = preload("res://Sprites/Wands/Model1/2.png")
				3: $Slots.texture = preload("res://Sprites/Wands/Model1/3.png")
				4: $Slots.texture = preload("res://Sprites/Wands/Model1/4.png")
				5: $Slots.texture = preload("res://Sprites/Wands/Model1/5.png")
				6: $Slots.texture = preload("res://Sprites/Wands/Model1/6.png")
		else:
			match wand.spell_capacity:
				1: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/1.png")
				2: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/2.png")
				3: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/3.png")
				4: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/4.png")
				5: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/5.png")
				6: $Slots.texture = preload("res://Sprites/Wands/Shuffle1/6.png")
		match 6-int(round((wand.spell_recharge/0.3)*6)):
			0, 1: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/1.png")
			2: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/2.png")
			3: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/3.png")
			4: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/4.png")
			5: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/5.png")
			6: $Cast.texture = preload("res://Sprites/Wands/CastSpeed/6.png")
		
		match 6-int(round((wand.full_recharge/0.6)*6)):
			0, 1: $Recharge.texture = preload("res://Sprites/Wands/Recharge/1.png")
			2: $Recharge.texture = preload("res://Sprites/Wands/Recharge/2.png")
			3: $Recharge.texture = preload("res://Sprites/Wands/Recharge/3.png")
			4: $Recharge.texture = preload("res://Sprites/Wands/Recharge/4.png")
			5: $Recharge.texture = preload("res://Sprites/Wands/Recharge/5.png")
			6: $Recharge.texture = preload("res://Sprites/Wands/Recharge/6.png")
		
		$Base.modulate = wand.color1
		$Slots.modulate = wand.color2
		$Cast.modulate = wand.color3
		$Recharge.modulate = wand.color3
