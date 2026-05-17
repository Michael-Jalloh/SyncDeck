@tool
extends Control

@onready var ip: TextEdit = $VBoxContainer/HBoxContainer/TextEdit
@onready var user: TextEdit = $VBoxContainer/HBoxContainer2/TextEdit
@onready var source: TextEdit = $VBoxContainer/HBoxContainer3/TextEdit
@onready var destination: TextEdit = $VBoxContainer/HBoxContainer4/TextEdit
@onready var sound_button: CheckButton = $VBoxContainer/HBoxContainer5/SoundButton
@onready var debug_button: CheckButton = $VBoxContainer/HBoxContainer6/DebugButton

var data_url = "user://syncdeck.json"
var thread: Thread
var data  = {}
var pid

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(_on_sync)
	$VBoxContainer/Button2.pressed.connect(_stop_sync)
	if !FileAccess.file_exists(data_url):
		save_data(data_url, {"ip":"","user":"","source": "","destination":"", "sound":true})

	var data = load_data(data_url)
	ip.text = data["ip"]
	user.text = data["user"]
	source.text = data["source"]
	destination.text = data["destination"]
	if data.has("sound"):
		sound_button.button_pressed = data["sound"]
	if data.has("debug"):
		debug_button.button_pressed = data["debug"]
	
	sound_button.pressed.connect(sound_button_changed)
	debug_button.pressed.connect(debug_button_changed)

func sound_button_changed() -> void:
	data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text,
		"sound": sound_button.button_pressed,
		"debug": debug_button.button_pressed
	}
	save_data(data_url, data)

func debug_button_changed() -> void:
	data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text,
		"sound": sound_button.button_pressed,
		"debug": debug_button.button_pressed
	}
	save_data(data_url, data)

func _on_sync() -> void:
	data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text,
		"sound": sound_button.button_pressed,
		"debug": debug_button.button_pressed
	}
	save_data(data_url, data)
	print("[INFO] -> Sending file....")
	$Sending.play()
	start_copying()
	$Timer.start()

func start_copying() -> void:
	if sound_button.button_pressed:
		$Sending.play()
	
	var source_text = source.text.rstrip(" ")
	var destination_text = user.text.rstrip(" ")+"@"+ip.text.rstrip(" ")+":"+destination.text.rstrip(" ")
	pid = OS.create_process("rsync", ["-avzP",source_text, destination_text], true)
	if debug_button.button_pressed:
		print("[DEBUG] -> ","rsync -avzP ", source_text, " ",destination_text)
		print("[INFO] -> Started sending....")

func load_data(url):
	if url == null: return {}
	var file = FileAccess.open(url, FileAccess.READ)
	var data = {}
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data

func save_data(url, dict) -> void:
	if url == null or dict == null: return
	var file = FileAccess.open(url, FileAccess.WRITE)
	file.store_line(JSON.stringify(dict))
	file.close()

func _on_timer_timeout() -> void:
	if pid:
		if OS.is_process_running(pid):
			if debug_button.button_pressed:
				print("[INFO] -> Sending...")
		else:
			print("[INFO] -> Sending done...")
			$Timer.stop()
			if sound_button.button_pressed:
				$Alarm.play()

func _stop_sync() -> void:
	print("[INFO] -> Stop Sync...")
	if pid:
		OS.kill(pid)
