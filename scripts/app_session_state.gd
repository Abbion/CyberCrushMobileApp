extends Node

var config = ConfigFile.new()
const configuration_path = "user://configuration.cfg"

enum UserDataType {
	USERNAME,
	PERSONAL_NUMBER
}

var token: String = ""
var user_data: Dictionary = { UserDataType.USERNAME: "", UserDataType.PERSONAL_NUMBER: "" }

func get_server_token() -> String:	
	if not token.is_empty():
		return token
	
	var err = config.load(configuration_path)
	
	if err != OK:
		print("AppState: Error cannot open the configuration file to load the token.")
		return ""
	
	token = config.get_value("server_access", "server_token", "");
	return token
	
func set_server_token(new_token: String) -> bool:
	token = new_token;
	config.set_value("server_access", "server_token", token)
	var save_result = config.save(configuration_path);
	
	if save_result != OK:
		print("AppState: Error cannot save token")
		return false
	return true

func get_username() -> String:
	if not user_data[UserDataType.USERNAME].is_empty():
		return user_data[UserDataType.USERNAME]
		
	var err = config.load(configuration_path)
	
	if err != OK:
		print("AppState: Error cannot open the configuration file to load the username.")
		return ""
	
	user_data[UserDataType.USERNAME] = config.get_value("user_data", "username", "");
	return user_data[UserDataType.USERNAME]

func get_personal_code() -> String:
	if not user_data[UserDataType.PERSONAL_NUMBER].is_empty():
		return user_data[UserDataType.PERSONAL_NUMBER]
		
	var err = config.load(configuration_path)
	
	if err != OK:
		print("AppState: Error cannot open the configuration file to load the personal code.")
		return ""
	
	user_data[UserDataType.PERSONAL_NUMBER] = config.get_value("user_data", "personal_code", "");
	return user_data[UserDataType.PERSONAL_NUMBER]

func set_user_data(username: String, personal_number: String) -> bool:
	user_data[UserDataType.USERNAME] = username
	user_data[UserDataType.PERSONAL_NUMBER] = personal_number
	
	config.set_value("user_data", "username", username)
	config.set_value("user_data", "personal_number", personal_number)
	var save_result = config.save(configuration_path);
	
	if save_result != OK:
		print("AppState: Error cannot save user data")
		return false
	return true

func clear() -> bool:
	token = ""
	user_data[UserDataType.USERNAME] = ""
	user_data[UserDataType.PERSONAL_NUMBER] = ""
	
	config.set_value("user_data", "username", "")
	config.set_value("user_data", "personal_number", "")
	config.set_value("server_access", "server_token", "")
	var save_result = config.save(configuration_path);
	
	if save_result != OK:
		print("AppState: Error cannot clear state")
		return false
	return true
