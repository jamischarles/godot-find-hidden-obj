extends Camera2D
## Things I changed
# 1. remapped gui input to camera script
# 2. changed imageContainer from control node to node type


# Using camera is interesting...
# if you make the changes in global scope here, then physics process helps get 
# to the right destination
# https://kidscancode.org/godot_recipes/3.x/2d/touchscreen_camera/

#var zoom = 1
var min_zoom = 0.5
var max_zoom = 2

var last_drag_distance = 0
var zoom_sensitivity = 10
var zoom_speed = 0.05

var limit




var events = {}

var target_return_rate = 0.2

# trying something new
var speed = 1.1
var newPos = position
var lastPos = position


var posChangeBufferX = 0
var posChangeBufferY = 0


# screen center pos while taking whole image into and zoom level
var targetScreenCenterPos

@onready var img_size = get_node("%hidden_objects_image").size

#var virt_position = position

## Learning
# zoom by 1.05 is slight zoom in
# zoom by 0.95 is slight zoom out

# this is when the camera updates...
# what happens if I turn it off? or can I do my sanity checks here?

# we only turn this on when drag + zoom actions need to happen.
# else it gets turned off
func _physics_process(delta):
	var screenCenter = get_screen_center_position()
	var screenSize = get_viewport().get_visible_rect().size
	
	print('-------------------->')
	print("screenCenter.x", screenCenter.x)
	print('posChangeBufferX', posChangeBufferX)
	print('screenSize.x', screenSize.x)
	print('pos.x:before', position.x)
	print('zoom.x', zoom.x)
	
	## Correlations:
	## at 1.x zoom...
	## pos.x before is 1000 less than screenCenter
	## screenSize + 258 is the limit (which is screenCenter)
	
	if screenCenter.x + -posChangeBufferX < screenSize.x + 258:
		position.x -= posChangeBufferX
		
	position.y -= posChangeBufferY
	#position.y = clamp(position.y, 0, screenSize.y * zoom.y / 2)
		
	posChangeBufferX = 0
	posChangeBufferY = 0
	
	## TODO: If I lerp then I wait till the condition to turn it off
	set_physics_process(false)

func _process(delta):
	
	## Learnings
	# After zoom, screensize is same, but screenCenter is different
	
	#print('--------------------- _process() -------------')
	#print('screenCenterPos', get_screen_center_position())
	#print('getTargetPos', get_target_position())
#
	#print('posChangeBufferX', posChangeBufferX)
	#var screenSize = get_viewport().get_visible_rect().size
	#var screenCenter = get_screen_center_position()
	#print('screensize/center: ', screenSize, "/", screenCenter)
	#print("get_viewport().size.x ", get_viewport().size.x)
	#
	### TODO: Fix the sign stuff and clean up this logic
	### Todo combine vector logic
	#
	## hard limit on left side of screen
	#
	## hard limit on right side of screen
	##if screenCenter.x + -posChangeBufferX < screenSize.x + 258 * zoom.x: # TODO: Adjust 258 as constant for right rail adjusted for zoom
	#
	#print('getTargetPos:after ', get_target_position())
	## TODO: Adjust for zoom. But works great at zoom = 1
	##var right = limit_right - (offset.x*zoom.x) - get_viewport().size.x * zoom.x / 2
	##var right = get_viewport().size.x * zoom.x / 2
	##position.x = clamp(position.x, 0, right)# + 258) # TODO: Can we get img size, then clamp it as that + 258?
	#var right_clamp = screenSize.x / 2 * zoom.x
	#print('right_clamp1 ', right_clamp)
	#print('right_clamp2 ', screenSize.x * zoom.x)
	#print('right_clamp/screenSize/zoom: ', screenSize.x / 2 * zoom.x, "/", screenSize.x, "/" ,zoom.x)
	## Q: WHY?!?!?!?!?!?!?!!??!?!?! does +258 fix it?!?!?!?!?
	#print('pos.x:before ', position.x)
	##position.x = clamp(position.x, 0, right)
	#position.x = clamp(position.x, 0, screenSize.x / 2 * zoom.x + 258)# + 258) # TODO: Can we get img size, then clamp it as that + 258?
	#print('pos.x:after ', position.x)
		### FIXME: This works at zoom > 1 but it's not enough. Do we need to change the /2 value?
		### FIXME: Need to manually go through that math...
		### NOTE: at 2x it works again fully
		### NOTE: At 1.x it works fully
		### NOTE: < 1 it works fully
		#
	#print("center/target", get_screen_center_position(), "/", get_target_position())	
	#
	#print("img_size/img_size*zoom: ", img_size.x, "/",img_size.x * zoom.x, "/",img_size.x /2 * zoom.x)	
	#print('position.x', position.x)
	#print('zoom.x', zoom.x)
	#
	
	
	
	#var vtrans = get_canvas_transform()
	#var top_left = -vtrans.get_origin() / vtrans.get_scale()
	#var vsize = get_viewport_rect().size
	#print("center", top_left + 0.5*vsize/vtrans.get_scale())
	#print('get_canvas_transform()', get_canvas_transform())
	#print("vtrans.get_origin()", vtrans.get_origin())
	#print("vtrans.get_scale()", vtrans.get_scale())
	#print("top_left", top_left)
	#print('scales', get_tree().root.content_scale_size, get_tree().root.content_scale_mode, get_tree().root.content_scale_factor)
	
	#if screenCenter.y + -posChangeBufferY < screenSize.y:
	
	#print('process')

