extends KinematicBody2D

export(int) var speed = 5
export(int) var hook_pull = 7
export(String) var pull_type = "still" # to_obj, to_player, still
var velocity = Vector2()
var hook_velocity := Vector2(0,0) # For pulling player to object
var pulling_velocity := Vector2(0, 0) # For pulling object to player
var dragging_velocity := Vector2(0, 0) # For dragging objects around with mouse
var target_velocity := Vector2(0, 0)
#var transfer_velocity = Vector2()
var input := Vector2(0, 0)
var mouse_pos_l := Vector2(0, 0) # Limited mouse position around player

onready var hook = $Hook

func explode(vel):
	target_velocity = vel
	
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
	
	# THIS SECTION MAY BE AN ISSUE =============================================
	# Movement velocity
	if input.x != 0 and (pull_type == "still" or hook.state != "hooked"):
		velocity.x = clamp(velocity.x+(input.x*.4),-speed,speed)
	else:
		velocity.x = lerp(velocity.x,0,.25)
	
	if input.y != 0 and (pull_type == "still" or hook.state != "hooked"):
		velocity.y = clamp(velocity.y+(input.y*.4),-speed,speed)
	else:
		velocity.y = lerp(velocity.y,0,.25)
	# ==========================================================================
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if hook.state != "hooked":
				if Input.is_mouse_button_pressed(1):
					pull_type = "to_obj"
				if Input.is_mouse_button_pressed(2):
					pull_type = "still"
			# We clicked the mouse -> shoot()
			if hook.state == "disabled" and (Input.is_mouse_button_pressed(1) or Input.is_mouse_button_pressed(2)):
				hook.shoot(to_local(get_global_mouse_position()))
	if event.is_action_released("release") or hook.state == "hooked" and not is_instance_valid(hook.hooked_obj):
		if hook.state == "hooked" or hook.state == "flying":
			# We released the mouse -> release() with retraction
			hook.release(true)
	if event is InputEventMouseMotion:
		# Limited mouse position
		mouse_pos_l = lerp(mouse_pos_l,Vector2(clamp(get_global_mouse_position().x, self.global_position.x - hook.length, self.global_position.x + hook.length), clamp(get_global_mouse_position().y, self.global_position.y - hook.length, self.global_position.y + hook.length)),1)


func _physics_process(delta):
	# Basic movement
	movement()
	
	# Pull you towards thing physics
	if hook.state == "hooked" and pull_type == "to_obj":
		hook_velocity = lerp(hook_velocity, to_local(hook.tip).normalized() * hook_pull, .09)
		# Amplify pull depending on direction
		if input.x == 1 and hook_velocity.x < speed/2:
			hook_velocity.x = lerp(hook_velocity.x, speed/2, .09)
		elif input.x == -1 and hook_velocity.x > -speed/2:
			hook_velocity.x = lerp(hook_velocity.x, -speed/2, .09)
		if input.y == 1 and hook_velocity.y < speed/2:
			hook_velocity.y = lerp(hook_velocity.y, speed/2, .09)
		elif input.y == -1 and hook_velocity.y > -speed/2:
			hook_velocity.y = lerp(hook_velocity.y, -speed/2, .09)
	elif hook.state == "hooked" and pull_type == "still":
		if is_instance_valid(hook.hooked_obj):
			if hook.hooked_obj is KinematicBody2D:
				dragging_velocity = lerp(dragging_velocity, hook.hooked_obj.to_local(mouse_pos_l).normalized() * hook_pull * (4 / hook.hooked_obj.size), .3)
				#print(Vector2(mouse_pos_l - hook.hooked_obj.global_position).length())
				if Vector2(mouse_pos_l - hook.hooked_obj.global_position).length() < 100:
					dragging_velocity /= 2
				if Vector2(mouse_pos_l - hook.hooked_obj.global_position).length() < 50:
					dragging_velocity /= 4
				if Vector2(mouse_pos_l - hook.hooked_obj.global_position).length() < 10:
					dragging_velocity /= 8
			
				hook.hooked_obj.set_velocity(dragging_velocity)
	
	### Movement
	## Pulling
	# Slow down
	if hook.state != "hooked":
		hook_velocity = lerp(hook_velocity, Vector2(0,0), .09)
	# Cap it
	hook_velocity = Vector2(clamp(hook_velocity.x, -hook_pull,hook_pull),clamp(hook_velocity.y, -hook_pull,hook_pull))
	
	## Moooooove
	velocity += hook_velocity + target_velocity
	target_velocity = lerp(target_velocity, Vector2(0, 0), 0.15)
	move_and_slide(velocity * 80)
	
	# Move limited mouse pos if player is moving
	if velocity.length() > 0:
		# Limited mouse position
		mouse_pos_l = lerp(mouse_pos_l,Vector2(clamp(get_global_mouse_position().x, self.global_position.x - hook.length, self.global_position.x + hook.length), clamp(get_global_mouse_position().y, self.global_position.y - hook.length, self.global_position.y + hook.length)),1)
		
	# Release if touching player
	if is_instance_valid(hook.hooked_obj):
		if hook.hooked_obj is KinematicBody2D:
			if hook.hooked_obj.touching_player() and pull_type == "to_obj":
				hook.release(false) # Release without retracting
