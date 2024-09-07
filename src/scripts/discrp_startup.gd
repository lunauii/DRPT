extends Node

var details : String
var state : String
var details_changed : bool
var state_changed : bool
var window_position : Vector2i

var moving : bool = false
var mouse_start : Vector2i

@onready var ui = $UI
@onready var change_box = $"UI/VBoxContainer/PanelContainer/MarginContainer/TabContainer/Defaults/MarginContainer/VBoxContainer2/ChangeBox"
@onready var detail_edit = $"UI/VBoxContainer/PanelContainer/MarginContainer/TabContainer/Defaults/MarginContainer/VBoxContainer/DetailsBox/DetailEdit"
@onready var state_edit = $"UI/VBoxContainer/PanelContainer/MarginContainer/TabContainer/Defaults/MarginContainer/VBoxContainer/StateBox/StateEdit"
@onready var resolution_menu = $UI/VBoxContainer/PanelContainer2/HBoxContainer/MenuButton

func _ready():
	resolution_menu.get_popup().id_pressed.connect(_on_item_menu_pressed)
	DiscordRPC.app_id = 1281484844404183071 # Application ID
	DiscordRPC.large_image = "pencil"

	load_data()

	if not FileAccess.file_exists("user://prev_params.cfg"):
		DiscordRPC.details = "Studying"
		DiscordRPC.state = "Textbook Chapter 1"
	else:
		DiscordRPC.details = details
		DiscordRPC.state = state
		detail_edit.text = details
		state_edit.text = state
		get_window().position = window_position

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordRPC.refresh() # Always refresh after changing the values!

func _on_item_menu_pressed(id: int):
	if id == 0:
	# 480x360
		get_window().size = Vector2i(480, 360)
	
	elif id == 1:
	# 720x540
		get_window().size = Vector2i(720, 540)
	
	elif id == 2:
	# 960x720
		get_window().size = Vector2i(960, 720)
	

func _on_details_edit_text_changed(new_details: String) -> void:
	details = new_details
	details_changed = true
	change_box.disabled = false


func _on_state_edit_text_changed(new_state: String) -> void:
	state = new_state
	state_changed = true
	change_box.disabled = false


func _on_change_button_pressed() -> void:
	save_changes()


func enter_button() -> void:
	save_changes()


func save_changes() -> void:
	DiscordRPC.details = details
	DiscordRPC.state = state
	change_box.disabled = true
	
	save_data()
	DiscordRPC.refresh()


func save() -> Dictionary:
	var save_dict = {
		
		"details" : details,
		"state" : state,
		"window_position" : window_position
		
	}
	
	return save_dict

func save_data():
	var save_data_var = FileAccess.open("user://prev_params.cfg", FileAccess.WRITE)
	
	var json_string = JSON.stringify(save())
	
	save_data_var.store_line(json_string)

func load_data():
	if not FileAccess.file_exists("user://prev_params.cfg"):
		return
	
	var save_data_var = FileAccess.open("user://prev_params.cfg", FileAccess.READ)
	
	while save_data_var.get_position() < save_data_var.get_length():
		var json_string = save_data_var.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var node_data = json.get_data()
		
		details = node_data["details"]
		state = node_data["state"]
		window_position = str_to_var("Vector2i" + node_data["window_position"])
	
		print(node_data)


func _on_close_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_minimize_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func _on_box_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if !moving:
			mouse_start = get_viewport().get_mouse_position()
		moving = event.is_pressed()
		

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		load_data()
		window_position = get_window().position
		save_data()
		get_tree().quit()

func _process(_delta: float) -> void:
	if moving:
		var current_mouse := Vector2i(get_viewport().get_mouse_position())
		get_window().position += current_mouse - mouse_start


func _on_detail_edit_text_submitted(_new_text: String) -> void:
	enter_button()


func _on_state_edit_text_submitted(_new_text: String) -> void:
	enter_button()
