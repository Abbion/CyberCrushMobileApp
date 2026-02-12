#Refactor 1
extends Control

@export var news_article_entry: PackedScene

@onready var feed: VBoxContainer = $news_container/scroll_feed/feed
@onready var title_input: LineEdit = $news_container/post_box_margin/post_box/title_input
@onready var content_input: TextEdit = $news_container/post_box_margin/post_box/content_input

@onready var scroll_feed: ScrollContainer = $news_container/scroll_feed
@onready var spinner_container: CenterContainer = $news_container/spinner_container

func _ready() -> void:
	refresh_news_feed()

func refresh_news_feed():
	spinner_container.show()
	scroll_feed.hide()
	
	var articles := await ServerRequest.news_feed()
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
		feed.add_child(article_entry)
		
	spinner_container.hide()
	scroll_feed.show()

func send_article():
	var title := title_input.text
	if title.length() < 3:
		PopupDisplayServer.push_warning("Tytuł posta jest za krótki. Wymagane minimum 3 znaki")
		return
	if title.length() > 32:
		PopupDisplayServer.push_warning("Tytuł posta jest za długi. Ograniczenie maksymalnie 32 zaków")
		return
	
	var content: String = content_input.get_cleaned_text()
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
	
	feed.add_child(article_entry)
	feed.move_child(article_entry, 0)
	
	title_input.clear()
	content_input.clear()

func on_publush_button_pressed() -> void:
	send_article()
