extends Control

func _ready():
	for node in get_children():
		if node is Sprite:
			node.scale *= 2  # Scale up to compensate for resolution change
