extends Node

enum CHAT_MESSAGE_ALIGNMENT { LEFT, RIGHT }
enum CHAT_TYPE{ DIRECT, GROUP }
enum REALTIME_CHAT_SOCKET_STATE{ NULL, CREATED, INITIALIZED, CONNECTED, CLOSED }

class DateTime:
	var year: int = 0
	var month: int = 0
	var day: int = 0
	var hour: int = 0
	var minute: int = 0
	
	static func from_string(naive_timestamp: String) -> DateTime:
		# When the serwer sends the timestamp through serialization there is a T -
		# character that separates the date from time
		# But when the timestamp is converted into a string the T character is missing
		# This replace unifies the format
		naive_timestamp = naive_timestamp.replace("T", " ");
		
		# The format is [yyyy-mm-dd hh:mm:ss.ms]
		var dateTime: DateTime = DateTime.new()
		var dash_split = naive_timestamp.split("-")
		
		if dash_split.size() < 3:
			return dateTime
		
		var dt_split = dash_split.get(2).split(" ")
		
		if dt_split.size() < 2:
			return dateTime
		
		var time_components = dt_split.get(1).split(":")
		
		if time_components.size() < 3:
			return dateTime
		
		dateTime.year = int(dash_split.get(0))
		dateTime.month = int(dash_split.get(1))
		dateTime.day = int(dt_split.get(0))
		dateTime.hour = int(time_components.get(0))
		dateTime.minute = int(time_components.get(1))
		
		return dateTime
	
	static func now() -> DateTime:
		var dateTime: DateTime = DateTime.new()
		var time = Time.get_datetime_dict_from_system(true)
		dateTime.year = time.year
		dateTime.month = time.month
		dateTime.day = time.day
		dateTime.hour = time.hour
		dateTime.minute = time.minute
		
		return dateTime
	
	func get_string() -> String:
		return "%02d/%02d/%s %02d:%02d" %[day, month, year, hour, minute]
