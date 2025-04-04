extends Node2D




var fadeOn = false
var sceneChosen = false
var autoTime = 0

func _ready():
	if SceneControl.currentLevel > 0:
		$WarnLab3.visible = false

func _process(delta):
	if not sceneChosen and autoTime >= 0:
		if autoTime >= 8 and SceneControl.currentLevel > 0:
			ChooseScene()
			autoTime = - 1
		else:
			autoTime += delta

func _input(event):
	if not fadeOn and not sceneChosen and autoTime > 1:
		if Input.is_action_just_pressed("ui_mouse_left") or Input.is_action_just_pressed("confirm") or (event.is_pressed() and SceneControl.currentLevel > 0):
			ChooseScene()

func ChooseScene():
	print("Current level: " + str(SceneControl.currentLevel))
	if SceneControl.currentLevel == 0:
		SceneTransition.NextScene("res://Scenes/Attack.tscn", self)
	else:
		SceneTransition.NextScene("res://Scenes/Menu.tscn", self)
	
	sceneChosen = true
