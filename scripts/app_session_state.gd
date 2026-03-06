#Refactor 1
extends Node

var app_selector_height: int = 0

var _token: String = ""
var _username: String = ""
var _language := GlobalTypes.LANGUAGE.ENGLISH
var _is_mobile := false

func _ready() -> void:
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

func get_language() -> GlobalTypes.LANGUAGE:
	return _language
