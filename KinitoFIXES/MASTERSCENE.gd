extends Node2D

var logs = 0


onready var kinitoscene = preload("res://KinitoFIXES/-Scenes/Application001/Main/1.tscn")
#onready var CMD_SCENE = preload("res://KinitoFIXES/-Scenes/CMD/CMD_Scene.tscn")
onready var CMD_SCENE = preload("res://KinitoFIXES/-Scenes/NewCMD/CMD-FIXES.tscn")
onready var log_main = preload("res://KinitoFIXES/-Scenes/LOG_MAIN.tscn")
onready var log_box = $GUI/LOG_BOX
var added_patch = false
var kintiopatch = false

func _replace_scene(old,new):
	old.get_parent().add_child(new)
	old.queue_free()


func print_log(string):
	logs += 1
	var log_copy = log_main.instance()
	var time_str = str("H: ", OS.get_time()["hour"], " M: ", OS.get_time()["minute"], " S: ", OS.get_time()["second"])
	log_copy.name = logs
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
var config_mod_ver_min = '1.1.3'

func ConfigHandler():
	var dir = Directory.new()
	dir.open('user://Mods')
	if dir.file_exists('ModConfiguration.zip'):
		while !config_loaded:
			if get_parent().has_node('Config_Scene'):
				var node = get_parent().get_node('Config_Scene')
				config_loaded = true
#				if node.VERSION == null or (node.VERSION < config_mod_ver_min):
#					OS.alert("OUTDATED ModConfiguration, See the logs for more ","ERROR")
#					print_log('DOWNLOAD THE LATEST ModConfiguration VERSION: \nhttps://github.com/reckdave/Mod-Configuration/releases/tag/release1.1')
				config_node = node.MakeConfig(config_name,config_author,config_info)
				config_info = config_node.ConfigValues
			yield(get_tree(),"idle_frame")
	else:
		OS.alert("MISSING MODCONFIG, RESULTING TO DEFAULT VALUES", "ERROR")
		config_loaded = true

func _ready():
	yield(ConfigHandler(),"completed")
	#_newinstanceapp(3)
	print_log('CONFIG FOUND')
	var gui_visible = config_info['GUI_VISIBLE']
	$GUI.visible = gui_visible
func _process(_delta):
	if Tab.data["open"][1] == true and !kintiopatch:
		kintiopatch = true
		var kinitopatch_scene = kinitoscene.instance()
		var applic = get_parent().get_parent().get_node("1").get_child(0)
		_replace_scene(applic,kinitopatch_scene)
		print_log("REPLACED")
	elif Tab.data["open"][1] == false and kintiopatch:
		kintiopatch = false
