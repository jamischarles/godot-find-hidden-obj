extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	var buttons = $Control.get_children()
	
	for button in buttons:
		print('button', button)
		button.connect('button_up', on_button_up.bind(button.get_name()))
		
		
	# dynamically add the click events with the click params...
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_button_up(level_to_load):
	get_tree().change_scene_to_file("res://%s/stage.tscn" % level_to_load)
