extends Node2D

var wasMouseHidden = false
var ableAccess = true

func _ready():
	if SceneControl.fullScreen == false:
		$CheckBox.pressed = false

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and SceneTransition.doneFadeout:
		if ableAccess:
			get_tree().paused = not get_tree().paused
			visible = not visible
			if get_tree().paused:
				if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
					wasMouseHidden = true
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				if OS.window_fullscreen:
					$CheckBox.pressed = true
				else:
					$CheckBox.pressed = false
			if not get_tree().paused:
				_on_ResumeButton_mouse_exited()
				_on_MenuButton_mouse_exited()
				_on_ExitButton_mouse_exited()
				if wasMouseHidden:
					Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
					wasMouseHidden = false
			print("Detected")
		else:
			get_tree().quit()

func _on_ExitButton_pressed():
	SoundController.PlayClick()
	get_tree().quit()

func _on_ResumeButton_pressed():
	SoundController.PlayClick()
	get_tree().paused = false
	visible = false
	_on_ResumeButton_mouse_exited()
	if wasMouseHidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		wasMouseHidden = false

func _on_MenuButton_pressed():
	
	SoundController.PlayClick()
	if SceneControl.currentLevel > 3:
		SceneControl.currentLevel = SceneControl.prevLevel
	SceneControl.customActivity = [0, 0, 0, 0, 0]
	if get_tree().change_scene("res://Scenes/Menu.tscn") != OK:
		print("Scene load fail")

func _on_ResumeButton_mouse_entered():
	$CenterContainer / VBoxContainer / ResumeButton / ResumeLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_MenuButton_mouse_entered():
	$CenterContainer / VBoxContainer / MenuButton / MenuLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ExitButton_mouse_entered():
	$CenterContainer / VBoxContainer / ExitButton / ExitLabel.modulate.a = 0.25
	SoundController.PlayHover()

func _on_ResumeButton_mouse_exited():
	$CenterContainer / VBoxContainer / ResumeButton / ResumeLabel.modulate.a = 1.0

func _on_MenuButton_mouse_exited():
	$CenterContainer / VBoxContainer / MenuButton / MenuLabel.modulate.a = 1.0

func _on_ExitButton_mouse_exited():
	$CenterContainer / VBoxContainer / ExitButton / ExitLabel.modulate.a = 1.0

func _on_CheckBox_pressed():
	if OS.window_fullscreen:
		SceneControl.SetWindowSmall()
	else:
		SceneControl.SetWindowLarge()
	$AudioStreamPlayer.play()
