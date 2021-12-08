extends Node2D

export var max_hp: int
var cur_hp: int

# Called when the node enters the scene tree for the first time.
func _ready():
	cur_hp = max_hp

func c_hit(damage):
	if(damage >= cur_hp):
		call_deferred('m_die')
	else:
		call_deferred('m_damage', damage)
		
func m_die():
	print('dead')
	cur_hp = 0
	get_parent().free()
	
func m_damage(damage):
	cur_hp = cur_hp - damage
	print('hit: %d/%d' % [cur_hp, max_hp])
