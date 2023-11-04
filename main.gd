extends Node2D

# scroll pos when button press starts
var startScrollPos

@onready var levelImageButtons = $ScrollContainer/VBoxContainer/MarginContainer/level_images.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	var buttons = levelImageButtons
	# scrolling to a node. This works pretty well...
#	await get_tree().process_frame
#	$ScrollContainer.ensure_control_visible($ScrollContainer/VBoxContainer/MarginContainer/level_images/"02")
	
#	print('02??: ', get_level_button_node("02"))
#	scroll_to_level_img('02')


	if Global.next_level:
		scroll_to_level_img(Global.next_level)
	
	for button in buttons:
		print('button', button)
		button.connect('button_down', on_button_down)
		button.connect('button_up', on_button_up.bind(button.get_name()))
		
		
	# dynamically add the click events with the click params...
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_button_down():
	startScrollPos = $ScrollContainer.scroll_vertical

func on_button_up(level_to_load):
	print('UP', $ScrollContainer.scroll_vertical)
	var endScrollPos = $ScrollContainer.scroll_vertical
	
	# if we're scrolling, ignore the button click
	# abs() ensures the number is positive
	if abs(endScrollPos - startScrollPos) > $ScrollContainer.scroll_deadzone:
		return
	
	# am I scrolling? If yes. Ignore
	
	print('load_level: ', level_to_load)
	Global.change_scene(level_to_load)




func _on_play_button_up():
	scroll_to_level_img("01")
#	var tween = get_tree().create_tween().set_parallel(false)


#	tween.tween_property($ScrollContainer, "scroll_vertical", 1100, .9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)
	
	
func get_level_button_node(levelNum: String) -> TextureButton:
	# only expect one result to match, so we'll return that
	return levelImageButtons.filter(func(node): return node.name == levelNum)[0]
	
	
# animated scroll to the element
# needs to be string because it's left padded with zero
func scroll_to_level_img(levelNum: String):	
	var buffer = 100
	
	# get global Y position of the level img we want to scroll to, then add a little buffer
	var node: TextureButton = get_level_button_node(levelNum)
	
	
	await get_tree().process_frame # needed so physics can calc the real position
	
	var targetYPos =  node.get_global_rect().position.y
	
	var tween = get_tree().create_tween().set_parallel(false)
	tween.tween_property($ScrollContainer, "scroll_vertical", targetYPos - buffer, .9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)
