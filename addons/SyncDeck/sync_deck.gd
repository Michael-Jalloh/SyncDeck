@tool
extends Control

@onready var ip = $VBoxContainer/HBoxContainer/TextEdit
@onready var user = $VBoxContainer/HBoxContainer2/TextEdit
@onready var source = $VBoxContainer/HBoxContainer3/TextEdit
@onready var destination = $VBoxContainer/HBoxContainer4/TextEdit
@onready var sound_button = $VBoxContainer/HBoxContainer5/SoundButton

var data_url = "user://syncdeck.json"
var thread: Thread
var data  = {}
var pid

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_Button_pressed)
	if !FileAccess.file_exists(data_url):
		save_data(data_url, {"ip":"","user":"","source": "","destination":"", "sound":true})

	var data = load_data(data_url)
	ip.text = data["ip"]
	user.text = data["user"]
	source.text = data["source"]
	destination.text = data["destination"]
	if data.has("sound"):
		sound_button.button_pressed = data["sound"]
	
	sound_button.pressed.connect(sound_button_changed)

func sound_button_changed():
	data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text,
		"sound": sound_button.button_pressed
	}
	save_data(data_url, data)

func _on_Button_pressed():
	data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text,
		"sound": sound_button.button_pressed
	}
	save_data(data_url, data)
	print("[INFO] -> Sending file....")
	start_copying()
	$Timer.start()

func start_copying():
	if sound_button.button_pressed:
		$Sending.play()
	pid = OS.create_process("scp", [source.text, user.text+"@"+ip.text+":"+destination.text], true)

func load_data(url):
	if url == null: return {}
	var file = FileAccess.open(url, FileAccess.READ)
	var data = {}
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data

func save_data(url, dict):
	if url == null or dict == null: return
	var file = FileAccess.open(url, FileAccess.WRITE)
	file.store_line(JSON.stringify(dict))
	file.close()



func _on_timer_timeout():
	if pid:
		if OS.is_process_running(pid):
			print("[INFO] -> Sending...")
		else:
			print("[INFO] -> Sending done...")
			$Timer.stop()
			if sound_button.button_pressed:
				$Alarm.play()
