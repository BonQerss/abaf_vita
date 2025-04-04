extends Node2D

var crawlTime = 0.0
var newsTime = - 1.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	if crawlTime >= 0:
		if crawlTime >= 5:
			$FadeRect / AnimationPlayer.play("FadeIn")
			crawlTime = - 1.0
		else:
			crawlTime += delta
	
	if newsTime >= 0:
		if newsTime >= 34 or (newsTime >= 4 and Input.is_action_just_pressed("ui_mouse_left")):
			SceneTransition.NextScene("res://Scenes/Credits.tscn", self)
		else:
			newsTime += delta

func FadeDone():
	$NewsSprite / AnimationPlayer.play("NewsIn")
	newsTime = 0.0
	$FadeRect / AnimationPlayer.play("FadeOut")
	$NewsSprite / AudioStreamPlayer.play()
	$BackSprite / AudioStreamPlayer.stop()
	$EscapeAmb.volume_db = - 12

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
