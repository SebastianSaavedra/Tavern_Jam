extends CharacterBody2D

const speed = 35

var playerIn: bool = false
var chasing: bool = false

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _ready():
	make_path()
	

func _physics_process(_delta: float) -> void:
	if chasing == true:
		# Get path and move
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		move_and_slide()
		

func make_path() -> void:
	nav_agent.target_position = player.global_position
	

func _on_timer_timeout():
	make_path()
	

func _on_area_2d_body_entered(body):
	if body == player:
		$Timer2.stop()
		playerIn = true
		chasing = true
		print(body)
		

func _on_area_2d_body_exited(body):
	if body == player:
		$Timer2.start()
		print(body)
		

func _on_timer_2_timeout():
	playerIn = false
	chasing = false
	print("escaped")
	
