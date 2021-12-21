extends KinematicBody2D

var velocity = Vector2()
var target_vel = Vector2()
var size = self.scale.x * self.scale.y
export(bool) var can_move = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_velocity(vel):
	target_vel = vel

func _physics_process(delta):
	move_and_slide(velocity * 60)
		
	velocity = lerp(velocity, target_vel, .15)
	if abs(velocity.x)-abs(target_vel.x) < .25:
		target_vel.x = 0
	if abs(velocity.y)-abs(target_vel.y) < .25:
		target_vel.y = 0

func touching_player():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		return collision.collider.name == "Player"
