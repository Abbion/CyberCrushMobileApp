extends Control

@export var news_article_entry: PackedScene

@onready var news_box: VBoxContainer = $VBoxContainer/feed/news_box
@onready var title_input = $VBoxContainer/post_box/title_input
@onready var content_input = $VBoxContainer/post_box/content_input

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
	
	if len(title) < 3 or len(title) > 28:
		return
	
	var content: String = content_input.text
	if len(content) < 1 or len(content) > 256:
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
