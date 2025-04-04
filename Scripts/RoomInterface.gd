extends Node2D

func DisableInterface( var on):
	if on:
		$ToolButtons / ConveyorButton.set_mouse_filter(2)
		$ToolButtons / LightButton.set_mouse_filter(2)
		$ToolButtons / PistolButton.set_mouse_filter(2)
		$ToolButtons / FoodButton.set_mouse_filter(2)
		$SecretButtons.visible = false
	else:
		$ToolButtons / ConveyorButton.set_mouse_filter(0)
		$ToolButtons / LightButton.set_mouse_filter(0)
		$ToolButtons / PistolButton.set_mouse_filter(0)
		$ToolButtons / FoodButton.set_mouse_filter(0)
		$SecretButtons.visible = true

func _on_CameraSystem_disable_interface(camsOn):
	DisableInterface(camsOn)

func _on_Center_pistol_activated(act):
	DisableInterface(act)
	if act:
		$ToolButtons / PistolButton / AudioStreamPlayer2.play()
	else:
		$ToolButtons / PistolButton / AudioStreamPlayer3.play()

func _on_Center_shocker_activated(act):
	$SecretButtons.visible = not act

func EnableLightButton():
	$ToolButtons / LightButton.set_mouse_filter(0)

func DisableLightButton():
	$ToolButtons / LightButton.set_mouse_filter(2)

func DisableConveyor():
	$ToolButtons / ConveyorButton.set_mouse_filter(2)

func EnableConveyor():
	$ToolButtons / ConveyorButton.set_mouse_filter(0)

func EnablePistol():
	$ToolButtons / PistolButton.set_mouse_filter(0)

func EnableFood():
	$ToolButtons / FoodButton.set_mouse_filter(0)

func EnableLightBox( var isOn):
	$LightBoxButton.visible = isOn

func EnableRepairEnter( var isOn):
	$EnterRepairButton.visible = isOn

func EnableHallEnter( var isOn):
	$EnterHallButton.visible = isOn

func _on_ChickenButton_pressed():
	if not $SecretButtons / ChickenButton / AudioStreamPlayer2D.playing:
		$SecretButtons / ChickenButton / AudioStreamPlayer2D.play()

func _on_FbCreepoButton_pressed():
	if not $SecretButtons / FbCreepoButton / AudioStreamPlayer2D.playing:
		$SecretButtons / FbCreepoButton / AudioStreamPlayer2D.play()

func _on_PuButton_pressed():
	if not $SecretButtons / PuButton / AudioStreamPlayer2D.playing:
		$SecretButtons / PuButton / AudioStreamPlayer2D.play()

func _on_PaperButton_pressed():
	if not $SecretButtons / PaperButton / AudioStreamPlayer2D.playing:
		$SecretButtons / PaperButton / AudioStreamPlayer2D.play()

func _on_SmokeButton_pressed():
	if not $SecretButtons / SmokeButton / AudioStreamPlayer2D.playing:
		$SecretButtons / SmokeButton / AudioStreamPlayer2D.play()

func _on_MugButton_pressed():
	if not $SecretButtons / MugButton / AudioStreamPlayer2D.playing:
		$SecretButtons / MugButton / AudioStreamPlayer2D.play()

func _on_NoButton_pressed():
	if not $SecretButtons / NoButton / AudioStreamPlayer2D.playing:
		$SecretButtons / NoButton / AudioStreamPlayer2D.play()

func _on_CandyButton_pressed():
	if not $SecretButtons / CandyButton / AudioStreamPlayer2D.playing:
		$SecretButtons / CandyButton / AudioStreamPlayer2D.play()

func _on_DeadFredButton_pressed():
	if not $SecretButtons / DeadFredButton / AudioStreamPlayer2D.playing:
		$SecretButtons / DeadFredButton / AudioStreamPlayer2D.play()
