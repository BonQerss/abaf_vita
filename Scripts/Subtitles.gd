extends RichTextLabel

var dialog = []
var dialog1 = ["Howdy, welcome to [color=#ff8259]Freddy Fazbear’s Grill[/color]!", "Today we'll be testing our old food delivery system.\n\nWe need to run through its course a few times, from kitchen to customer.", "I'll be up in the [color=#33beff]Kitchen[/color] making orders, putting them on the delivery system's conveyor belt.\n\nThey'll be sent down to [color=#33beff]Party Room A[/color], then [color=#33beff]Party Room B[/color], and then finally your [color=#33beff]Office[/color].", "I need you to [color=#fffc33]confirm[/color] orders as they arrive in these rooms.\n\nRooms can be viewed using the [color=#ff8833]camera system[/color], which lets you check up on anything in the building.", "Conveyor openings, seen in the Kitchen and Party Rooms, can be closed remotely on their cameras with button-activated [color=#ff8833]doors[/color].\n\nThey'll [color=#ff4733]pause[/color] incoming orders while closed.", "There's an order status indicator to the left of your office.\n\nOnce it says \"[color=#fffc33]Delivered[/color]\", find the order in the building and confirm its arrival.", "If anything's acting up with the conveyor, you can [color=#ff4733]stop[/color] it using the [color=#ff8833]lever[/color] to your left.\n\nThis will stop progress on any incoming orders.", "Some of the tools in your office run on a makeshift power setup. It ain't too stable.\n\nGiven a mighty push, the power could [color=#ff4733]overload[/color] and need a full reboot before the equipment is usable again.", "As a heads up, you might see some robot critters moving 'round the building.\n\nDon’t worry, they won’t bite! They're just taking a stretch.", "Just switch off those [color=#ff8833]lights[/color] to your right if you want to be left alone, makes 'em scurry on.", "If you see that cow-bird [color=#feff74]Chica[/color] swing by, pick up that [color=#ff8833]toy pistol[/color] on your desk to activate her new showdown mode.\n\nIf you're quick and aim between the [color=#fffc33]eyes[/color] you might even win a free soda!", "Alrighty now, let’s get a move on!"]




var dialog2 = ["What in the world, did that old bulb blow up?", "There should be a box with a spare bulb in the office somewhere, if you could swap that out for me real quick."]
var dialog3 = ["Thanks, it's about time that bulb got replaced.\n\nSay, ain't it getting a little stuffy 'round here to you?", "We got a nice [color=#ff8833]vent fan[/color] to really help freshen up this air.\n\nIt's right above your office. Ain't that nice?", "It's connected to the camera system, feel free to give it a try. It gets awful dusty up in those vents.", "Now, let's get some more orders going!"]
var dialog4 = ["Think I heard some of them rusty screws pop out in the conveyor.", "My hat's too big to fit inside there, so if you could head in and swap 'em out for me that'd be mighty nice.\n\nI'll shut down the conveyor from my side."]
var dialog5 = ["Okay this is it, last run through the orders!", "If the cameras start having trouble, give them a [color=#ff8833]refresh[/color] through the [color=#33beff]Back Stage[/color] camera.\n\nIf a robot messes with them old wires in the back, a refresh could [color=#feff74]shock[/color] 'em away.", "Then if the cameras get completely [color=#ff4733]frozen[/color] up, you can switch to [color=#ff8833]backup[/color].\n\nThis puts it on that rickety office power, so best keep 'em refreshed.", "Get ready, last round of orders a-coming!"]
var dialog6 = ["Okay, that's all we need to do! Thanks for the help.", "Head over to the dining area and I'll get you on your way."]
var dialog7 = ["You’re awfully committed ain’t ya—or are you just lookin’ for another bite?\n\nI’m gonna try whipping up something real nice to top it all off!", "I tell ya, back in the day this place was jumping!\n\nWe had families in and out all day, new shows, events, the whole works.", "It all changed after [color=#D8413C][shake rate=5.0 level=6]the bite[/shake][/color] happened.\n\nSome kid went up and bit a huge chunk right out of Fredbear's face.\n\nTore it right off.", "Now he just sits there all alone on his little stage inside the wall, slowly wearing away.\n\nThe crew thinks he ought to be called [color=#FFCA47]Threadbear[/color]. A bit crooked ain’t it?", "Oh, one more thing—sometimes the conveyor gets [color=#ff4733]jammed[/color] around the [color=#33beff]Party Rooms[/color].\n\nIf that happens just stop the conveyor for a little bit, and it'll restart itself.", "Also, remember to refresh those cameras when they're acting up.\n\nCan't be too sure of 'em, could lose your [color=#ff4733]connection[/color].", "Anywho, pardon my wobblin’ jaw, let's get ‘er going!"]


var dialog8 = ["I think that wraps everything up.", "Thanks for playing!", "(Maybe go to cutscene instead of this dialogue set)"]
var dialog9 = ["The conveyor seems to be stuck, can't be shut down or nothing.\n\nBe mighty careful, don't try to be crawling in there."]
var dialog10 = ["I tell ya, the power setup ain't working right today.\n\nSometimes an awful buzzing starts when one of them robots is near anything electrical.", "Our technician left behind a device that seems to fix this problem.\n\nIt gives a little [color=#FF6E00]shock[/color] and stops that buzzing.", "If you hear a tool buzzing in your [color=#33beff]Office[/color] or in the [color=#33beff]Vents[/color], try using this device on it.\n\nJust don't touch anything buzzing, don't want no one getting hurt."]
var dialog11 = ["We're gonna have a little challenge today.\n\nLet's see if we can get through double the orders in less time.", "In fact, I put a cover over my head to really show this off!\n\nThis will be a piece of pecan pie."]
var dialog12 = ["So, bit of a situation today.\n\nThe heater's broken and I'm freezing my boots off.", "Them wires in the back might freeze up in these temperatures.\n\nTry refreshing the cameras, might give off just enough heat to keep it running.", "Let's make this quick and get outta here."]
var dialog13 = ["It's time for a real challenge.\n\nWhen it's lunch hour and we've got a hungry swarm coming through here, we need to be ready.", "I'll be sending out orders real quick between the party rooms. Get ready!"]
var dialog14 = ["The repair crew added a new power saving feature.\n\nYou can disconnect some of the camera system tools to reduce overload risk.", "That's all, let's go!"]

