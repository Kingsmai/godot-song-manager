extends Node

const DB_PATH = "song_manager"

const SONGS_TABLE_NAME = "songs"

var db: SQLite = SQLite.new()

func _ready() -> void:
	initialize_database()

func initialize_database() -> void:
	var db_dir = DB_PATH.get_base_dir()
	DirAccess.make_dir_recursive_absolute(db_dir)
	if not DirAccess.dir_exists_absolute(db_dir):
		DirAccess.make_dir_recursive_absolute(db_dir)
	db.verbosity_level = 0
	db.path = DB_PATH
	db.open_db()
	create_song_table()

func create_song_table() -> void:
	var song_table_dict = {
		song_id            = { data_type = "int" , not_null = true, primary_key = true, auto_increment = true },
		song_title         = { data_type = "text", not_null = true  },
		song_title_pinyin  = { data_type = "text", not_null = true  },
		song_artist        = { data_type = "text", not_null = false },
		song_artist_pinyin = { data_type = "text", not_null = false },
		song_lyric         = { data_type = "text", not_null = false },
		song_genre         = { data_type = "text", not_null = false },
		song_genre_pinyin  = { data_type = "text", not_null = false },
		song_remark        = { data_type = "text", not_null = false },
		song_link          = { data_type = "text", not_null = false },
		inserted_datetime  = { data_type = "text", not_null = true  },
		updated_datetime   = { data_type = "text", not_null = false },
		deleted            = { data_type = "int" , not_null = true , default = 0 },
		deleted_datetime   = { data_type = "text", not_null = false }
	}
	db.create_table(SONGS_TABLE_NAME, song_table_dict)

func get_songs(search_pattern: String = "", search_scope: Song.SearchScope = Song.SearchScope.SONG_TITLE) -> Array[Song]:
	var result: Array
	if search_pattern.strip_edges().is_empty():
		result = db.select_rows(SONGS_TABLE_NAME, "deleted != 1", ["*"])
	else:
		var pattern := "%%%s%%" % search_pattern  # 安全拼接通配符
		var condition: String = "deleted != 1 AND "
		match search_scope:
			Song.SearchScope.SONG_TITLE:
				condition = "song_title LIKE '%s' OR song_title_pinyin LIKE '%s'" % [pattern, pattern]
			Song.SearchScope.SONG_ARTIST:
				condition = "song_artist LIKE '%s' OR song_artist_pinyin LIKE '%s'" % [pattern, pattern]
			Song.SearchScope.SONG_GENRE:
				condition = "song_genre LIKE '%s' OR song_genre_pinyin LIKE '%s'" % [pattern, pattern]
		result = db.select_rows(SONGS_TABLE_NAME, condition, ["*"])
	var songs: Array[Song] = []
	for row in result:
		songs.append(Song.from_dict(row))
	return songs

func query_songs_by_fields(song_title: String = "", song_artist: String = "", song_genre: String = "") -> Array[Song]:
	var conditions: Array[String] = []
	# 拼接 song_title 条件
	if not song_title.strip_edges().is_empty():
		var pattern := "%%%s%%" % song_title.strip_edges()
		conditions.append("(song_title LIKE '%s' OR song_title_pinyin LIKE '%s')" % [pattern, pattern])
	# 拼接 song_artist 条件
	if not song_artist.strip_edges().is_empty():
		var pattern := "%%%s%%" % song_artist.strip_edges()
		conditions.append("(song_artist LIKE '%s' OR song_artist_pinyin LIKE '%s')" % [pattern, pattern])
	# 拼接 song_genre 条件
	if not song_genre.strip_edges().is_empty():
		var pattern := "%%%s%%" % song_genre.strip_edges()
		conditions.append("(song_genre LIKE '%s' OR song_genre_pinyin LIKE '%s')" % [pattern, pattern])
	# 合并 WHERE 子句
	var where_clause := "deleted != 1"
	if conditions.size() > 0:
		where_clause += " AND "
		where_clause += " AND ".join(conditions)
	# 查询数据库
	var result := db.select_rows(SONGS_TABLE_NAME, where_clause, ["*"])
	# 转换为 Song 对象
	var songs: Array[Song] = []
	for row in result:
		songs.append(Song.from_dict(row))
	return songs


func add_song(new_song: Song) -> bool:
	return db.insert_row(SONGS_TABLE_NAME, new_song.to_dict())

func update_song(song: Song) -> bool:
	var condition = "song_id = %d" % [song.song_id]
	return db.update_rows(SONGS_TABLE_NAME, condition, song.to_dict())

func get_song_by_id(id: int) -> Song:
	var condition = "song_id = %d" % [id]
	var result = db.select_rows(SONGS_TABLE_NAME, condition, ["*"])
	if result.size() > 0:
		return Song.from_dict(result[0])
	else:
		return null

func get_last_song_record() -> Song:
	var query = "SELECT * FROM songs ORDER BY song_id DESC LIMIT 1;"
	var result = db.query(query)
	if result:
		return Song.from_dict(db.query_result[0])
	else:
		return null

func delete_song(song_id: int) -> bool:
	var condition = "song_id = %d" % [song_id]
	return db.update_rows(SONGS_TABLE_NAME, condition, {
		"deleted": 1,
		"deleted_datetime": Time.get_datetime_string_from_system()
	})
