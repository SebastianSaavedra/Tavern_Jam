extends Control


func _on_button_retry_pressed():
	print("RetryPressed")
	get_tree().change_scene_to_file("res://Scenes/mapa_laberinto.tscn")
