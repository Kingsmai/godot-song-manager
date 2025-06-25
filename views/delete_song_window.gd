extends Window
class_name DeleteSongWindow

signal confirmed
signal cancelled

@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

@onready var song_detail_label: Label = %SongDetailLabel

var selected_song_id : int
var selected_song_title: String
var selected_song_artist: String

func set_metadata(song_id: int, song_title: String, song_artist: String):
	selected_song_id = song_id
	selected_song_title = song_title
	selected_song_artist = song_artist
	song_detail_label.text = "Song Title: %s\nArtist: %s" % [selected_song_title, selected_song_artist]

func _ready() -> void:
	confirm_button.pressed.connect(func ():
		Database.delete_song(selected_song_id)
		confirmed.emit()
		self.hide()
	)
	cancel_button.pressed.connect(func ():
		cancelled.emit()
		self.hide()
	)
