@tool
extends Control


@onready var ip = $VBoxContainer/HBoxContainer/TextEdit
@onready var user = $VBoxContainer/HBoxContainer2/TextEdit
@onready var source = $VBoxContainer/HBoxContainer3/TextEdit
@onready var destination = $VBoxContainer/HBoxContainer4/TextEdit

var data_url = "user://syncdeck.json"

func _ready():
	$VBoxContainer/Button.pressed.connect(_on_Button_pressed)
	if !FileAccess.file_exists(data_url):
		save_data(data_url, {"ip":"","user":"","source": "","destination":""})

	var data = load_data(data_url)
	ip.text = data["ip"]
	user.text = data["user"]
	source.text = data["source"]
	destination.text = data["destination"]

func _on_Button_pressed():
	var data = {
		"ip": ip.text,
		"user": user.text,
		"source": source.text,
		"destination": destination.text
	}
	var otp = []
	OS.execute("scp", [source.text, user.text+"@"+ip.text+":"+destination.text], otp)
	print("Sending Done....")
	print(otp)
	save_data(data_url, data)

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
