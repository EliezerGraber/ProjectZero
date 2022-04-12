extends Node2D

export var max_hp: int
var cur_hp: int

var burn_timer = null
var burning = false
var frozen = false

func _ready():
	burn_timer = Timer.new()
	add_child(burn_timer)
	
func _process(delta):
	pass
		
func c_hit(damage):
	if(damage >= cur_hp):
		call_deferred('m_die')
	else:
		call_deferred('m_damage', damage)

func burn(t):
	if burn_timer.is_stopped():
		burn_timer.connect("timeout", self, "burn_damage")
		burn_timer.set_wait_time(2.0)
		burn_timer.set_one_shot(false)
		burn_timer.start()
	
	burning = true
	$Fire.visible = true
	
	yield(get_tree().create_timer(t), "timeout")
	
	burn_timer.stop()
	burning = false
	$Fire.visible = false

func burn_damage():
	c_hit(.05)
	
func freeze(t):
	frozen = true
	$Freeze.visible = true
	
	yield(get_tree().create_timer(t), "timeout")
	
	frozen = false
	$Freeze.visible = false

func m_die():
	print('dead')
	cur_hp = 0
	get_parent().queue_free()
	
func m_damage(damage):
	cur_hp = cur_hp - damage
	print('hit: %d/%d' % [cur_hp, max_hp])
