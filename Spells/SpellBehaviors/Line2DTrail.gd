extends Line2D


func _on_request_movement(delta: Vector2):
	points = [-delta, Vector2.ZERO]
