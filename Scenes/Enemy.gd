extends CharacterBody2D

const speed = 35

var playerIn: bool = false
var playerSeen: bool = false
var chasing: bool = false

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var ray_cast = $RayCast2D

func _ready():
	
	pass
	

func _physics_process(_delta: float) -> void:
	
	#Raycast
	if playerIn == true:
		var space = get_viewport().world_2d.direct_space_state
		var result = space.intersect_ray(PhysicsRayQueryParameters2D.create(global_transform.origin, player.global_transform.origin))
		
		if result.collider == player:
			if playerSeen == false:
				playerSeen = true
				print("heyho")
				
				chasing = true
				$Timer2.stop()
				$Timer.start()
		else:
			if playerSeen == true:
				playerSeen = false
				$Timer2.start()
				print("nah")
	
	if chasing == true:
		# Chasing movement
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		$Timer.stop()
		

func make_path() -> void:
	nav_agent.target_position = player.global_position
	

func _on_timer_timeout():
	make_path()
	

func _on_area_2d_body_entered(body):
	if body == player:
		playerIn = true
		print("entered")
		
		if playerSeen == true:
			chasing = true
			$Timer2.stop()
			$Timer.start()
		

func _on_area_2d_body_exited(body):
	
	if body == player:
		playerIn = false
		$Timer2.start()
		print("exited")
		

func _on_timer_2_timeout():
	playerIn = false
	chasing = false
	playerSeen = false
	print("escaped")
	
