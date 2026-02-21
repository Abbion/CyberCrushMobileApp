#Refactor 1
extends Node

var app_selector_height: int = 0

var token: String = ""
var username: String = ""

func get_server_token() -> String:
	return token
	
func set_server_token(new_token: String) -> void:
	token = new_token

func get_username() -> String:
	return username

func set_username(new_username: String) -> void:
	username = new_username

func clear() -> void:
	token = ""
	username = ""
