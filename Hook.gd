"""
This script controls the chain.
"""
extends Node2D

onready var links = $Chains		# A slightly easier reference to the links
var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

var velocity = Vector2()
const chain_speed = 50	# The speed with which the chain moves

var retracting = false # Whether the chain irs moving back to the playe
var flying = false	# Whether the chain is moving through the air
var hooked = false	# Whether the chain has connected to a wall
var hooked_obj: Node

export(bool) var can_move = true

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2):
	if not retracting:
		$Tip.set_collision_mask_bit(1, false) # Prevent tip from colliding with player
		direction = dir.normalized()	# Normalize the direction and save it
		flying = true					# Keep track of our current scan
		tip = self.global_position		# reset the tip position to the player's position
		
# release() the chain
func release(retract: bool):
	if retract:
		$Tip.set_collision_mask_bit(1, true) # Allow tip to collide with player
		retracting = true
	can_move = true
	if hooked_obj is KinematicBody2D:
		hooked_obj.can_move = true
	flying = false	# Not flying anymore	
	hooked = false	# Not attached anymore

# Every graphics frame we update the visuals
func _process(delta):
	if not retracting:
		$Tip.set_collision_mask_bit(1, false) # Prevent tip from colliding with player
	self.visible = flying or hooked or retracting	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	var tip_loc = to_local(tip)	# Easier to work in local coordinates
	# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
	links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	links.position = tip_loc						# The links are moved to start at the tip
	links.region_rect.size.y = tip_loc.length() * 2		# and get extended for the distance between (0,0) and the tip

# Every physics frame we update the tip position
func _physics_process(delta):
	if can_move:
		$Tip.global_position = tip	# The player might have moved and thus updated the position of the tip -> reset it
	if flying:
		hooked_obj = null
		# `if move_and_collide()` always moves, but returns true if we did collide
		if can_move:
			velocity = direction
		var collision = $Tip.move_and_collide(velocity * chain_speed)
		if collision:
			hooked = true	# Got something!
			flying = false	# Not flying anymore
			hooked_obj = collision.collider
	elif hooked:
		# Can't grab Bullet because it's an Area2D
		if hooked_obj.name == "Enemy" or hooked_obj.name == "Bullet":
			velocity = hooked_obj.velocity
		else:
			velocity = Vector2(0, 0)
		if can_move:
			$Tip.move_and_collide(velocity * delta)
	elif retracting:
		velocity = get_parent().to_local(tip).normalized() * -chain_speed * 10
		$Tip.move_and_slide(velocity)
		for i in $Tip.get_slide_count():
			var collision = $Tip.get_slide_collision(i)
			if collision:
				if collision.collider.name == "Player":
					retracting = false
	if can_move:
		tip = $Tip.global_position	# set `tip` as starting position for next frame
