extends KinematicBody2D

export(int) var speed = 5
export(int) var hook_pull = 20
export(String) var pull_type = "still" # to_obj, to_player, still
var velocity = Vector2()
var hook_velocity := Vector2(0,0) # For pulling player to object
var pulling_velocity := Vector2(0, 0) # For pulling object to player
var dragging_velocity := Vector2(0, 0) # For dragging objects around with mouse
#var transfer_velocity = Vector2()
var input := Vector2(0, 0)
var mouse_pos_l := Vector2(0, 0) # Limited mouse position around player

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
		velocity.x = lerp(velocity.x,0,.25)
	
	if input.y != 0:
		velocity.y = clamp(velocity.y+(input.y*.4),-speed,speed)
	else:
		velocity.y = lerp(velocity.y,0,.25)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if not $Hook.hooked:
				if Input.is_mouse_button_pressed(1):
					pull_type = "to_obj"
				if Input.is_mouse_button_pressed(2):
					pull_type = "still"
			# We clicked the mouse -> shoot()
			if not ($Hook.hooked or $Hook.flying or $Hook.retracting) and (Input.is_mouse_button_pressed(1) or Input.is_mouse_button_pressed(2)):
				$Hook.shoot(event.position - get_viewport().size * 0.5)
	if event.is_action_released("release"):
		if $Hook.hooked or $Hook.flying:
			# We released the mouse -> release() with retraction
			$Hook.release(true)
	if event is InputEventMouseMotion:
		# Limited mouse position
		mouse_pos_l = lerp(mouse_pos_l,Vector2(clamp(get_global_mouse_position().x, self.global_position.x - $Hook.length, self.global_position.x + $Hook.length), clamp(get_global_mouse_position().y, self.global_position.y - $Hook.length, self.global_position.y + $Hook.length)),1)


func _physics_process(delta):
	# Basic movement
	movement()
	
	# Pull you towards thing physics
	if $Hook.hooked and pull_type == "to_obj":
		hook_velocity = lerp(hook_velocity, to_local($Hook.tip).normalized() * hook_pull, .09)
		# Amplify pull depending on direction
		if sign(hook_velocity.x) != sign(input.x) and input.x != 0:
			hook_velocity.x *= 0.9
		elif sign(hook_velocity.x) == sign(input.x) and input.x != 0:
			hook_velocity.x *= 1.1
		if sign(hook_velocity.y) != sign(input.y) and input.y != 0:
			hook_velocity.y *= 0.9
		elif sign(hook_velocity.y) == sign(input.y) and input.y != 0:
			hook_velocity.y *= 1.1
	elif $Hook.hooked and pull_type == "still":
		if $Hook.hooked_obj is KinematicBody2D:
			dragging_velocity = lerp(dragging_velocity, $Hook.hooked_obj.to_local(mouse_pos_l).normalized() * hook_pull * (4 / $Hook.hooked_obj.size), .2)
			#print(Vector2(mouse_pos_l - $Hook.hooked_obj.global_position).length())
			if Vector2(mouse_pos_l - $Hook.hooked_obj.global_position).length() < 50:
				dragging_velocity /= 2
			
			$Hook.hooked_obj.set_velocity(dragging_velocity)
	
	### Movement
	## Pulling
	# Slow down
	if not $Hook.hooked:
		hook_velocity = lerp(hook_velocity, Vector2(0,0), .09)
	# Cap it
	hook_velocity = Vector2(clamp(hook_velocity.x, -hook_pull,hook_pull),clamp(hook_velocity.y, -hook_pull,hook_pull))
	if hook_velocity.length() > 10:
		print(hook_velocity)
	
	## Moooooove
	velocity += hook_velocity
	move_and_slide(velocity * 80)
	
	# Release if touching player
	if $Hook.hooked_obj is KinematicBody2D:
		if $Hook.hooked_obj.touching_player() and pull_type == "to_obj":
				$Hook.release(false) # Release without retracting
