extends Node

var config = ConfigFile.new()
const configuration_path = "user://configuration.cfg"

var token : String = ""

func get_server_token():
	if not token.is_empty():
		return token
	
	var err = config.load(configuration_path)
	
	if err != OK:
		print("Cannot open the configuration file to load the token.")
		return ""
	
	token = config.get_value("server_access", "server_token", "");
	return token
	
func set_server_token(new_token: String):
	token = new_token;
	config.set_value("server_access", "server_token", token)
	config.save(configuration_path);
