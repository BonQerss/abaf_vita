extends Node2D

var secretTime = 0

func _process(delta):
	if secretTime >= 0:
		if secretTime >= 0.1:
			
			if get_tree().change_scene("res://Scenes/Menu.tscn") != OK:
				print("Scene load fail")
			secretTime = - 1
		else:
			secretTime += delta
