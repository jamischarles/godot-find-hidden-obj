extends Area2D

signal found_hidden_objects_on_canvas

var canvas_click_circle: Polygon2D

var click_circle_pos: Vector2
var click_circle_collision_shape = CollisionPolygon2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(click_circle_collision_shape)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _draw():
	print('_draw')
	var pos = click_circle_pos
	
	

	var polygon = generate_circle_polygon(80, 50, pos)
	var visible_shape = Polygon2D.new()
#	
	# solid circle
#	draw_circle(pos, 50, Color.DARK_RED)
	
	# Matches color in right_rail.gd
#	draw_polyline(polygon, Color(Color.LIGHT_GRAY, .5), 8.0, true)
	draw_polyline(polygon, Color(0.0666666701436, 0.66274511814117, 0.839215695858, .5), 8.0, true)
	
	# move collision shape to new circle position
	click_circle_collision_shape.set_polygon(polygon)
	



# draw circles and create collision areas from here...
# why don't we use a polygon? Or an area2d with attached circle shape?
# hm... either would work...
# senses movement. If it's a swipe/move, then we do nothign...
# FIXME: Make it more gracious. Allow some movement.

# TODO: Need to have allowable distance built in
# obvious scroll attempt should be ignored. But a kid slipping should count as click
var clickStartPos
func _on_canvas_with_clickzones_gui_input(event):
#	print('event', event)
	if event.get_class() == "InputEventScreenTouch":
	
		if event.is_pressed():
			clickStartPos = event.get_position()
#			print('###DOWN')
			
		else:	
#			print('###UP')
			click_circle_pos = event.get_position()
			if click_circle_pos == clickStartPos:
				queue_redraw()
#				print('SAME POS')

			# if CLICK DRAG do nothing. 
			else:
				pass
#				print('new pos')
	#		print('click_input', event)
			# compare the release position to the click position
			
	#		print('click_input2', event.get_position())
			
#		destroy_and_spawn_click_circle(event.get_position().x, event.get_position().y)

		



func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array
	
	# +1 because circle wasn't quite closed for circle outline
	for _i in num_sides+1:
		polygon.append(vector + pos)
		vector = vector.rotated(angle_delta)
		
	return polygon


func _on_area_entered(area):
	print('##COLLISION', get_overlapping_areas())
	# Q: We somehow need to store BOTH, then clear it
#	print("ENTER@@@", area)
#	print("##COLLISION", area.name)
	
	# send the overlapping areas of the click_circle as an array 
	emit_signal("found_hidden_objects_on_canvas", get_overlapping_areas())

