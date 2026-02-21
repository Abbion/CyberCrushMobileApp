#Refactor 1
extends Node

signal new_chat_created(chat_id: int)
signal close_chat_board()
signal consume_popup(popup_info: PopupDisplayServer.PopupInfo)
signal popup_closed()
signal logout()
