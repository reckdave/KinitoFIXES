extends Node2D

onready var kinitoscene = preload("res://KinitoFIXES/Scenes/App001/1.tscn")
onready var CMD_SCENE = preload("res://KinitoFIXES/Scenes/NewCMD/CMD-FIXES.tscn")
onready var log_main = preload("res://KinitoFIXES/Scenes/LOG_MAIN.tscn")
onready var log_box = $CanvasLayer/GUI/LOG_BOX

var kintiopatch = false


func _replace_scene(old,new):
	old.get_parent().add_child(new)
	old.queue_free()

func print_log(string):
	var log_copy = log_main.instance()
	var time_str = str("H: ", OS.get_time()["hour"], " M: ", OS.get_time()["minute"], " S: ", OS.get_time()["second"])
	log_copy.name = str(string).left(10)
	log_copy.get_node("LOG_TEXT").text = string
	log_copy.get_node("LOG_TIME").text = time_str
	log_box.add_child(log_copy)
	print("[kinito-fixes] ", string)

var cmd
func open_cmd(parent):
	var clone = CMD_SCENE.instance()
	clone.fixes_node = self
	cmd = clone
	parent.add_child(clone)
	return clone
func close_cmd():
	cmd.queue_free()

var config_name = 'KinitoFIXES' # change to your liking
var config_author = 'reckdave'
var config_info = {'GUI_VISIBLE':false,'FIX_FRIENDS':false,'CAM_SCARE':true,'CMD_SHOW':true,'FEAR_FIX':false} # change to your liking
var config_loaded = false
var config_node

func ConfigHandler():
	var dir = Directory.new()
	dir.open('user://Mods')
	if dir.file_exists('ModConfiguration.zip'):
		while !config_loaded:
			if get_parent().has_node('Config_Scene'):
				var node = get_parent().get_node('Config_Scene')
				config_loaded = true
				config_node = node.MakeConfig(config_name,config_author,config_info)
				config_info = config_node.ConfigValues
			yield(get_tree(),"idle_frame")
	else:
		OS.alert("MISSING MODCONFIG, RESULTING TO DEFAULT VALUES", "ERROR")
		config_loaded = true

func _ready():
	version_check()
	yield(ConfigHandler(),"completed")
	print_log('CONFIG FOUND')
	#$GUI.visible = config_info['GUI_VISIBLE']

# UPDATE CHECK
const version_url = "https://raw.githubusercontent.com/reckdave/KinitoFIXES/main/KinitoFIXES/Files/VERSION.json"
const version = "1.0.0"

func version_check():
	$VersionRequest.request(version_url)

func _request_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = str2var(body.get_string_from_utf8())
		print_log(data["VERSION"])
		if version < data["VERSION"]:
			OS.alert("THIS IS AN OUTDATED VERSION OF MODCONFIG \nDOWNLOAD LATEST AT THE GITHUB","KINITOFIXES")
			OS.shell_open("https://github.com/reckdave/KinitoFIXES/releases/tag/release%s" % data["VERSION"])
	else:
		print_log('FAILED TO GET VERSION NUMBER: ' + response_code)


func _process(_delta):
	if Tab.data["open"][1] == true and !kintiopatch:
		kintiopatch = true
		var kinitopatch_scene = kinitoscene.instance()
		var applic = get_parent().get_parent().get_node("1").get_child(0)
		_replace_scene(applic,kinitopatch_scene)
		print_log("REPLACED")
#		var kill_var = null
#		kill_var.kill()
	elif Tab.data["open"][1] == false and kintiopatch:
		kintiopatch = false
