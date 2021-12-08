extends Area2D

var dir = Vector2(0, 0)
export var direction: Vector2
export var speed: int

# Called when the node enters the scene tree for the first time.
func _ready():
	 connect("body_entered", self, "c_on_Bullet_body_entered")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	m_move_bullet(delta)
	dir = direction * 80
	
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
	if body.name != "Tip":
		queue_free()
