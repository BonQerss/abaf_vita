extends Node2D

var hitTop = false
var scrollSpeed = 50

func _ready():
	if SceneControl.musicOn:
		$AudioStreamPlayer.play()
	else:
		$AudioStreamPlayer2.play()

func _process(delta):
	if not hitTop:
		$Scroller.position.y -= delta * scrollSpeed
	
	if $Scroller.position.y <= - 3102:
		hitTop = true
		SoundController.PlayEscapeAmb(false)
		SceneTransition.NextScene("res://Scenes/Menu.tscn", self)

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_pressed("ui_accept"):
		scrollSpeed = 174
	
	if Input.is_action_just_released("ui_accept"):
		scrollSpeed = 58

func _on_BurgButton_pressed():
	if not $Scroller / BurgButton / AudioStreamPlayer.playing:
		$Scroller / BurgButton / AudioStreamPlayer.play()
