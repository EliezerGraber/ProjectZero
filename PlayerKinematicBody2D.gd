extends KinematicBody2D

export (int) var speed = 3

var velocity = Vector2()
var transfer_velocity = Vector2()
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

func _process(delta):
	pass

func _physics_process(delta):
	movement()
	#move_and_slide(velocity * 80)
	var collision = move_and_collide(velocity * 80 * delta)
	if collision:
		velocity = velocity.slide(collision.normal)
	
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
