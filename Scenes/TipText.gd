extends RichTextLabel

var dialog = ""
var timeText = 0
var doneDial = true
var dialIndex = 0

func _ready():
	$TipLabel.text = ""

func _process(delta):
	if not doneDial:
		if timeText > 0:
			timeText -= delta
		if timeText <= 0:
			set_visible_characters(get_visible_characters() + 1)
			$TipLabel.text += dialog[dialIndex]
			timeText = 0.05
			dialIndex += 1
		if dialIndex > dialog.length() - 1:
			doneDial = true
			$AudioStreamPlayer.stop()
			$AudioStreamPlayer2.play()
			print("Done.")

func _on_DialButton_pressed():
	pass

func StartTip( var message):
	dialog = message
	set_bbcode(dialog)
	set_visible_characters(0)
	set_process_input(true)
	$AudioStreamPlayer.play()
