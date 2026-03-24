#Refactor 1
extends Node

var _app_config: ConfigFile = ConfigFile.new()
const _APP_CONFIG_PATH: String = "user://app.cfg"
var _app_config_loaded = false

var app_selector_height: int = 0

var _token: String = ""
var _username: String = ""
var _can_publish_posts: bool = false
var _cyber_defence_level: int = 1
var _language := GlobalTypes.LANGUAGE.ENGLISH
var _is_mobile := false
var _server_game_state : GlobalTypes.ServerGameState

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

func set_can_publish_posts(can_publish: bool) -> void:
	_can_publish_posts = can_publish

func can_publish_posts() -> bool:
	return _can_publish_posts

func is_game_online() -> bool:
	return _server_game_state.is_online

func get_info_panel_text() -> String:
	return _server_game_state.info_panel_text

func set_cyber_defence_level(level: int) -> void:
	_cyber_defence_level = level
	GlobalSignals.cyber_defence_pack_changed.emit(_cyber_defence_level)
	
func get_cyber_defence_level() -> int:
	return _cyber_defence_level

func clear() -> void:
	_token = ""
	_username = ""
	_can_publish_posts = false
	_cyber_defence_level = 1

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

func set_server_game_state(server_game_state: GlobalTypes.ServerGameState):
	_server_game_state = server_game_state

func get_language() -> GlobalTypes.LANGUAGE:
	return _language
