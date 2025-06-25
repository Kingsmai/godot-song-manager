extends Node
class_name UpdateChecker

var current_version = ProjectSettings.get_setting("application/config/version")

const UPDATE_NOTIFIER_WINDOW = preload("res://views/update_notifier_window.tscn")

func _ready() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	# 替换为你的仓库地址（如 godotengine/godot）
	var repo_url = "https://api.github.com/repos/Kingsmai/godot-song-manager/releases/latest"
	var error = http_request.request(repo_url, [], HTTPClient.METHOD_GET)
	if error != OK:
		push_error("HTTP 请求失败")

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
		
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	
	# 提取最新版本号（如 "v4.4.1"）
	var latest_version = data.get("tag_name", "")
	var download_url = data.get("html_url", "")  # Release 页面链接
	
	# 比较版本（示例：当前版本为 "v1.0.0"）
	if _compare_versions(latest_version, current_version) > 0:
		_show_update_notice(latest_version, download_url)

func _compare_versions(v1: String, v2: String) -> int:
	# 移除可能的 "v" 前缀并分割数字
	var v1_parts = v1.trim_prefix("v").split(".")
	var v2_parts = v2.trim_prefix("v").split(".")
	
	for i in range(max(v1_parts.size(), v2_parts.size())):
		var num1 = int(v1_parts[i]) if i < v1_parts.size() else 0
		var num2 = int(v2_parts[i]) if i < v2_parts.size() else 0
		if num1 > num2:
			return 1  # v1 更新
		elif num1 < num2:
			return -1 # v2 更新
	return 0  # 版本相同

func _show_update_notice(new_version: String, url: String):
	var dialog = UPDATE_NOTIFIER_WINDOW.instantiate()
	dialog.title = "New Version Available"
	dialog.dialog_text = "Current Version: v%s\nLatest Version: %s\nDownload Now?" % [current_version, new_version]
	dialog.confirmed.connect(func(): OS.shell_open(url))
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
