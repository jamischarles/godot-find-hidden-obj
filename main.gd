extends Node2D

# scroll pos when button press starts
var startScrollPos

# Called when the node enters the scene tree for the first time.
func _ready():
	var buttons = $ScrollContainer/VBoxContainer/MarginContainer/level_images.get_children()
	
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
	get_tree().change_scene_to_file("res://%s/stage.tscn" % level_to_load)




func _on_play_button_up():
	var tween = get_tree().create_tween().set_parallel(false)


	tween.tween_property($ScrollContainer, "scroll_vertical", 1100, .9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)
#	tween.tween_property(shape, "scale", Vector2(1.5,1.5), .15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#	tween.tween_property(shape, "scale", Vector2(1,1), .1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#	tween.tween_property(shape, "modulate", Color(0.65,.1,.86, 0), .1).set_ease(Tween.EASE_OUT)
	
#	tween.tween_property(self, "scale", Vector2(), 1)
#	tween.tween_property(self, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
	
#	shape.z_index = 0 # reset back down
		
	# don't remove it since we only have one
#	tween.tween_callback(on_tween_done)
#	print('SCROLL')
#	$ScrollContainer.scroll_vertical=600
