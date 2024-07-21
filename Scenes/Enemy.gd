extends CharacterBody2D

const speed = 35

var playerIn: bool = false
var playerSeen: bool = false
var chasing: bool = false

@export var positions: Array[Node2D]
var next_position: Node2D
var next_position_value: int = 0

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _ready():
	chasing = false
	$Timer.start()
	next_position_value = 1
	next_position = positions[0]
	

func _physics_process(_delta: float):
	
	#Raycast
	if playerIn == true:
		var space = get_viewport().world_2d.direct_space_state
		var result = space.intersect_ray(PhysicsRayQueryParameters2D.create(global_transform.origin, player.global_transform.origin))
		
		# Chasing
		if result.collider == player:
			print(player)
			if playerSeen == false:
				playerSeen = true
				print("heyho")
				
				player.speed_up()
				player.cannot_hide()
				chasing = true
				$Timer2.stop()
				$Timer.start()
		else:
			print ("not player")
			if playerSeen == true:
				playerSeen = false
				$Timer2.start()
				print("nah")
	
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	if player.hiding == false || $Timer2.time_left == 0:
		move_and_slide()
	
	if chasing == true:
		pass
	else:
		#Patrol movement
		if global_position.distance_to(next_position.global_position) <= 5:
			if next_position_value < positions.size():
				next_position = positions[next_position_value]
				next_position_value += 1
				print("next pos")
			else:
				next_position = positions[0]
				next_position_value = 1
				print("reset")
		

func make_path() -> void:
	if chasing:
		nav_agent.target_position = player.global_position
	else:
		nav_agent.target_position = next_position.global_position
		pass
	

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
		body.slow_down()
		player.Can_Hide()
		print("exited")
		

func _on_timer_2_timeout():
	playerIn = false
	chasing = false
	playerSeen = false
	player.slow_down()
	player.Can_Hide()
	print("escaped")
	
