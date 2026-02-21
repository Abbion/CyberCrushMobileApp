#Refactor 1
extends Node

enum CHAT_MESSAGE_ALIGNMENT { LEFT, RIGHT }
enum CHAT_TYPE{ DIRECT, GROUP }
enum REALTIME_CHAT_SOCKET_STATE{ NULL, CREATED, INITIALIZED, CONNECTED, CLOSED }
const BASE_YEAR = 2000

class UserData:
	var username: String = ""
	var personal_number: int = 0
	var extra_data: Dictionary = {}

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
		var dateTime := DateTime.new()
		var dash_split := naive_timestamp.split("-")
		
		if dash_split.size() < 3:
			return dateTime
		
		var dt_split := dash_split.get(2).split(" ")
		
		if dt_split.size() < 2:
			return dateTime
		
		var time_components := dt_split.get(1).split(":")
		
		if time_components.size() < 3:
			return dateTime
		
		dateTime.year = int(dash_split.get(0))
		dateTime.month = int(dash_split.get(1))
		dateTime.day = int(dt_split.get(0))
		dateTime.hour = int(time_components.get(0))
		dateTime.minute = int(time_components.get(1))
		
		return dateTime
	
	static func now() -> DateTime:
		var dateTime := DateTime.new()
		var time := Time.get_datetime_dict_from_system(true)
		dateTime.year = time.year
		dateTime.month = time.month
		dateTime.day = time.day
		dateTime.hour = time.hour
		dateTime.minute = time.minute
		
		return dateTime
	
	func is_leap_year() -> bool:
		return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
	
	func days_in_year() -> int:
		return 366 if is_leap_year() else 365

	func days_in_month() -> int:
		match month:
			1, 3, 5, 7, 8, 10, 12:
				return 31
			4, 6, 9, 11:
				return 30
			2:
				return 29 if is_leap_year() else 28
			_:
				return 0
	
	func minutes_since_base_year() -> int:
		var total_minutes := 0
		
		for y in range(BASE_YEAR, year):
			total_minutes += days_in_year() * 24 * 60
		
		for m in range(1, month):
			total_minutes += days_in_month() * 24 * 60
		
		total_minutes += (day - 1) * 24 * 60
		
		total_minutes += hour * 60
		total_minutes += minute
		
		return total_minutes
	
	func get_string() -> String:
		var default_format := "%02d/%02d/%s %02d:%02d" %[day, month, year, hour, minute]
		var minutes_for_default_format := 24 * 60;
		var current_datetime := now()
		
		var minutes_in_self := minutes_since_base_year()
		var minutes_in_current := current_datetime.minutes_since_base_year()
		var minutes_diff := minutes_in_current - minutes_in_self
		
		if minutes_diff > minutes_for_default_format:
			return default_format
		
		var hours_elapsed := int(floor(float(minutes_diff) / 60.0))
		
		if hours_elapsed >= 1:
			if hours_elapsed >= 2:
				return "%s godziny temu" % floor(hours_elapsed)
			else:
				return "godzinę temu"
		
		var minutes_elapsed_diff := minutes_diff - (hours_elapsed * 60)
		
		if minutes_elapsed_diff < 60:
			if minutes_elapsed_diff <= 1:
				return "teraz"
			if minutes_elapsed_diff <= 4:
				return "%s minuty temu" % floor(minutes_elapsed_diff)
			else:
				return "%s minut temu" % floor(minutes_elapsed_diff)
		
		return default_format
