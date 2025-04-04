extends Node2D

var timeScene = 0.0
var crowbarStart = false
var introMusStart = false

func _ready():
	if SceneControl.performant:
		$BackBufferCopy / BlurRect.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$FlickRect.visible = true
	SoundController.PlayIntro()

func _process(delta):
	#print("Static RAM:", OS.get_static_memory_usage())
	#print("Dynamic RAM:", OS.get_dynamic_memory_usage())
	if timeScene >= 0:
		if timeScene >= 5:
			$FogRect / AnimationPlayer.play("Distort")
			SoundController.PlayWavy()
			timeScene = - 1
		elif timeScene >= 2.0 and not crowbarStart:
			$AudioStreamPlayer2.play()
			$IntroSting.play()
			crowbarStart = true
		else:
			timeScene += delta
		
		if timeScene >= 2.8 and not introMusStart:
			introMusStart = true

func StartAnim():
	$AnimBack.play("attack")
	$AudioStreamPlayer.play()

func EndAttack():
	if get_tree().change_scene("res://Scenes/Aware.tscn") != OK:
		print("Scene load fail")
