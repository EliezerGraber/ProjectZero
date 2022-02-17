"""
This script controls the chain.
"""
extends Node2D

onready var links = $Chains		# A slightly easier reference to the links
onready var player = get_parent()

var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

var velocity = Vector2()
export(int) var chain_speed = 50	# The speed with which the chain moves

var state = "disabled" # state can be "disabled", "flying", "hooked", or "retracting"

#var retracting = false # Whether the chain irs moving back to the playe
#var flying = false	# Whether the chain is moving through the air
#var hooked = false	# Whether the chain has connected to a wall

var hooked_obj: Node
var hooked_offset = Vector2(0, 0)
var max_distance = 600 # Distance from player until grapple retracts
var length = 500 # Length of the chain

export(bool) var can_move = true

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2):
	if state != "retracting":
		$Tip.set_collision_mask_bit(1, false) # Prevent tip from colliding with player
		direction = dir.normalized()	# Normalize the direction and save it
		state = "flying"				# Keep track of our current scan
		tip = self.global_position		# reset the tip position to the player's position
		
# release() the chain
func release(retract: bool):
	if retract:
		$Tip.set_collision_mask_bit(1, true) # Allow tip to collide with player
		state = "retracting"
	else:
		state = "disabled"
	can_move = true
	if is_instance_valid(hooked_obj):
		if hooked_obj is KinematicBody2D:
			hooked_obj.can_move = true
	#flying = false	# Not flying anymore	
	#hooked = false	# Not attached anymore
	hooked_obj = null
	#player.pull_type = "still"

# Every graphics frame we update the visuals
func _process(delta):
	if state != "retracting":
		$Tip.set_collision_mask_bit(1, false) # Prevent tip from colliding with player
	# Disable or enable colliding with objects
	if state == "hooked" or state == "retracting":
		$Tip.set_collision_mask_bit(0, false)
		$Tip.set_collision_mask_bit(3, false)
		$Tip.set_collision_mask_bit(5, false)
	else:
		$Tip.set_collision_mask_bit(0, true)
		$Tip.set_collision_mask_bit(3, true)
		$Tip.set_collision_mask_bit(5, true)
		
	## Visuals
	if state != "disabled":	# Only visible if flying or attached to something:
		var tip_loc = to_local(tip)	# Easier to work in local coordinates
		# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
		links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
		$Tip.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
		links.position = tip_loc						# The links are moved to start at the tip
		links.region_rect.size.y = tip_loc.length() * 2		# and get extended for the distance between (0,0) and the tip
	self.visible = state != "disabled"	# Only visible if flying or attached to something
		
# Every physics frame we update the tip position
func _physics_process(delta):
	#if can_move:
	$Tip.global_position = tip	# The player might have moved and thus updated the position of the tip -> reset it
	if state == "flying":
		hooked_obj = null
		# `if move_and_collide()` always moves, but returns true if we did collide
		if can_move:
			velocity = lerp(velocity, direction, 0.1)
		var collision = $Tip.move_and_collide(velocity * chain_speed)
		if collision:
			hooked_offset = $Tip.global_position - collision.collider.global_position
			state = "hooked"
			#hooked = true	# Got something!
			#flying = false	# Not flying anymore
			hooked_obj = collision.collider
			if is_instance_valid(hooked_obj):
				if hooked_obj is KinematicBody2D:
					hooked_obj.can_move = false
		#length = Vector2(player.global_position - tip).length()
		if Vector2(player.global_position - tip).length() >= max_distance:
			release(true)
	elif state == "hooked":
		# Can't grab Bullet because it's an Area2D
		#if player.pull_type == "still":
		if is_instance_valid(hooked_obj):
			$Tip.position = to_local(hooked_obj.global_position) + hooked_offset
	elif state == "retracting":
		velocity = lerp(velocity, player.to_local(tip).normalized() * -chain_speed * 50, 0.1)
		$Tip.move_and_slide(velocity)
		for i in $Tip.get_slide_count():
			var collision = $Tip.get_slide_collision(i)
			if collision:
				if collision.collider.name == "Player":
					state = "disabled"
					if is_instance_valid(hooked_obj):
						if hooked_obj is KinematicBody2D:
							hooked_obj.can_move = true
					velocity = Vector2(0, 0)
	#if can_move:
	tip = $Tip.global_position	# set `tip` as starting position for next frame
