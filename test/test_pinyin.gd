extends Node

func _ready() -> void:
	print(Pinyin.get_pinyin("你好 world"))
	print(Pinyin.get_pinyin("Hello，世界！"))
	print(Pinyin.get_pinyin("123测试AbC"))
	print(Pinyin.get_pinyin("天气不错☀️today"))
	print(Pinyin.get_pinyin("爱我的人和我爱的人"))
