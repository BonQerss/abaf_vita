extends Node2D

var tempTime = 0
var fbGlitchTime = 0
var tbSlideStart = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if SceneControl.musicOn:
		$AudioStreamPlayer2.play()

func _process(delta):
	if tempTime >= 0:
		if tempTime > 20:
			SceneTransition.NextScene("res://Scenes/Menu.tscn", self)
			tempTime = - 1
		elif tempTime >= 13 and not tbSlideStart:
			$TbSprite / AnimationPlayer.play("SlideIn")
			$TbSprite / AudioStreamPlayer2D.play()
			tbSlideStart = true
		else:
			tempTime += delta
	
	if tbSlideStart:
		if fbGlitchTime > 0.04:
			$TbSprite / AudioStreamPlayer2D.pitch_scale = rand_range(0.8, 1.2)
			fbGlitchTime = 0
		else:
			fbGlitchTime += delta
