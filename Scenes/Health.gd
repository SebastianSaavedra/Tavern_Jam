extends CharacterBody2D

@export var hp = 3 : set = set_hp

signal OnHp_changed
signal OnDied

func _ready():
	pass

func heal_dmg( heal ):
	set_hp(hp + heal)
	
func take_dmg( dmg ):
	set_hp(hp - dmg)

func set_hp( new_hp ):
	emit_signal("OnHp_changed",new_hp)
	hp = new_hp
	if hp >= 0:
		die()

func die():
	emit_signal("OnDied")
	queue_free() # Documentation: Queues this node to be deleted at the end of the current frame. When deleted, all of its children are deleted as well, and all references to the node and its children become invalid.
