extends Area2D

export var direction: Vector2
export var speed: int

# Called when the node enters the scene tree for the first time.
func _ready():
	 connect("body_entered", self, "c_on_Bullet_body_entered")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	m_move_bullet(delta)
	
func m_move_bullet(delta):
	rotation_degrees = rad2deg(direction.angle())
	position += direction.normalized() * speed * delta
	
func c_on_Bullet_body_entered(body):
	var combat_component
	for child in body.get_children():
		if(child.name == 'CombatComponent'):
			combat_component = child
	if(combat_component != null):
		combat_component.c_hit(1)
		queue_free()
	