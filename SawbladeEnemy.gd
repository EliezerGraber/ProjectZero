extends KinematicBody2D

var dir_timer = 0
var velocity = Vector2(0, 0)
var target_vel = Vector2(0, 0)
var size = self.scale.x * self.scale.y
var collision
var speedControl = 4

export(bool) var can_move = true

func _ready():
	pass

func set_velocity(vel):
	target_vel = vel
func explode(vel):
	velocity += vel
func is_loaded():
	if is_instance_valid($"../Player") and Vector2(self.global_position - $"../Player".global_position).abs().length() < 1000:
		return true
	else:
		return false
func _physics_process(delta):
	if self.is_loaded():
		do_physics_process()
func do_physics_process():
	move_and_slide(velocity * 60)
	if can_move:
		speedControl = 3
	else:
		speedControl = 1
	#astar code starts here
	#print(self.global_position)
	get_parent().freeAStarCell(self.global_position)
	get_parent().occupyAStarCell(self.global_position, false)
	var path = get_parent().getAStarPathToPlayer(self.global_position)
	if path.size() > 1:
		target_vel = lerp(target_vel,path[0].direction_to(path[1]) * speedControl, speedControl/2)
	else:
		if is_instance_valid($"../Player"):
			target_vel = lerp(target_vel,self.global_position.direction_to(get_parent().player.global_position)*speedControl, speedControl/2)
	
	velocity = lerp(velocity, target_vel, .05)
	if abs(velocity.x)-abs(target_vel.x) < .25:
		target_vel.x = 0
	if abs(velocity.y)-abs(target_vel.y) < .25:
		target_vel.y = 0
		
	#astar code ends here
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider is KinematicBody2D:
			var combat_component
			for child in collision.collider.get_children():
				if(child.name == 'CombatComponent'):
					combat_component = child
			if(combat_component != null):
				combat_component.c_hit(0.001)
				#print(collision.normal)
				velocity += collision.normal * 10

func touching_player():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider is KinematicBody2D:
			return collision.collider.name == "Player"

