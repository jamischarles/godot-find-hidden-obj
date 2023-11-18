extends Node

#https://ask.godotengine.org/1883/transfering-a-variable-over-to-another-scene

# used for truly GLOBAL state.
# We autoload this (see project settings) so we can ref this from any script

## TODO: We should make a LevelSwitcher class that's global and keep track of this routing type logic

## global persisted data goes to global_data.txt

# on first load, load the persistent data from disk

var state

var default_state = {
	all_levels_unlocked = false
}

#print('STATE: ', state)

func _ready():
	print('GLOBAL IS READY')
	state = __load_state()
	

# not set
var next_level: String
# TODO: Calc max levels automagically?
var highest_level = "06"

func set_next_level_str(currentLevelStr: String):
	var newLevelInt = int(currentLevelStr) + 1
	next_level = "0" + str(newLevelInt)
	return next_level
	
func change_scene(destination: String):	
	var target: String
	match destination:
		"home":
			target = "main.tscn"
		_:
			# default fallthrough
			# assume "01" numbers are being passed
			target = "%s/stage.tscn" % destination
			
			# update the new "next_level"
			# Q: How do we max out at the top end?
			# TODO: Test that ^
			# If there are levels left to go, then let's set that as next
			if destination != highest_level:
				set_next_level_str(destination)
			
	
	get_tree().change_scene_to_file("res://" + target)
	
func send_to_next_level():
	change_scene(next_level)
	

# read & write persistent state
# Using this pattern: https://docs.godotengine.org/en/latest/classes/class_configfile.html
func __load_state():
	var config = ConfigFile.new()
	#	https://ask.godotengine.org/4351/where-are-user-locations-on-each-platform
#	~/Library/Application Support/Godot/app_userdata/Matchy Match/state.cfg
	var err = config.load("user://state.cfg")
	if err != OK:
		# FIXME: Should spread out the keys in here...
		config.set_value("state", "state", default_state)
#		return default_state
		
	return config.get_value("state", "state", default_state)	
#	some_variable = config.get_value("some_section_name", "some_key_name")
	
#	var loaded_data_raw = FileAccess.open("res://global_data.txt", FileAccess.READ)
#	var data = str_to_var(loaded_data_raw.get_as_text()) # deserialize back into the data structure
#	print('##data', data)
#	if !data: 
#		return default_state
#	return data
	
## TODO: Define the data and shapes in this file if we use it in more places...	
## TODO: Just change this to persist_state?
func __save_state(data):
	var config = ConfigFile.new()
	config.set_value("state", "state", data)
#	~/Library/Application Support/Godot/app_userdata/Matchy Match/state.cfg
	config.save("user://state.cfg")
#	https://ask.godotengine.org/4351/where-are-user-locations-on-each-platform
#
#	var file_handle = FileAccess.open("res://global_data.txt", FileAccess.WRITE)
##	https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/
#	# save human readable non-json format that prerves godot data types
#	file_handle.store_string(var_to_str(data))
#	state = data
	
## updates global state and persists to disk
func set_state(new_fields: Dictionary) -> Dictionary:
	state.merge(new_fields, true)
	__save_state(state)
	return state
	
## returns current global state	
func get_state() -> Dictionary:
	return state	


## FIXME: where should we distinguish between left padded string nums and not?
