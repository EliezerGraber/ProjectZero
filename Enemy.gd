extends KinematicBody2D

var _timer = null
var dir_timer = 0
var velocity = Vector2(0, 0)
var target_vel = Vector2(0, 0)
var size = self.scale.x * self.scale.y
var collision

export(bool) var can_move = true
export(Vector2) var dir = Vector2(0, 1)
export(int) var move_range = 300
export(Resource) var BULLET
export(NodePath) onready var gun = get_node(gun) as Position2D
export(NodePath) onready var bullet_parent = get_node(bullet_parent)

func _ready():
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "shoot_test")
	_timer.set_wait_time(3.5)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

func set_velocity(vel):
	target_vel = vel
	
func _physics_process(delta):
	collision = move_and_collide(velocity * 60 * delta)
	if can_move: # Normal enemy movement
		velocity = lerp(velocity, dir, .05)
		if (collision and collision.collider.get_collision_layer() != 2) or dir_timer >= move_range:
			dir *= -1
			dir_timer = 0
		dir_timer += 1
	else: # Being pulled
		velocity = lerp(velocity, target_vel, .15)
		if abs(velocity.x)-abs(target_vel.x) < .25:
			target_vel.x = 0
		if abs(velocity.y)-abs(target_vel.y) < .25:
			target_vel.y = 0

func shoot_test():
	for i in range(0, 360, 45):
		m_shoot(i)
#takes in angle to shoot at in degrees
func m_shoot(angle:int):
	var b = BULLET.instance()
	bullet_parent.add_child(b)
	b.transform = Transform2D(deg2rad(angle), position).translated(Vector2(55, 0))
	b.direction = Vector2(1,0).rotated(deg2rad(angle))

func touching_player():
	if collision:
		return collision.collider.name == "Player"
	else:
		return false
