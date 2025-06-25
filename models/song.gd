extends Node
class_name Song

enum SearchScope {
	SONG_TITLE,
	SONG_ARTIST,
	SONG_GENRE
}

var song_id            : int
## 歌名
var song_title         : String:
	set(value):
		song_title = value
		var pinyin = Pinyin.get_pinyin(song_title)
		song_title_pinyin = ",".join(pinyin).to_lower()
## 歌名拼音（搜索用）
var song_title_pinyin  : String
## 歌手
var song_artist        : String:
	set(value):
		song_artist = value
		var pinyin = Pinyin.get_pinyin(song_artist)
		song_artist_pinyin = ",".join(pinyin).to_lower()
## 歌手拼音（搜索用）
var song_artist_pinyin : String
## 歌词摘要
var song_lyric         : String
## 曲风
var song_genre         : String:
	set(value):
		song_genre = value
		var pinyin = Pinyin.get_pinyin(song_genre)
		song_genre_pinyin = ",".join(pinyin).to_lower()
## 曲风拼音（搜索用）
var song_genre_pinyin  : String
## 备注
var song_remark        : String
## 听歌链接
var song_link          : String
var inserted_datetime  : String
var updated_datetime   : String

static func from_dict(data: Dictionary) -> Song:
	var song = Song.new()
	song.song_id           = data["song_id"]
	song.song_title        = data["song_title"]
	song.song_artist       = data["song_artist"]
	song.song_lyric        = data["song_lyric"]
	song.song_genre        = data["song_genre"]
	song.song_remark       = data["song_remark"]
	song.song_link         = data["song_link"]
	if data["inserted_datetime"]:
		song.inserted_datetime = data["inserted_datetime"]
	if data["updated_datetime"]:
		song.updated_datetime  = data["updated_datetime"]
	return song

func to_dict() -> Dictionary:
	var data = {}
	data["song_title"]         = self.song_title
	data["song_title_pinyin"]  = self.song_title_pinyin
	data["song_artist"]        = self.song_artist
	data["song_artist_pinyin"] = self.song_artist_pinyin
	data["song_lyric"]         = self.song_lyric
	data["song_genre"]         = self.song_genre
	data["song_genre_pinyin"]  = self.song_genre_pinyin
	data["song_remark"]        = self.song_remark
	data["song_link"]          = self.song_link
	if self.inserted_datetime:
		data["inserted_datetime"]  = self.inserted_datetime
	if self.updated_datetime:
		data["updated_datetime"]   = self.updated_datetime
	return data
