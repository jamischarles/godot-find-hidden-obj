extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_touch_screen(newPosition:Vector2):
	
	# move circle
	position = newPosition
	
	scale = Vector2(0, 0)
	
	modulate = Color(1,1,1, 0)
	
	# fade and bounce in
	
	# hide
	print('###on_touch_screen')
	## 2) Tween
	var tween = get_tree().create_tween().set_parallel(false)
#	tween.tween_property(self, "modulate", Color.RED, 3).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_property(self, "modulate", Color(0.11,1,1,.5), .2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(0.65,.1,.86,.5), .1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.5,0.5), .3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(0.65,.1,.86, 0), .1).set_ease(Tween.EASE_OUT)
	
#	tween.tween_property(self, "scale", Vector2(), 1)
#	tween.tween_property(self, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
	
	# don't remove it since we only have one
	tween.tween_callback(on_tween_done)


func on_tween_done():
	print('tween DONE')

#func _on_canvas_container_gui_input(event):
#	on_touch_screen() # Replace with function body.
var clickStartPos
var click_circle_pos
func _on_canvas_container_gui_input(event):
#	print('event', event)

	# we COULD use this to listen for dragging, but we'd still need the distance logic we have 
	# below. Not sure this simplifies anything
#	if event.get_class() == "InputEventScreenDrag":
#		print("DRAG")
#
	## The drag sensitivity here should match the sensitivity on the scrolling 
	## (scroll deadzone on the ScrollContainer) node...

	if event.get_class() == "InputEventScreenTouch":
#		print("TOUCH")
	
		if event.is_pressed():
			clickStartPos = event.get_position()
#			print('###DOWN')
			
		else:	
#			print('###Touch RELEASE')
			var clickEndPos = event.get_position()
			
			# move the feedback circle
			click_circle_pos = clickEndPos
			
			
			if !isEventDrag(clickStartPos, clickEndPos):
				# if touch and NOT drag, then move the touch effect
				on_touch_screen(clickStartPos)
#				print('SAME POS')

			# if CLICK DRAG do nothing. 
			else:
				pass
#				print('new pos')
	#		print('click_input', event)
			# compare the release position to the click position
			
	#		print('click_input2', event.get_position())
			
#		destroy_and_spawn_click_circle(event.get_position().x, event.get_position().y)

		
# if within deadzone, then consider it a touch (with a little movement) vs a drag
func isEventDrag(startPos: Vector2, endPos: Vector2):
	var drag_distance = startPos.distance_to(endPos)
	# FIXME: Maybe we pull that value so they are always the same...
	# this number (100) lines up PERFECTLY with "scroll_deadzone" on ScrollContainer
	return drag_distance > 100

