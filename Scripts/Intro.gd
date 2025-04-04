extends Node2D

var timeScene = 0.0
var zoomStart = false
var clickStart = false
var circleStart = false
var clicked = false
var startLeave = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) 
	$Zoom.visible = false
	$NewsFar.visible = true
	if SceneControl.musicOn:
		$AudioStreamPlayer.play()

func _process(delta):
	if timeScene >= 30 and not startLeave:
		SceneTransition.NextScene("res://Scenes/Main.tscn", self)
		$ClickLab / AnimationPlayer.play("ClickOut")
		startLeave = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		timeScene += delta
	
	if not zoomStart and timeScene >= 2.0:
		zoomStart = true
		$Zoom.visible = true
		$NewsFar.visible = false
		$Zoom.play("zoom")
	
	if not clickStart and timeScene >= 4.0:
		clickStart = true
	
	if not circleStart and timeScene >= 26:
		$RedCircle / AnimationPlayer.play("Circle")
		circleStart = true
		clicked = true

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if (Input.is_action_just_pressed("ui_mouse_left") or Input.is_action_just_pressed("confirm")) and clickStart and not clicked:
		timeScene = 26
		clicked = true

func _on_Zoom_animation_finished():
	if $Zoom.animation == "zoom":
		$NewsClose / AnimationPlayer.play("HQIn")
