#Refactor 1
extends Node

@warning_ignore("unused_signal") signal new_chat_created(chat_id: int)
@warning_ignore("unused_signal") signal close_chat_board()
@warning_ignore("unused_signal") signal consume_popup(popup_info: PopupDisplayServer.PopupInfo)
@warning_ignore("unused_signal") signal popup_closed()
@warning_ignore("unused_signal") signal logout()
@warning_ignore("unused_signal") signal app_language_changed(language: GlobalTypes.LANGUAGE)
