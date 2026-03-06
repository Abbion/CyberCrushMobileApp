#Refactor 1
extends Node

const JSON_HTTP_HEADER = [
		"Content-Type: application/json"
	]

const HTTP_SUCCESS_CODE: int = 200
const MAIN_PAGE_SCENE: String = "res://scenes/pages/main_page.tscn"
const LOGIN_PAGE_SCENE: String = "res://scenes/pages/login_page.tscn"
const MAX_MEMBERS_IN_GROUP_CHAT: int = 16
