#Refactor 1
extends Node

var _app_config: ConfigFile = ConfigFile.new()
const _APP_CONFIG_PATH: String = "user://app.cfg"
var _app_config_loaded = false

var app_selector_height: int = 0

var _token: String = ""
var _username: String = ""
var _language := GlobalTypes.LANGUAGE.ENGLISH
var _is_mobile := false

func _ready() -> void:
	if _app_config.load(_APP_CONFIG_PATH) == OK:
		_app_config_loaded = true
		_language = _app_config.get_value("general", "language", GlobalTypes.LANGUAGE.ENGLISH)
	
	set_language(_language)
	if OS.get_name() in ["Android", "iOS"]:
		_is_mobile = true

func os_is_mobile() -> bool:
	return _is_mobile

func get_server_token() -> String:
	return _token
	
func set_server_token(new_token: String) -> void:
	_token = new_token

func get_username() -> String:
	return _username

func set_username(new_username: String) -> void:
	_username = new_username

func clear() -> void:
	_token = ""
	_username = ""

func set_language(language: GlobalTypes.LANGUAGE):
	_language = language
	match _language:
		GlobalTypes.LANGUAGE.ENGLISH:
			TranslationServer.set_locale("en")
		GlobalTypes.LANGUAGE.POLISH:
			TranslationServer.set_locale("pl")
	
	GlobalSignals.emit_signal("app_language_changed", _language)
	
	_app_config.set_value("general", "language", _language)
	_app_config.save(_APP_CONFIG_PATH)

func get_language() -> GlobalTypes.LANGUAGE:
	return _language
