# 游戏管理器 - 单例
# 负责游戏状态管理、计时器、玩家注册

extends Node

signal game_started
signal game_ended(extraction_success: bool)
signal player_died(player_id: int)
signal game_timer_updated(time_left: float)

enum GameState { LOBBY, PREPARING, PLAYING, ENDED }

var current_state: GameState = GameState.LOBBY
var players: Dictionary = {}  # player_id -> PlayerController
var game_time: float = 0.0
var max_game_time: float = 900.0  # 15分钟

func _ready():
    print("[GameManager] 初始化完成")

func _process(delta):
    if current_state == GameState.PLAYING:
        game_time -= delta
        game_timer_updated.emit(game_time)
        
        if game_time <= 0:
            end_game(false)  # 时间到，失败

func start_game():
    current_state = GameState.PLAYING
    game_time = max_game_time
    game_started.emit()
    print("[GameManager] 游戏开始")

func end_game(success: bool):
    current_state = GameState.ENDED
    game_ended.emit(success)
    print("[GameManager] 游戏结束，成功:", success)

func register_player(player_id: int, player: Node):
    players[player_id] = player
    print("[GameManager] 注册玩家:", player_id)

func unregister_player(player_id: int):
    if players.has(player_id):
        players.erase(player_id)
        print("[GameManager] 移除玩家:", player_id)

func get_player_count() -> int:
    return players.size()

func is_game_running() -> bool:
    return current_state == GameState.PLAYING
