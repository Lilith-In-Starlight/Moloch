extends Node2D


var WorldMap :TileMap

var CastInfo := SpellCastInfo.new()
var spell_behavior = RayBehavior.new()


var timer := 0.0

func _ready():
	add_child(spell_behavior)
	spell_behavior.ray_setup(self, 30000)
	spell_behavior.connect("hit_something", self, "_on_hit_something")
	spell_behavior.connect("hit_nothing", self, "_on_hit_nothing")
	WorldMap = get_tree().get_nodes_in_group("World")[0]


func _physics_process(delta):
	CastInfo.heat_caster(1/60.0)
	spell_behavior.ray_setup(self, 3000)
	spell_behavior.cast(CastInfo)
	
	timer += delta
	if timer > 0.5:
		queue_free()
			

func _on_hit_something():
	var pos :Vector2 = spell_behavior.get_collision_point()
	var pos2 :Vector2 = spell_behavior.get_collision_point()
	if spell_behavior.get_collider().is_in_group("World"):
		CastInfo.push_caster(-(pos-position).normalized()*30)
		pos.x = int(pos.x/8)
		pos.y = int(pos.y/8)
		for x in range(-3, 4):
			for y in range(-3, 4):
				var v := Vector2(x, y)
				if v.length() < 3:
					WorldMap.set_cellv(v+pos,-1)
					CastInfo.heat_caster(1/60.0)
		WorldMap.update_bitmask_region(pos-Vector2(3,3), pos+Vector2(3,3))
	
	elif spell_behavior.get_collider().has_method("health_object"):
		spell_behavior.get_collider().health_object().temp_change(5.0, CastInfo.Caster)
		CastInfo.heat_caster(1/60.0)
		CastInfo.push_caster(-(pos-position).normalized()*20)
	$Line2D.points = [Vector2(0, 0), pos2-position]


func _on_hit_nothing():
	$Line2D.points = [Vector2(0, 0), Vector2(cos(spell_behavior.angle), sin(spell_behavior.angle))*1000]
