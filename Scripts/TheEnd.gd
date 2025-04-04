extends Control

var crawlDone = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimatedSprite.play("default")

func DoneCrawl():
	if not crawlDone:
		SceneTransition.NextScene("res://Scenes/Reward.tscn", self)
		crawlDone = true
