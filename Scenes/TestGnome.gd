extends CharacterBody2D

@export var max_speed := 100
@export var speed_up_speed := 200
var start_speed := 100
@export var acceleration := 50
@export var friction := 40
var can_move := true
var moving := false

var can_attack := false

var can_hide := true
var in_hide_area := false
var hiding := false

var lookLeft := false

var anim_in_progress := false
@onready var anim_body : AnimatedSprite2D = $"Player Sprites".get_node("player_BodySprite")
@onready var anim_hat : AnimatedSprite2D = $"Player Sprites".get_node("PlayerHatSprite")
@onready var anim_attack : AnimationPlayer = $"Player Sprites".get_node("Attack").get_node("Attack_Anim")
@onready var magic_glow : PointLight2D = $"Player Sprites".get_node("Magic_ON").get_node("PointLight2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	start_speed = max_speed
	can_move = true
	
	can_hide = true
	in_hide_area = false
	hiding = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Input direction to movement
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction.x:
		#Avoid 1frame-turn-arround bug
		if direction.x * velocity.x >= 0:
			#Accelerate
			velocity.x = move_toward(velocity.x, direction.x * max_speed, acceleration)
		else:
			#On turn around: Decelaretion based on friction, not acceleration
			velocity.x = move_toward(velocity.x, direction.x * max_speed, friction)
	else:
		velocity.x = move_toward(velocity.x, direction.x * max_speed, friction)
	
	if direction.y:
		#Avoid 1frame-turn-arround bug
		if direction.y * velocity.y >= 0:
			#Accelerate
			velocity.y = move_toward(velocity.y, direction.y * max_speed, acceleration)
		else:
			#On turn around: Decelaretion based on friction, not acceleration
			velocity.y = move_toward(velocity.y, direction.y * max_speed, friction)
	else:
		velocity.y = move_toward(velocity.y, direction.y * max_speed, friction)
	
	if can_move == true:
		move_and_slide()
		
	#Anims
	if $Timer_Anim.time_left == 0:
		$Timer_Anim.wait_time = 1
		$Timer_Anim.start()
		$Timer_Anim.paused = true
		anim_in_progress = false
		if direction != Vector2(0,0):
			moving = false
		else:
			moving = true
	if direction != Vector2(0,0) && moving == false && anim_in_progress == false && hiding == false:
		moving = true
		anim_body.play("Player_Walk")
		anim_hat.play("Hat_Walk")
		
	if direction == Vector2(0,0) && moving == true && anim_in_progress == false && hiding == false:
		moving = false
		anim_body.play("Player_Idle")
		anim_hat.play("Hat_Idle")
		
	
	# Hide Action
	if hiding == false && can_hide == true && in_hide_area == true && Input.is_action_just_pressed("Hide"):
		start_hiding()
		
	elif hiding == true && Input.is_action_just_pressed("Hide"):
		stop_hiding()
		
	
	#Attack Action
	if Input.is_action_just_pressed("Attack") && $Timer_AttackCD.time_left == 0:
		magic_glow.enabled = false
		$Timer_AttackCD.start()
		stop_hiding()
		can_attack = false
		# Anims
		anim_attack.play("AttackPlayer")
		anim_body.play("Player_Attack")
		anim_hat.play("Hat_Attack")
		start_anim(0.9)
		
	if $Timer_AttackCD.time_left == 0 && can_attack == false:
		print("can attack")
		magic_glow.enabled = true
		can_attack = true
	
	
	# Sprite Flip
	if direction.x <= -0.15:
		if lookLeft == false:
			$"Player Sprites".scale.x *= -1
			lookLeft = true
	if direction.x >= 0.15:
		if lookLeft == true:
			$"Player Sprites".scale.x *= -1
			lookLeft = false
		
func start_anim(timer):
		anim_in_progress = true
		$Timer_Anim.paused = false
		$Timer_Anim.wait_time = timer
		$Timer_Anim.start()


func start_hiding():
	can_attack = false
	can_move = false
	hiding = true
	anim_in_progress = true
	anim_body.play("Player_Hidden")
	anim_hat.play("Hat_Hidden")
	print("g'bye")
		
func stop_hiding():
	can_attack = true
	anim_in_progress = false
	can_move = true
	hiding = false
	print("yo")
		
	
func cannot_hide():
	can_hide = false
	print("cant h")

func Can_Hide():
	can_hide = true
	print("can h")
		
func speed_up():
	max_speed = speed_up_speed
	
func slow_down():
	max_speed = start_speed


func _on_area_2d_body_entered(body):
	in_hide_area = true
	print("h area")

func _on_area_2d_body_exited(body):
	in_hide_area = false
	print("no h area")
