extends Control

@onready var game_over_screen := $"Game Over"
@onready var win_screen := $Win

func game_over():
	game_over_screen.visible = true
	
func win():
	win_screen.visible = true


func _on_button_retry_pressed():
	print("RetryPressed")
	get_tree().change_scene_to_file("res://Scenes/mapa_laberinto.tscn")
