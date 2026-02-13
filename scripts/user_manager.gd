extends Node

var credentials_file: ConfigFile = ConfigFile.new()
const credentials_file_path: String = "user://user_db.cfg"
var saved_credentials: int = 0

func _ready() -> void:
	var err := credentials_file.load(credentials_file_path)
	
	if err != OK:
		return

	saved_credentials = credentials_file.get_value("metadata", "saved_credentials", 0)

func get_all_saved_credentials() -> Dictionary:
	var credentials := {}
	
	for index in range(saved_credentials):
		var section := "user_%s" % index
		var username = credentials_file.get_value(section, "username", "")
		var token = credentials_file.get_value(section, "token", "")
		credentials.set(username, token)
		
	return credentials

func get_token(username: String) -> String:
	var token_index := find_section_index_for_username(username)
	if token_index == -1:
		return ""
	
	var section := "user_%s" % token_index
	return credentials_file.get_value(section, "token", "")

func save_user_credentails(username: String, token: String) -> bool:
	if find_section_index_for_username(username) != -1:
		if update_token(username, token) == false:
			return true
	
	var section := "user_%s" % saved_credentials
	credentials_file.set_value(section, "username", username)
	credentials_file.set_value(section, "token", token)
	credentials_file.set_value("metadata", "saved_credentials", saved_credentials + 1)
	
	if save_db("save_user_credentails") == false:
		return false
	
	saved_credentials += 1
	return true

func find_section_index_for_username(username: String) -> int:
	for index in range(saved_credentials):
		var section := "user_%s" % index
		var saved_username = credentials_file.get_value(section, "username", "")
		if saved_username == username:
			return index
	return -1

func remove_user_credentails(username: String) -> bool:
	var remove_index := find_section_index_for_username(username)
	if remove_index == -1:
		return false
		
	var section := "user_%s" % remove_index
	credentials_file.erase_section(section)
	
	for index in range(remove_index, saved_credentials - 1):
		var new_section := "user_%s" % index
		var old_section := "user_%s" % (index + 1)
		if rename_user_section(old_section, new_section) == false:
			PopupDisplayServer.push_error("Błąd podczas zwalniania danych uwierzytelniających użytkownika")
			credentials_file.clear()
			return false
	
	saved_credentials -= 1
	return true

func rename_user_section(old_section: String, new_section: String) -> bool:
	var username = credentials_file.get_value(old_section, "username", "")
	var token = credentials_file.get_value(old_section, "token", "")
	
	if username.is_empty() or token.is_empty():
		return false
	
	credentials_file.erase_section(old_section)
	credentials_file.set_value(new_section, "username", username)
	credentials_file.set_value(new_section, "token", token)
	
	return save_db("rename_user_section")

func save_as_last_used(username: String, token: String) -> bool:
	credentials_file.set_value("last_used_credentials", "username", username)
	credentials_file.set_value("last_used_credentials", "token", token)
	return save_db("save_as_last_used")

func clear_last_used_credentials() -> bool:
	return save_as_last_used("", "")

func get_last_used_credentials() -> Dictionary:
	var credentials = {}
	
	if credentials_file.has_section("last_used_credentials") == false:
		return credentials
	
	var username = credentials_file.get_value("last_used_credentials", "username", "")
	var token = credentials_file.get_value("last_used_credentials", "token", "")
	
	if username.is_empty() or token.is_empty():
		return credentials
	
	credentials.set("username", username)
	credentials.set("token", token)
	return credentials
	
func update_token(username: String, token: String) -> bool:
	var update_index := find_section_index_for_username(username)
	if update_index == -1:
		return false
	
	var section := "user_%s" % update_index
	credentials_file.set_value(section, "token", token)
	return save_db("update_token")

func save_db(caller: String) -> bool:
	var err := credentials_file.save(credentials_file_path)
	if err == OK:
		return true
		
	PopupDisplayServer.push_error("Błąd zapisu danych użytkownika", "Error: %s. Origin: %s" % [err, caller])
	return false
