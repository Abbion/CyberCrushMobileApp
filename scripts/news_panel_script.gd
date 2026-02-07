extends Control

@export var news_article_entry: PackedScene

@onready var news_box: VBoxContainer = $VBoxContainer/feed/news_box
@onready var title_input: LineEdit = $VBoxContainer/post_box_margin/post_box/title_input
@onready var content_input: TextEdit = $VBoxContainer/post_box_margin/post_box/long_text_input

func _ready() -> void:
	refresh_news_feed()

func refresh_news_feed():
	var articles = await ServerRequest.news_feed()
	for article in articles:
		var author = article["author"]
		var date = article["timestamp"]
		var title = article["title"]
		var content = article["content"]
		
		var article_entry = news_article_entry.instantiate()
		article_entry.author = author
		article_entry.date = GlobalTypes.DateTime.from_string(date).get_string()
		article_entry.title = title
		article_entry.content = content
		news_box.add_child(article_entry)

func send_article():
	var title: String = title_input.text
	if title.length() < 3:
		PopupDisplayServer.push_warning("Tytuł posta jest za krótki. Wymagane minimum 3 znaki")
		return
	if title.length() > 32:
		PopupDisplayServer.push_warning("Tytuł posta jest za długi. Ograniczenie maksymalnie 32 zaków")
		return
	
	var content: String = content_input.text
	if content.length() < 3:
		PopupDisplayServer.push_warning("Zawartość posta jest za krótka. Wymagane minimum 3 znaki")
		return
	if content.length() > 255:
		PopupDisplayServer.push_warning("Zawartość posta jest za krótka. Ograniczenie maksymalnie 256 znaków")
		return
	
	ServerRequest.post_news_article(title, content)
	
	var article_entry = news_article_entry.instantiate()
	article_entry.author = AppSessionState.get_username()
	article_entry.date = GlobalTypes.DateTime.now().get_string()
	article_entry.title = title
	article_entry.content = content
	
	news_box.add_child(article_entry)
	news_box.move_child(article_entry, 0)

func _on_publush_button_pressed() -> void:
	send_article()
