extends KinematicBody2D

var velocity = Vector2()
var target_vel = Vector2()
var size = self.scale.x * self.scale.y
export(bool) var can_move = true

var Explosion = preload("res://Explosion.tscn")

func explode(c):
	var explosionInst = Explosion.instance()
	add_child(explosionInst)

func set_velocity(vel):
	target_vel = vel

func _physics_process(delta):
	move_and_slide(velocity * 60)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		#if collision.collider.name != "Player":
		if collision:
			self.visible = false
			explode(1)
		
	velocity = lerp(velocity, target_vel, .05)

func touching_player():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		return collision.collider.name == "Player"
