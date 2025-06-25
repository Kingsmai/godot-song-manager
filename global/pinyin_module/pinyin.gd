extends Node

var pinyin_dict: Dictionary = {}

func remove_multiple_characters(input_string: String, chars_to_remove: String) -> String:
	for char in chars_to_remove:
		input_string = input_string.replace(char, "")
	return input_string

func remove_tone(pinyin: String) -> String:
	var result := ""
	for c in pinyin:
		if c not in "12345":
			result += c
	return result

func load_pinyin_file(file_path: String) -> void:
	if pinyin_dict: return  # 已加载，无需重复加载

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开拼音文件: %s" % file_path)
		return

	var pinyin_array: Array = JSON.parse_string(file.get_as_text())
	file.close()

	for item in pinyin_array:
		var simp : String = item.get("simplified", "")
		var trad : String = item.get("traditional", "")
		var raw_pinyin : String = item.get("pinyin", "")
		var parts := raw_pinyin.split(" ")
		var cleaned_parts := []

		for part in parts:
			cleaned_parts.append(remove_tone(part.strip_edges().to_lower()))

		var cleaned_pinyin := " ".join(cleaned_parts)

		# simplified + traditional 同步处理
		for word in [simp, trad]:
			if not word: continue
			if not pinyin_dict.has(word):
				pinyin_dict[word] = []
			if cleaned_pinyin not in pinyin_dict[word]:
				pinyin_dict[word].append(cleaned_pinyin)

# 计算笛卡尔积组合（例如 [["ju", "che"], ["zai"], ["man"]] → ["juzaiman", "chezaiman"]）
func cartesian_product(arrays: Array) -> Array:
	if arrays.size() == 0:
		return []

	var result := [""]
	for group in arrays:
		var temp := []
		for prefix in result:
			for element in group:
				temp.append(prefix + element)
		result = temp
	return result

func get_pinyin(text: String) -> Array:
	var pinyin_parts: Array = []

	for c in text:
		var code := c.unicode_at(0)
		if code >= 0x4E00 and code <= 0x9FFF:
			if pinyin_dict.has(c):
				# 拆为子项：多音词拆成单个音节
				var all_forms: Array = []
				for full in pinyin_dict[c]:
					var split_parts : Array = full.split(" ")
					all_forms.append(split_parts)
				# 展平多音字的所有拼音（如 [["ju"], ["che"]] → ["ju", "che"]）
				var merged := []
				for item in all_forms:
					var joined := "".join(item)
					if joined not in merged:
						merged.append(joined)
				pinyin_parts.append(merged)
			else:
				pinyin_parts.append([""])  # 无拼音时仍保留空项
		elif (code >= 65 and code <= 90) or (code >= 97 and code <= 122):
			pinyin_parts.append([c])
		# 忽略其他符号

	return cartesian_product(pinyin_parts)

func _ready() -> void:
	load_pinyin_file("res://global/pinyin_module/cedict.json")
