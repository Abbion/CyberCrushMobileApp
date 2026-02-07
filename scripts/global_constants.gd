extends Node

const JSON_HTTP_HEADER = [
		"Content-Type: application/json"
	]

const HTTP_SUCCESS_CODE = 200
const MAIN_PAGE_SCENE = "res://scenes/pages/main_page.tscn"
const LOGIN_PAGE_SCENE = "res://scenes/pages/login_page.tscn"

const MAX_MEMBERS_IN_GROUP_CHAT = 16
const DEFAULT_VIEWPORT_HEIGHT = 720

# TODO: Do not use values with a m prefix
var m_is_mobile = false
func _ready() -> void:
	if OS.get_name() in ["Android", "iOS"]:
		m_is_mobile = true

func os_is_mobile() -> bool:
	return m_is_mobile
