extends Node

func PlayScare(which: int):
	match which:
		1:
			$Jumpscare1.pitch_scale = 1.0
			$Jumpscare1.play()
		2:
			$Jumpscare2.pitch_scale = 1.0
			$Jumpscare2.play()
		3:
			$Jumpscare1.pitch_scale = 0.94
			$Jumpscare1.play()
		4:
			$Jumpscare3.play()
		5:
			$JumpscareFan.play()
		6:
			$JumpscarePistol.play()
		7:
			$JumpscareLever.play()
		8:
			$JumpscareLight.play()
		9:
			$Jumpscare2.play()

func PlayHover():
	$ClickHover.play()

func PlayClick():
	$ClickConfirm.play()

func PlayQuickClick():
	$ClickQuick.play()

func PlayEscapeAmb(on: bool):
	if on:
		$EscapeAmb.play()
		$EscapeAmb.volume_db = -8.0
	else:
		$EscapeAmb.stop()

func PlayWavy():
	$Wavy.play()

func FadeEscape():
	$EscapeTween.interpolate_property($EscapeAmb, "volume_db", -8, -80, 24.0, 1, Tween.EASE_IN, 0)
	$EscapeTween.start()

func _on_EscapeTween_tween_completed(_object, _key):
	$EscapeAmb.stop()

func PlayIntro():
	$IntroMusic.play()

