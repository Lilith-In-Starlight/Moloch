tool
extends Container

func _notification(what):
	if (what==NOTIFICATION_SORT_CHILDREN):
		var maxy := 0
		for c in get_children():
			c.rect_position.x = -c.rect_size.x/2
			c.rect_position.y = maxy
			maxy += c.rect_size.y

func set_some_setting():
	queue_sort()
