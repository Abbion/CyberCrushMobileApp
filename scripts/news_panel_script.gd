#Refactor 1
extends Control

@export var news_article_entry: PackedScene

@onready var decoration_separator: HSeparator = $main_margin/news_container/decoration_separator
@onready var post_background: PanelContainer = $main_margin/news_container/post_background
@onready var title_input: VBoxContainer = $main_margin/news_container/post_background/inner_margin/post_box/title_input
@onready var content_input: TextEdit = $main_margin/news_container/post_background/inner_margin/post_box/content_input
@onready var clear_buttton: Button = $main_margin/news_container/post_background/inner_margin/post_box/post_actions/clear_button
@onready var publish_button: Button = $main_margin/news_container/post_background/inner_margin/post_box/post_actions/publish_button
@onready var scroll_feed: ScrollContainer = $main_margin/news_container/scroll_feed
@onready var feed: VBoxContainer = $main_margin/news_container/scroll_feed/feed
@onready var spinner_container: CenterContainer = $main_margin/news_container/spinner_container
@onready var delete_post_title_label: Label = $overlay_margin/overlay_center/delete_post_window/delete_post_margin/delete_post_content/post_title_label
@onready var delete_post_overlay: MarginContainer = $overlay_margin

var _post_id_selected_for_deletion: int = -1

func _ready() -> void:
	if AppSessionState.can_publish_posts():
		decoration_separator.show()
		post_background.show()
	else:
		decoration_separator.hide()
		post_background.hide()
	
	refresh_news_feed()

func refresh_news_feed():
	spinner_container.show()
	scroll_feed.hide()
	
	var articles := await ServerRequest.news_feed()
	for article in articles:
		var id = article["id"]
		var author = article["author"]
		var date = article["timestamp"]
		var title = article["title"]
		var content = article["content"]
		
		var article_entry = news_article_entry.instantiate()
		article_entry.post_id = id
		article_entry.author = author
		article_entry.date = GlobalTypes.DateTime.from_string(date).get_string()
		article_entry.title = title
		article_entry.content = content
		feed.add_child(article_entry)
		
	spinner_container.hide()
	scroll_feed.show()

func send_article():
	if !AppSessionState.can_publish_posts():
		return

	var title: String = title_input.get_cleaned_text()
	if title.length() < 3:
		PopupDisplayServer.push_warning(tr("POST_TITLE_TOO_SHORT"))
		return
	if title.length() > 32:
		PopupDisplayServer.push_warning(tr("POST_TITLE_TOO_LONG"))
		return
	
	var content: String = content_input.get_cleaned_text()
	if content.length() < 3:
		PopupDisplayServer.push_warning(tr("POST_CONTENT_TOO_SHORT"))
		return
	if content.length() > 255:
		PopupDisplayServer.push_warning(tr("POST_CONTENT_TOO_LONG"))
		return
	
	var post_id := await ServerRequest.post_news_article(title, content)
	
	if post_id < 0:
		return
	
	var article_entry = news_article_entry.instantiate()
	article_entry.post_id = post_id
	article_entry.author = AppSessionState.get_username()
	article_entry.date = GlobalTypes.DateTime.now().get_string()
	article_entry.title = title
	article_entry.content = content
	
	feed.add_child(article_entry)
	feed.move_child(article_entry, 0)
	
	title_input.clear_text_box()
	content_input.clear_text_box()

func on_publish_button_pressed() -> void:
	publish_button.disabled = true
	clear_buttton.disabled = true
	send_article()
	publish_button.disabled = false
	clear_buttton.disabled = false

func on_clear_button_pressed() -> void:
	title_input.clear_text_box()
	content_input.clear_text_box()

func on_tree_entered() -> void:
	GlobalSignals.delete_post.connect(delete_post)

func on_tree_exited() -> void:
	GlobalSignals.delete_post.disconnect(delete_post)

func delete_post(id: int, title: String) -> void:
	_post_id_selected_for_deletion = id
	delete_post_title_label.text = title
	delete_post_overlay.show()

func on_delete_post_cancel_pressed() -> void:
	delete_post_overlay.hide()
	_post_id_selected_for_deletion = -1
	
func on_delete_post_confirm_pressed() -> void:
	var status = await ServerRequest.delete_news_article(_post_id_selected_for_deletion)
	
	if status == true:
		for article in feed.get_children():
			if article.post_id == _post_id_selected_for_deletion:
				feed.remove_child(article)
				article.queue_free()
	
	delete_post_overlay.hide()
	_post_id_selected_for_deletion = -1
