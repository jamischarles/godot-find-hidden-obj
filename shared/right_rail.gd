extends ScrollContainer

# Will contain logic of handling right rail clicks and signals etc...
# And track the currently selected animal in the right rail...

# when it's on canvas assign it here...
#@onready var btnGroup: ButtonGroup = $legend_for_hidden_objects.get_child(0).button_group

# this prop has to be set by the ui :(
# right rail buttons. For easy access
@onready var legend_button_group: ButtonGroup = $legend_for_hidden_objects.get_children()[0].button_group

# Called when the node enters the scene tree for the first time.
func _ready():
	var legend_buttons = $legend_for_hidden_objects.get_children()

	
	for i in len(legend_buttons):
		var button = legend_buttons[i]
#		button.pressed.connect(on_button_pressed.bind(button.get_name(), button) )
		button.pressed.connect(on_button_pressed)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	## Q: Do we need to add the button back?
func on_button_pressed():
#	print("animalName: ", name)
#	print("animalName2: ", btnGroup.get_pressed_button())
	## TODO: implement my own comparision logic for this?!?
#	Dirty checking?
	legend_button_group.emit_changed()



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
