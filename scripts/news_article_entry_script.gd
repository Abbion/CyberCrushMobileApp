#Refactor 1
extends PanelContainer

@export var author: String
@export var date: String
@export var title: String
@export var content: String

@onready var author_label: Label = $article_margin/article/publish_data/author_label
@onready var date_label: Label = $article_margin/article/publish_data/date_label
@onready var title_label: Label = $article_margin/article/title_label
@onready var content_label: Label = $article_margin/article/content_label

func _ready() -> void:
	author_label.text = author
	date_label.text = date
	title_label.text = title
	content_label.text = content
