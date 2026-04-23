#Refactor 1
extends MarginContainer

@export var post_id: int
@export var author: String
@export var date: String
@export var title: String
@export var content: String

@onready var author_label: Label = $autor_label_anchor/article_data/author_label
@onready var date_label: Label = $article_margin/inner_margin/article/publish_data/date_label
@onready var title_label: Label = $article_margin/inner_margin/article/title_label
@onready var content_label: Label = $article_margin/inner_margin/article/content_label
@onready var delete_post_button: Button = $autor_label_anchor/article_data/delete_post

func _ready() -> void:
	author_label.text = author
	date_label.text = date
	title_label.text = title
	content_label.text = content
	
	if AppSessionState.get_username() == author:
		delete_post_button.show()
		delete_post_button.connect("pressed", on_delete_post_pressed)
	else:
		delete_post_button.hide()

func on_delete_post_pressed():
	GlobalSignals.delete_post.emit(post_id, title)
