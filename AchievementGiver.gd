extends Node


func _process(delta: float) -> void:
	var dead :bool = get_parent().dead
	var was_dead :bool = get_parent().was_dead
	var health :Flesh = get_parent().health
	if dead and not was_dead:
		Config.give_achievement("first_of_many")
		if health.cause_of_death != health.DEATHS.BLED and health.cause_of_death != -1:
			if health.damaged_from_side_effect:
				get_parent().died_from_own_cast = true
				Config.give_achievement("fun1")
			elif health.last_damaged_by == self:
				get_parent().died_from_own_spell = true
				Config.give_achievement("fun2")
		elif health.cause_of_death != -1:
			if health.bleeding_from_side_effect:
				get_parent().died_from_own_cast = true
				Config.give_achievement("fun1")
			elif health.bleeding_by == self:
				get_parent().died_from_own_spell = true
				Config.give_achievement("fun2")
		was_dead = true
	
	if health.total_broken_appendages >= 4:
		Config.give_achievement("oof_ouch")