#func _physics_process(delta):
	#print('physics')
	#position.x = lerp(position.x, newPos.x, 1 * delta)
	#position.y = lerp(position.y, newPos.y, 1 * delta)
	#position.x = lerp(lastPos.x, newPos.x * zoom.x, speed * delta)
	#position.y = lerp(lastPos.y, newPos.y * zoom.x, speed * delta)
	#lastPos = position
	#position = lerp(position, get_node(target).position, target_return_rate)
	# TODO: get width and h of image for camera limit
	#limit_right =  ## FIXME: is this the right place for this?
	#position = virt_position ## Is this even needed?
	pass

	#set_custom_viewport(get_tree().root.get_node("/root/Global"))
	#print('camera ready')
	#make_current()
	#set_zoom(Vector2(1, 1))
	#offset = Vector2(100, 0)


# Allows us to handle any input that hasn't been handled by another node first
# Nice way to separate things like scroll from zooming
func _unhandled_input(event):
	#print('event', event)
	#pass

#func ready():
	#hould zoom in (as in, one world pixel will fill 4 screen pixels).


# handle any gui input on the stage canvas
## Todo: Try very simple handling first. Then go state machine if needed...
#func _on_image_container_gui_input(event):
	if event is InputEventMouseButton && event.is_alt_pressed() && event.is_shift_pressed():
		#zoom *= 0.95
		zoom -= Vector2(.05, .05)
		
	elif event is InputEventMouseButton && event.is_alt_pressed():
		#zoom *= 1.05
		zoom += Vector2(.5, .5)
		limit_right = img_size.x + 258 * zoom.x
		#print('limit_right', limit_right)
		set_physics_process(true)
		
	# zoom via smartpad on mac
	# nice way to emulate some of the same functionaolity
	if event is InputEventMagnifyGesture:
		var new_zoom = event.factor
		new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
		print("new_zoom from mac pad", new_zoom)
		zoom = Vector2.ONE * new_zoom
		#zoom = lerp(zoom, Vector2.ONE * new_zoom, 0.4)

	
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
			#print('RELEASE')
			# TODO: Tween the end? or lerp it?
			# This will add the slowdown effect....?
			#position.x += 50
			
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			#position = event.position
			# is'r ceay linear right now. TODO: we need to try lerp for the movement
			#event.relative.rotated(rotation) * zoom.x
			
			# TODO: Need to CLAMP or VERIFY after zoom and move that we're within the limits
			# Also need to RESET the limits after zoom
			
			var screenSize = get_viewport().get_visible_rect().size
			#print('screenSize', screenSize)
			#print('screenCenterPos', get_screen_center_position())
			#print('getTargetPos', get_target_position())
			#
			#print('event.relative.rotated(rotation)', event.relative.rotated(rotation))
			#if get_screen_center_position().x * zoom.x <  screenSize.x * zoom.x:
			
			# We do NOT want this one, since it's based on where the mouse is
			#print('evt.pos', event.position)

				
				#position.x -=
			#print('newPos', newPos)
			#print('limits', get_limit(SIDE_BOTTOM))
			#print('drag_margin', get_drag_margin(SIDE_BOTTOM))
			#print('get_target_position().x', get_target_position().x)
			#if newPos <= get_target_position().x:
				#position.x = newPos
			
			posChangeBufferX += event.relative.rotated(rotation).x * zoom.x # Does this even help?
			posChangeBufferY += event.relative.rotated(rotation).y
			
			# run the physics process
			set_physics_process(true)
			#position.y -= event.relative.rotated(rotation).y * zoom.x
			#position = get_target_position()
			#print('newPos', position)
			
			#position.x = clamp(position.x, 0, limit_right)
			#position.y = clamp(position.y, 0, limit_bottom)
			
			
			get_node("%HScrollBar").value = position.x
			#position = lerp(position,  event.position, 2.4)
			#print('position change')
			#limit_right = limit_right * zoom.x # 258 is right rail width
			#position.x = lerp(position.x, event.position.x, .01)
			#position.y = lerp(position.y, event.position.y, .01)
			#newPos = event.position
		elif events.size() == 2:
			# distance between finger and thumb
			var drag_distance = events[0].position.distance_to(events[1].position)
			print('drag_dist: ', drag_distance)
			
			# dead zone for when to start zoom
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				# zoom in or zoom out? (flip it. Not sure why that's needed)
				var new_zoom = (1 + zoom_speed) if drag_distance > last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				print("new_zoom", new_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance	
				
			
			
			#position = lerp(start_point, end_point, lerp_amount)
			#camera.position for 2D
			#lerp_amount += speed
			#position -= lerp(position, event.relative.rotated(rotation), target_return_rate)

## TODO Try
# https://kidscancode.org/godot_recipes/3.x/2d/touchscreen_camera/
# https://forum.godotengine.org/t/how-to-move-the-camera-view/21640
#https://www.youtube.com/watch?v=PDXknOG1NR0

# https://www.reddit.com/r/godot/comments/13ks6tb/mobile_scroll_containers/

var event_state = {
	status = "no_touch",  # one-touch, # two-touch, # three-touch # drag
	# lua style assign turns key into string (nice)
	
}

# these are the ONLY valid states for the FSM to be in...
var finite_states = {
	"no_touch" : {
		status = "no_touch"
	}, 
	"one_touch_press" : { # in progress
		status = "one_touch_press",
		pos = Vector2()
	}, 
	"one_touch_drag_scroll" : { # in progress
		status = "one_touch_drag_scroll",
		start_pos = Vector2() # position where the drag started
	},
	
	"multi_touch_press": {
		status = "multi_touch_press",
		touch_points = {} # number based dict / array. Will include state for each touch point
	},
	
	"multi_touch_drag_zoom": { # multi touch drag for purpose of zoom in/out in progress
		status = "multi_touch_drag_zoom",
		touch_points = {}, # number based dict / array. Will include state for each touch point
		distance = 0 # distance between the pinched fingers (usually use 0 and 1)
	}
}
