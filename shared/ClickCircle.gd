extends Area2D

signal found_hidden_object_on_canvas

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
	
	draw_polyline(polygon, Color(Color.LIGHT_GRAY, .5), 8.0, true)
	
	# move collision shape to new circle position
	click_circle_collision_shape.set_polygon(polygon)
	



# draw circles and create collision areas from here...
# why don't we use a polygon? Or an area2d with attached circle shape?
# hm... either would work...
func _on_canvas_with_clickzones_gui_input(event):
	if event.get_class() == "InputEventScreenTouch" && event.is_pressed():
		click_circle_pos = event.get_position()
#		print('click_input', event)
#		print('click_input2', event.get_position())
		queue_redraw()
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
	print("##COLLISION", area.name)
	emit_signal("found_hidden_object_on_canvas", area)