var page = 0
var startDial = false
var typeTime = 0
var readyNext = false
var currentDial = 0
var walkX = false

signal dialog_finished()
signal pages_finished()
signal chars_finished()
signal chars_started()

func _ready():
	pass

func _process(delta):
	if startDial:
		if typeTime > 0:
			typeTime -= delta
		else:
			if not readyNext:
				if get_visible_characters() <= get_total_character_count():
					set_visible_characters(get_visible_characters() + 1)
					typeTime = 0.03
				else:
					readyNext = true
					emit_signal("chars_finished")
					$mgrStatic.stop()

func _on_DialButton_pressed():
	if get_visible_characters() > get_total_character_count():
		if page < dialog.size() - 1:
			page += 1
			set_bbcode(dialog[page])
			set_visible_characters(0)
			readyNext = false
			var tutImg = 0
			$mgrStatic.play()
			
			match (page):
				1:
					match (currentDial):
						1:
							$mgr4Player.play()
							tutImg = 1
						2:
							$mgr4Player.play()
						3:
							$mgr4Player.play()
							tutImg = 4
						4:
							$mgr14Player.play()
						5:
							$mgr3Player.play()
							tutImg = 5
						6:
							$mgr2Player.play()
						7:
							$mgr10Player.play()
						10:
							$mgr4Player.play()
							tutImg = 7
						11:
							$mgr8Player.play()
						12:
							$mgr18Player.play()
						13:
							$mgr17Player.play()
						14:
							$mgr2Player.play()
				2:
					match (currentDial):
						1:
							$mgr7Player.play()
							tutImg = 13
						3:
							$mgr3Player.play()
						5:
							$mgr6Player.play()
							tutImg = 14
						7:
							$mgr6Player.play()
						10:
							$mgr3Player.play()
						12:
							$mgr18Player.play()
				3:
					match (currentDial):
						1:
							$mgr3Player.play()
							
							tutImg = 11
							
						3:
							$mgr7Player.play()
						5:
							$mgr7Player.play()
						7:
							$mgr13Player.play()
							tutImg = 16
				4:
					if currentDial < 6:
						$mgr5Player.play()
						tutImg = 12
					elif currentDial == 7:
						$mgr5Player.play()
						tutImg = 15
					else:
						pass
				5:
					if currentDial < 6:
						$mgr4Player.play()
						tutImg = 8
					elif currentDial == 7:
						$mgr3Player.play()
						tutImg = 17
					else:
						pass
				6:
					if currentDial < 6:
						$mgr14Player.play()
						tutImg = 9
					elif currentDial == 7:
						$mgr12Player.play()
					else:
						pass
					if currentDial == 1:
						
						pass
				7:
					if currentDial < 6:
						$mgr6Player.play()
					else:
						pass
				8:
					if currentDial < 6:
						$mgr8Player.play()
					else:
						pass
				9:
					if currentDial < 6:
						tutImg = 10
						$mgr3Player.play()
				10:
					if currentDial < 6:
						$mgr5Player.play()
						tutImg = 3
				11:
					if currentDial < 6:
						$mgr2Player.play()
			emit_signal("chars_started", tutImg)
		else:
			$mgrStatic.stop()
			emit_signal("pages_finished")
	else:
		$mgrSkip.play()
		set_visible_characters(get_total_character_count())

func BeginDial():
	startDial = true
	set_bbcode(dialog[page])
	set_visible_characters(0)
	set_process_input(true)
	walkX = true
	match (currentDial):
		1:
			$AudioStreamPlayer.play()
		2:
			$mgr16Player.play()
		3:
			$mgr15Player.play()
		4:
			$mgr6Player.play()
		5:
			$mgr4Player.play()
		6:
			$mgr17Player.play()
		7:
			$mgr9Player.play()
		9:
			$mgr14Player.play()
		10:
			$mgr6Player.play()
		11:
			$mgr2Player.play()
		12:
			
			pass
		13:
			$mgr7Player.play()
		14:
			$mgr4Player.play()
	$mgrStatic.play()

func EndDial():
	emit_signal("dialog_finished")
	startDial = false
	readyNext = false
	set_visible_characters(0)
	set_process_input(false)
	$mgrStatic.stop()

func SetDialText( var which):
	match (which):
		0:
			
			dialog = dialog1
		1:
			
			dialog = dialog2
		2:
			
			dialog = dialog3
		3:
			
			dialog = dialog4
		4:
			
			dialog = dialog5
		5:
			
			dialog = dialog6
		6:
			
			dialog = dialog7
		7:
			
			dialog = dialog8
		8:
			
			dialog = dialog9
		9:
			
			dialog = dialog10
		10:
			
			dialog = dialog11
		11:
			
			dialog = dialog12
		12:
			
			dialog = dialog13
		13:
			
			dialog = dialog14
	page = 0
	typeTime = 0
	currentDial = which + 1
