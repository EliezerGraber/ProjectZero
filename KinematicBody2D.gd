extends KinematicBody2D

var velocity = Vector2()
var target_vel = Vector2()
var size = self.scale.x * self.scale.y
export(bool) var can_move = true

func set_velocity(vel):
	target_vel = vel
func explode(vel):
	velocity += vel

func _physics_process(delta):
	move_and_slide(velocity * 60)
		
	velocity = lerp(velocity, target_vel, .05)
	if abs(velocity.x)-abs(target_vel.x) < .25:
		target_vel.x = 0
	if abs(velocity.y)-abs(target_vel.y) < .25:
		target_vel.y = 0

func touching_player():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider is KinematicBody2D:
			return collision.collider.name == "Player"
