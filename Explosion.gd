extends Area2D

func _physics_process(delta):
	print("Boomed:")
	for body in get_overlapping_bodies():
		if body != get_parent() and body is KinematicBody2D:
			var dir = to_local(body.global_position).normalized()
			body.explode(dir * 15 / (self.scale.x * self.scale.y / 2))
			if is_instance_valid($"../../Player/Hook") and $"../../Player/Hook".state == "hooked":
				$"../../Player/Hook".release(true)
			print(body.name)
	get_parent().queue_free()
	queue_free()
