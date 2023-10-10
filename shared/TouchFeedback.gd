extends Area2D

signal shape_found

# right now we align them fully in the editor GUI
# so the circle and collision obj are the exact same size at full size.
# now that we don't use the full size we need to ensure the collision area
# matches the size of the circle at full animation size
# FIXNE: should we be scaling the parent area2d instead?
var MAX_CIRCLE_SIZE = .5 #scale prop

# Called when the node enters the scene tree for the first time.
func _ready():
	# scale the collision shape down to max_size to match circle size
	$CollisionCircle.scale = Vector2(MAX_CIRCLE_SIZE, MAX_CIRCLE_SIZE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_touch_screen(newPosition:Vector2):
	
	# move circle (position is relative to parent el "touchFeedback" area2d node
	self.position = newPosition
	
	# is there lag here with this?
	# or because this is physics I probably need to wait to run this until the physics cycle is done...
	# Q: Or can we avoid this if we tie this to the event?
	
	
	# scale and transparency props are on the circlesprite
#	$CircleSprite.scale = Vector2(3, 3)
	$CircleSprite.scale = Vector2(0, 0)
	$CircleSprite.modulate = Color(1,1,1, .5)
	
	# fade and bounce in
	
	# hide
	print('###on_touch_screen')
	## 2) Tween
	var tween = get_tree().create_tween().set_parallel(false)
#	tween.tween_property(self, "modulate", Color.RED, 3).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_property(self, "modulate", Color(0.11,1,1,.5), .2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($CircleSprite, "modulate", Color(0.65,.1,.86,.5), .1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_property($CircleSprite, "scale", Vector2(MAX_CIRCLE_SIZE,MAX_CIRCLE_SIZE), .3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($CircleSprite, "modulate", Color(0.65,.1,.86, 0), .1).set_ease(Tween.EASE_OUT)
	
#	tween.tween_property(self, "scale", Vector2(), 1)
#	tween.tween_property(self, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
	
	
		
	# don't remove it since we only have one
	tween.tween_callback(on_tween_done)


func on_tween_done():
	# disable the collision circle
	# OR just set "monitoring" to false
	print('tween DONE')
	# checking for overlap avoids getting stale overlapping areas
	if self.has_overlapping_areas():
		# emit signal that we have a shape that's marked within feedback circle area
		print('overlaps', self.get_overlapping_areas())
		
		# only match one at a time
		var first_found_shape = self.get_overlapping_areas()[0]
		emit_signal("shape_found", first_found_shape)

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

