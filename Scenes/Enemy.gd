extends CharacterBody2D

const speed = 78
var lookLeft := false

var playerIn: bool = false
var playerSeen: bool = false
var chasing: bool = false
var can_be_stunned: bool = false
var stunned: bool = false

@export var positions: Array[Node2D]
var next_position: Node2D
var next_position_value: int = 0

@export var player: Node2D
var player_attack_CD : Timer = null
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var my_anim : AnimatedSprite2D = $"Enemy Sprites"
@onready var my_particle : CPUParticles2D = $"Enemy Sprites".get_node("Stun Particles")

func _ready():
	chasing = false
	$Timer.start()
	next_position_value = 1
	next_position = positions[0]
	
	player_attack_CD = player.get_node("Timer_AttackCD")

func _physics_process(_delta: float):
	
	#Raycast
	if playerIn == true:
		var space = get_viewport().world_2d.direct_space_state
		var result = space.intersect_ray(PhysicsRayQueryParameters2D.create(global_transform.origin, player.global_transform.origin))
		
		# Chasing
		if result.collider == player:
			if playerSeen == false:
				playerSeen = true
				
				player.speed_up()
				player.cannot_hide()
				chasing = true
				$Timer2.stop()
				$Timer.start()
		else:
			if playerSeen == true:
				playerSeen = false
				$Timer2.start()
	
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	if player and player.hiding == false || $Timer2.time_left == 0:
		if stunned == false:
			move_and_slide()
			#Anim
			if my_anim.animation != "Enemy_Walk":
				my_anim.play("Enemy_Walk")
				my_particle.visible = false
		else:
			my_anim.play("Enemy_Stun")
			my_particle.visible = true
			
	else:
		if my_anim.animation != "Enemy_Idle":
			my_anim.play("Enemy_Idle")
			my_particle.visible = false
	
	if dir.x <= -0.15:
		if lookLeft == false:
			$"Enemy Sprites".scale.x *= -1
			lookLeft = true
	if dir.x >= 0.15:
		if lookLeft == true:
			$"Enemy Sprites".scale.x *= -1
			lookLeft = false
	
	# De-stun
	if stunned == true && $Timer_Stun.time_left == 0:
		stunned = false
		can_be_stunned = true
		
	if chasing == true:
		# Get stunned idiot!
		if Input.is_action_just_pressed("Attack") && player_attack_CD.time_left == 0:
			stunned = true
			$Timer_Stun.start()
	else:
		#Patrol movement
		if global_position.distance_to(next_position.global_position) <= 5:
			if next_position_value < positions.size():
				next_position = positions[next_position_value]
				next_position_value += 1
			else:
				next_position = positions[0]
				next_position_value = 1
	

func make_path() -> void:
	if chasing:
		nav_agent.target_position = player.global_position
	else:
		nav_agent.target_position = next_position.global_position
	

func _on_timer_timeout():
	make_path()
	


func _on_area_2d_body_entered(body):
	can_be_stunned = true
	
	if body == player:
		playerIn = true
		print("in")
		
		if playerSeen == true:
			player.cannot_hide()
			chasing = true
			$Timer2.stop()
			$Timer.start()
		

func _on_area_2d_body_exited(body):
	
	if body == player:
		print("out")
		playerIn = false
		$Timer2.start()
		body.slow_down()
		player.Can_Hide()
		

func _on_timer_2_timeout():
	can_be_stunned = false
	playerIn = false
	chasing = false
	playerSeen = false
	player.slow_down()
	player.Can_Hide()

func _on_area_2d_vs_player_body_entered(body):
	if body == player:
		if player.was_attacked():
			player.take_dmg(1)
