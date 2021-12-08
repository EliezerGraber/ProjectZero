extends KinematicBody2D

export(int) var speed = 3
export(int) var hook_pull = 10
export(String) var pull_type = "still" # to_obj, to_player, still
var velocity = Vector2()
var hook_velocity := Vector2(0,0) # For pulling player to object
var pulling_velocity := Vector2(0, 0) # For pulling object to player
#var transfer_velocity = Vector2()
var input = Vector2()

func movement():
	# Inputs
	input.x = (
		-1 if Input.is_action_pressed("ui_left")
		else 1 if Input.is_action_pressed("ui_right")
		else 0
	)
	input.y = (
		-1 if Input.is_action_pressed("ui_up")
		else 1 if Input.is_action_pressed("ui_down")
		else 0
	)
	
	# Movement velocity
	if input.x != 0:
		velocity.x = clamp(velocity.x+(input.x*.4),-speed,speed)
	else:
		velocity.x = lerp(velocity.x,0,.35)
	
	if input.y != 0:
		velocity.y = clamp(velocity.y+(input.y*.4),-speed,speed)
	else:
		velocity.y = lerp(velocity.y,0,.35)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if $Hook.hooked or $Hook.flying and pull_type == "still":
				if Input.is_mouse_button_pressed(1):
					pull_type = "to_obj"
				if Input.is_mouse_button_pressed(2):
					pull_type = "to_player"
			# We clicked the mouse -> shoot()
			if not ($Hook.hooked or $Hook.flying or $Hook.retracting) and Input.is_mouse_button_pressed(2):
				$Hook.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release() with retraction
			if $Hook.flying:
				$Hook.release(true)
			else:
				pull_type = "still"
	if event.is_action("release"):
		if $Hook.hooked:
			$Hook.release(true)


func _physics_process(delta):
	# Basic movement
	movement()
	
	# Pull you towards thing physics
	if $Hook.hooked and pull_type == "to_obj":
		if not Input.is_mouse_button_pressed(1):
			pull_type = "still"
		# `to_local($Hook.tip).normalized()` is the direction that the hook is pulling
		hook_velocity = lerp(hook_velocity, to_local($Hook.tip).normalized() * hook_pull, .1)
		# Reduce pull if going in opposite direction
		if sign(hook_velocity.x) != sign(input.x):
			hook_velocity.x *= 0.7
		if sign(hook_velocity.y) != sign(input.y):
			hook_velocity.y *= 0.7
	# Pull thing towards you physics
	elif $Hook.hooked and pull_type == "to_player":
		if not Input.is_mouse_button_pressed(2):
			pull_type = "still"
		if $Hook.hooked_obj is KinematicBody2D:
			$Hook.hooked_obj.can_move = false
			$Hook.can_move = false
			pulling_velocity = lerp(pulling_velocity, to_local($Hook.tip).normalized() * hook_pull, .1)
			$Hook.hooked_obj.move_and_collide(pulling_velocity * -80 * delta)
			#$Hook/Tip.global_position = $Hook.tip
			#$Hook/Tip.move_and_collide(pulling_velocity * delta)
			#$Hook.tip = $Hook/Tip.global_position
	elif pull_type == "still":
		# Not hooked -> no hook velocity
		if $Hook.hooked_obj is KinematicBody2D:
			pulling_velocity = lerp(pulling_velocity, Vector2(0, 0), .05)
			$Hook.hooked_obj.move_and_collide(pulling_velocity * delta)
			$Hook/Tip.global_position = $Hook.tip
			$Hook/Tip.move_and_collide(pulling_velocity * delta)
			$Hook.tip = $Hook/Tip.global_position
			$Hook.hooked_obj.can_move = true
		
		hook_velocity = lerp(hook_velocity, Vector2(0,0), .15)

	# Move
	velocity += hook_velocity
	move_and_slide(velocity * 80)
	
	# Collision
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			if collision.collider == $Hook.hooked_obj and (pull_type == "to_obj" or pull_type == "to_player"):
				$Hook.release(false) # Release without retracting
	
	#var collision = move_and_collide(velocity * 80 * delta)
	#if collision:
	#	velocity = velocity.slide(collision.normal)
	
#	Box Pushing
#	if collision:
#		transfer_velocity = velocity - collision.normal
#		# To make the other kinematicbody2d move as well
#		if collision.collider.get_class() == "KinematicBody2D":
#			if abs(velocity.x) > speed or abs(velocity.y) > speed:
#				collision.collider.set_velocity(transfer_velocity * 10)
#				velocity = velocity.bounce(collision.normal) / 3
#			else:
#				collision.collider.set_velocity(transfer_velocity)
#				#velocity = velocity.slide(collision.normal)
