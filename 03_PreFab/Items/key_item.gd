extends Node2D

@export var player : CharacterBody2D = null
@onready var container : Node2D = $Container
@onready var col_area : CollisionShape2D = $Container/Area2D/CollisionShape2D
@onready var pickup_fx : Node2D = $PickUp_FX
@onready var fx_text : CPUParticles2D = $"PickUp_FX/Text Particles"
@onready var fx_item : CPUParticles2D = $"PickUp_FX/item Particles"

func _ready():
	pickup_fx.visible = false

func _on_area_2d_body_entered(body):
	if body == player && col_area.disabled == false:
		player.gain_key_item()
		
		container.visible = false
		col_area.disabled = true
		
		pickup_fx.visible = true
		fx_text.emitting = true
		fx_item.emitting = true
		pickup_fx.get_node("pickSFX").playing = true
		#queue_free()
