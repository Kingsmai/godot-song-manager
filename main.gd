@tool
extends PanelContainer

@onready var search_song_line_edit: LineEdit = %SearchSongLineEdit
@onready var search_song_option_button: OptionButton = %SearchSongOptionButton

@onready var add_song_button: Button = %AddSongButton

@onready var song_tree: Tree = %SongTree

@onready var song_title_line_edit: LineEdit = %SongTitleLineEdit
@onready var song_artist_line_edit: LineEdit = %SongArtistLineEdit
@onready var song_lyric_line_edit: LineEdit = %SongLyricLineEdit
@onready var song_genre_line_edit: LineEdit = %SongGenreLineEdit
@onready var song_remark_text_edit: TextEdit = %SongRemarkTextEdit
@onready var song_link_line_edit: LineEdit = %SongLinkLineEdit

@onready var save_button: Button = %SaveButton
@onready var cancel_button: Button = %CancelButton

@onready var delete_song_window: DeleteSongWindow = %DeleteSongWindow

#@export_tool_button("Dev Refresh", "res://assets/flag.svg")
#var editor_dev_refresh_btn = dev_refresh

enum State {
	ADD_SONG,
	EDIT_SONG
}

var state := State.ADD_SONG

func _on_add_song_button_pressed() -> void:
	_clear_fields()

func _on_save_button_pressed() -> void:
	var song = Song.new()
	song.song_title = song_title_line_edit.text
	song.song_artist = song_artist_line_edit.text
	song.song_lyric = song_lyric_line_edit.text
	song.song_genre = song_genre_line_edit.text
	song.song_remark = song_remark_text_edit.text
	song.song_link = song_link_line_edit.text
	if song_tree.get_selected():
		song.song_id = song_tree.get_selected().get_metadata(0)
		song.updated_datetime = Time.get_datetime_string_from_system()
		Database.update_song(song)
	else:
		song.inserted_datetime = Time.get_datetime_string_from_system()
		Database.add_song(song)
	load_song_tree()
	_clear_fields()

func _on_cancel_button_pressed() -> void:
	if state == State.EDIT_SONG and song_tree.get_selected():
		var song_node = song_tree.get_selected()
		var song_id = song_node.get_metadata(0)
		var song_title = song_node.get_text(0)
		var song_artist = song_node.get_text(1)
		delete_song_window.popup()
		delete_song_window.set_metadata(song_id, song_title, song_artist)

func _on_delete_song_window_confirmed() -> void:
	_clear_fields()
	load_song_tree()

func _on_song_tree_item_selected() -> void:
	var song_id = song_tree.get_selected().get_metadata(0)
	var selected_song = Database.get_song_by_id(song_id)
	if selected_song:
		song_title_line_edit.text = selected_song.song_title
		song_artist_line_edit.text = selected_song.song_artist
		song_lyric_line_edit.text = selected_song.song_lyric
		song_genre_line_edit.text = selected_song.song_genre
		song_remark_text_edit.text = selected_song.song_remark
		song_link_line_edit.text = selected_song.song_link
	save_button.text = "Update"
	save_button.theme_type_variation = "ButtonSuccess"
	cancel_button.text = "Delete"
	cancel_button.theme_type_variation = "ButtonDanger"
	state = State.EDIT_SONG

func _on_search_song_line_edit_text_changed(new_text: String):
	var search_scope = search_song_option_button.get_selected_id()
	load_song_tree(new_text, search_scope)

## 作用于【新增歌曲时】，歌名 / 歌手 / 曲风 输入框被编辑时。左侧列表会实时显示，
## 提醒用户这首歌是否被添加过
func _on_song_details_edited(_new_song: String) -> void:
	if state == State.EDIT_SONG: return
	song_tree.clear()
	var songs = Database.query_songs_by_fields(
		song_title_line_edit.text,
		song_artist_line_edit.text,
		song_genre_line_edit.text
	)
	var root = song_tree.create_item()
	for song in songs:
		var song_node = root.create_child()
		_set_song_tree_node(song_node, song)

func song_tree_setup() -> void:
	song_tree.set_column_title(0, "Title")
	song_tree.set_column_title(1, "Artist")
	song_tree.set_column_title(2, "Genre")
	song_tree.set_column_title(3, "Notes")

func song_tree_undo_setup() -> void:
	song_tree.set_column_title(0, "")
	song_tree.set_column_title(1, "")
	song_tree.set_column_title(2, "")
	song_tree.set_column_title(3, "")

func load_song_tree(search_pattern: String = "", search_scope: Song.SearchScope = Song.SearchScope.SONG_TITLE) -> void:
	song_tree.clear()
	var songs = Database.get_songs(search_pattern, search_scope)
	var root = song_tree.create_item()
	for song in songs:
		var song_node = root.create_child()
		_set_song_tree_node(song_node, song)

func setup_search_scope_option_button() -> void:
	search_song_option_button.clear()
	for search_scope: String in Song.SearchScope:
		var item = search_scope.split("_")[1].capitalize() if search_scope.contains("_") else search_scope.capitalize()
		search_song_option_button.add_item(item)

### DEGUG: 开发时用的，点击 Dev Refresh 按钮后，设置 Tree 列表名
#func dev_refresh():
	## Set tree column title
	#var undo_redo = EditorInterface.get_editor_undo_redo()
	#undo_redo.create_action("Set song tree column title")
	#undo_redo.add_do_method(self, song_tree_setup.get_method())
	#undo_redo.add_undo_method(self, song_tree_undo_setup.get_method())
	#undo_redo.commit_action()

func _ready() -> void:
	add_song_button.pressed.connect(_on_add_song_button_pressed)
	song_tree_setup()
	save_button.pressed.connect(_on_save_button_pressed)
	load_song_tree()
	song_tree.item_selected.connect(_on_song_tree_item_selected)
	setup_search_scope_option_button()
	search_song_line_edit.text_changed.connect(_on_search_song_line_edit_text_changed)
	song_title_line_edit.text_changed.connect(_on_song_details_edited)
	song_artist_line_edit.text_changed.connect(_on_song_details_edited)
	song_genre_line_edit.text_changed.connect(_on_song_details_edited)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	delete_song_window.confirmed.connect(_on_delete_song_window_confirmed)

func _set_song_tree_node(song_node: TreeItem, song: Song) -> void:
	song_node.set_text(0, song.song_title)
	song_node.set_text(1, song.song_artist)
	song_node.set_text(2, song.song_genre)
	song_node.set_text(3, song.song_remark)
	song_node.set_metadata(0, song.song_id)

func _clear_fields() -> void:
	song_title_line_edit.text = ""
	song_artist_line_edit.text = ""
	song_lyric_line_edit.text = ""
	song_genre_line_edit.text = ""
	song_remark_text_edit.text = ""
	song_link_line_edit.text = ""
	song_tree.deselect_all()
	save_button.text = "Save"
	save_button.theme_type_variation = "ButtonPrimary"
	cancel_button.text = "Cancel"
	cancel_button.theme_type_variation = ""
	state = State.ADD_SONG
