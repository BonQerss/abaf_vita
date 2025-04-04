extends RichTextLabel

var dialog = ""
var dialogTexts = ["Man 1: They should be all ready to go now.", "Man 2: Yeah mister, they haven't moved this good since yesteryear!", "Man 2: Like that whole thing with Chica shootin' an iron, what the world?", "Man 2: I ain't understand a lick of it, but it sure is somethin'. Thank you kindly.", "Man 1: Well, I must be off now.", "Man 2: Say, how about you stay around a bit? I cook a mean [unintelligible]", "Man 1: I have to go, sorry."]

var page = - 1
var timeText = 0
var doneDial = true
var dialIndex = 0

var timeDial = - 1

func _ready():
	$ManLabel.text = ""

func _process(delta):
	if not doneDial:
		if timeText > 0:
			timeText -= delta
		if timeText <= 0:
			set_visible_characters(get_visible_characters() + 1)
			$ManLabel.text += dialog[dialIndex]
			timeText = 0.05
			dialIndex += 1
		if dialIndex > dialog.length() - 1:
			doneDial = true
			print("Done.")
	
	if timeDial > - 1:
		if timeDial >= 4:
			if page < dialogTexts.size() - 1:
				StartTip()
			else:
				print("Bye bye!")
				visible = false
				timeDial = - 1
		else:
			timeDial += delta

func _on_DialButton_pressed():
	pass

func StartTip():
	$ManLabel.text = ""
	dialIndex = 0
	page += 1
	dialog = dialogTexts[page]
	set_bbcode(dialog)
	set_visible_characters(0)
	timeDial = 0
	doneDial = false
