# 主菜单脚本
# 处理创建房间、加入房间、退出游戏

extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var status_label: Label = $StatusLabel

func _ready():
	# 连接按钮信号
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 连接网络管理器信号
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.player_connected.connect(_on_player_connected)
	
	# 单机版：直接显示单机游戏按钮
	host_button.text = "单机游戏"
	join_button.text = "多人游戏(开发中)"
	join_button.disabled = true
	
	# 确保按钮可以响应触摸事件
	host_button.focus_mode = Control.FOCUS_ALL
	settings_button.focus_mode = Control.FOCUS_ALL
	quit_button.focus_mode = Control.FOCUS_ALL
	
	# 禁用鼠标捕获，让触屏点击正常工作
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	print("[MainMenu] 初始化完成")

func _on_host_pressed():
	# 单机版：直接进入游戏，无需联网
	status_label.text = "正在启动游戏..."
	print("[MainMenu] 点击了单机游戏按钮")
	
	# 直接切换场景
	_change_to_game_world()

func _change_to_game_world():
	var scene_path = "res://scenes/game_world.tscn"
	
	# 检查文件是否存在
	if not ResourceLoader.exists(scene_path):
		status_label.text = "错误: 游戏场景不存在!"
		print("[MainMenu] 场景文件不存在:", scene_path)
		return
	
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		status_label.text = "启动失败! 错误码: " + str(error)
		print("[MainMenu] 场景切换失败，错误码:", error)
	else:
		print("[MainMenu] 场景切换成功")

func _on_join_pressed():
	# 多人模式暂未开放
	status_label.text = "多人模式开发中..."

func _on_settings_pressed():
	# 显示设置信息
	status_label.text = "设置功能开发中..."
	print("[MainMenu] 点击了设置按钮")
	
	# 创建设置弹窗
	var popup = PopupPanel.new()
	popup.set_size(Vector2(400, 300))
	add_child(popup)
	popup.popup_centered()
	
	var vbox = VBoxContainer.new()
	popup.add_child(vbox)
	
	var title = Label.new()
	title.text = "游戏设置"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	var volume_label = Label.new()
	volume_label.text = "音量: 100%"
	volume_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(volume_label)
	
	var quality_label = Label.new()
	quality_label.text = "画质: 高"
	quality_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(quality_label)
	
	var close_btn = Button.new()
	close_btn.text = "关闭"
	close_btn.pressed.connect(func(): popup.hide())
	vbox.add_child(close_btn)

func _on_quit_pressed():
	get_tree().quit()

func _on_connection_failed():
	status_label.text = "连接失败！"

func _on_player_connected(id: int):
	status_label.text = "玩家 " + str(id) + " 已连接"
	if NetworkManager.get_connected_players() >= 1:
		# 至少2人，可以开始游戏
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
