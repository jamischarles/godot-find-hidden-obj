extends ScrollContainer

# Will contain logic of handling right rail clicks and signals etc...
# And track the currently selected animal in the right rail...

# when it's on canvas assign it here...
#@onready var btnGroup: ButtonGroup = $legend_for_hidden_objects.get_child(0).button_group

# this prop has to be set by the ui :(
# right rail buttons. For easy access
#@onready var legend_button_group: ButtonGroup = $legend_for_hidden_objects.get_children()[0].button_group

#var lastSelectedButton: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 10 # set above clickzones (after matched) so it doesn't bleed through right rail
	pass
#	var legend_buttons = $legend_for_hidden_objects.get_children()
#
#
#	for i in len(legend_buttons):
#		var button = legend_buttons[i]
##		button.pressed.connect(on_button_pressed.bind(button.get_name(), button) )
#		button.pressed.connect(on_button_pressed)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	## Q: Do we need to add the button back?
	## TODO: Break this up and make it more declarative...?
func on_button_pressed():
	pass
	## destroy the panel child of the previously selected button
	## removes the "selected" border
#	var oldPanel = lastSelectedButton.get_child(0) if lastSelectedButton else null
#	if oldPanel: oldPanel.queue_free()
#
#	## change the button style to a "pressed" state
#	var button = legend_button_group.get_pressed_button()
#	lastSelectedButton = button
	
	


#	var panel = Panel.new()
	
#	panel.draw_style_box(StyleBoxFlat.new(), button.get_rect())
#	button.add_child(panel)
	
#	var box = StyleBoxFlat.new()
#	box.bg_color = Color(0.0666666701436, 0.66274511814117, 0.839215695858)
	
#	panel.add_theme_stylebox_override("test", box)
#	panel["theme_override_styles/panel"] = box
	
#	box.set_border_width_all(15)
#	box.border_color = Color(0.0666666701436, 0.66274511814117, 0.839215695858, .5)
#	

	
#	box.set_draw_center(false)
	
	# didn't render at all until I did this...
#	panel.set_size(button.get_size())
	

	
	
#	print("animalName: ", name)
#	print("animalName2: ", btnGroup.get_pressed_button())
	## TODO: implement my own comparision logic for this?!?
#	Dirty checking?
#	legend_button_group.emit_changed()



#func _gui_input(event):
#	# touch event on the button in right rail
#	# Q: how can we not treat a scroll event as a button press/touch?
#
#	if event.get_class() == "InputEventScreenTouch" &&  event.is_released():
#		print("relase")
#
#	if event.get_class() == "InputEventScreenTouch" &&  event.is_pressed():
#
#		print('press: ', event.get_class())
		
#	event.is_pressed()
	
	
#	InputEventScreenTouch
	
#	InputEventScreenTouch: index=0, pressed=true, canceled=false, position=((78, 496)), double_tap=false
