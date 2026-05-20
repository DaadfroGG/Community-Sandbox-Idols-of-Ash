extends "res://scripts/game.gd"

var is_in_modded_run = false
const MOD_LOG_NAME := "DaadfroGG-Community_Sandbox:Game"

var loaded_pck_names: Array[String] = []
const MOD_SAVE_PATH: String = "user://mod_save_data.cfg"

func save_mod_data() -> void:
    var cfg = ConfigFile.new()
    cfg.set_value("mod", "map", active_sandbox_map_data.scene_path if active_sandbox_map_data else "")
    cfg.set_value("mod", "balance_index", get_sandbox_difficulty_level_for_balance_setting(active_balance_settings))
    cfg.save(MOD_SAVE_PATH)
    ModLoaderLog.debug("Mod save data written", MOD_LOG_NAME)

func get_mod_saved_map() -> String:
    var cfg = ConfigFile.new()
    if cfg.load(MOD_SAVE_PATH) == OK:
        return cfg.get_value("mod", "map", "")
    return ""

func get_mod_saved_balance_index() -> int:
    var cfg = ConfigFile.new()
    if cfg.load(MOD_SAVE_PATH) == OK:
        return cfg.get_value("mod", "balance_index", 0)
    return 0

func clear_mod_save() -> void:
    if FileAccess.file_exists(MOD_SAVE_PATH):
        DirAccess.remove_absolute(MOD_SAVE_PATH)
func _ready() -> void:
    super()
    ModLoaderLog.debug("MapLoader initializing", MOD_LOG_NAME)
    _load_maps()
func register_climber(p_climber: Climber) -> void:
    super(p_climber)
    if is_in_modded_run and SaveGameData.exists():
        SaveGameData.load(climber)
        ModLoaderLog.debug("Loaded save position for modded run", MOD_LOG_NAME)
func _load_maps() -> void:
    var exe_dir = OS.get_executable_path().get_base_dir()
    var maps_dir = exe_dir.path_join("maps")
    ModLoaderLog.debug("Scanning for maps at: %s" % maps_dir, MOD_LOG_NAME)

    var dir = DirAccess.open(maps_dir)
    if not dir:
        ModLoaderLog.debug("No maps folder found next to executable", MOD_LOG_NAME)
        return

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".pck"):
            var full_path = maps_dir.path_join(file_name)
            var success = ProjectSettings.load_resource_pack(full_path)
            var map_name = file_name.replace(".pck", "")
            ModLoaderLog.debug("Loaded %s -> %s" % [map_name, "OK" if success else "FAILED"], MOD_LOG_NAME)
            if success:
                loaded_pck_names.append(map_name)
        file_name = dir.get_next()
    dir.list_dir_end()
func trigger_ending():
    if is_in_modded_run:
        trigger_modded_ending()
        return
    climber.enter_ending_state()

func trigger_modded_ending():
    audio.play_dark_transition()
    await get_tree().create_timer(2.0).timeout
    is_in_modded_run = false
    active_sandbox_map_data = null
    SceneLoader.load_scene(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))

func load_level_based_on_difficulty(from_main_menu: bool = false):
    if is_in_modded_run:
        var stored_path = active_sandbox_map_data.scene_path if active_sandbox_map_data else ""
        if stored_path == "":
            SceneLoader.load_scene(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
            return
        ModLoaderLog.debug("stored_path: %s" % [stored_path], MOD_LOG_NAME)
    
        on_new_loaded_level()
        active_run_time = 0.0
        in_foglands_scene = false
        SceneLoader.load_scene(func(): Game.perform_level_load_modded(stored_path))
        return
    on_new_loaded_level()
    active_run_time = 0.0
    in_foglands_scene = is_in_normal_campaign() or is_in_nightmare_campaign()
    if active_sandbox_map_data and active_sandbox_map_data.scene_path == "res://scenes/FogLands.tscn":
        in_foglands_scene = true
    if from_main_menu and is_in_nightmare_first_kiln():
        Game.get_tree().change_scene_to_file("res://scenes/transition_to_first_kiln.tscn")
    else:
        Game.get_tree().change_scene_to_file(active_sandbox_map_data.scene_path)

func on_new_loaded_level():
    super()
    if is_in_modded_run:
        # Wait for climber to register then load save
        await get_tree().create_timer(1.0).timeout
        if climber and SaveGameData.exists():
            SaveGameData.load(climber)
            ModLoaderLog.debug("Loaded save data for modded run", MOD_LOG_NAME)
        
func load_custom_map(scene_path: String, balance_settings: MapBalanceSettings = null) -> void:
    is_in_modded_run = true
    active_balance_settings = balance_settings if balance_settings else normal_balance_settings
    active_sandbox_map_data = SandboxDataManager.get_map_data_with_path(scene_path)
    if not active_sandbox_map_data:
        active_sandbox_map_data = SandboxMapData.new().setup(
            scene_path.get_file().replace(".tscn", ""),
            scene_path,
            SandboxData.EDifficultyLevel.Nightmare
        )
    in_sandbox_mode = false
    audio.play_dark_transition2()
    await get_tree().create_timer(2.0).timeout
    PlayerData.reset_player_death_count()
    on_new_loaded_level()
    active_run_time = 0.0
    in_foglands_scene = false
    SceneLoader.load_scene(func(): Game.perform_level_load_modded(scene_path))

func perform_level_load_modded(scene_path: String) -> void:
    ModLoaderLog.debug("performlevel load modded start", MOD_LOG_NAME)
    on_new_loaded_level()
    active_run_time = 0.0
    in_foglands_scene = false
    get_tree().change_scene_to_file(scene_path)
    # Reset SceneLoader state since we bypassed it
    SceneLoader.transitioning = false

func is_in_sandbox_mode() -> bool:
    return in_sandbox_mode

func is_difficulty_globally_available(difficulty: int) -> bool:
    if difficulty <= 1:
        return true
    return super(difficulty)

func is_in_normal_campaign() -> bool:
    if is_in_modded_run or not active_sandbox_map_data:
        return false
    return active_balance_settings == normal_balance_settings and active_sandbox_map_data.scene_path == "res://scenes/FogLands.tscn"

func is_in_nightmare_campaign() -> bool:
    if is_in_modded_run or not active_sandbox_map_data:
        return false
    return active_balance_settings == nightmare_balance_settings and active_sandbox_map_data.scene_path == "res://scenes/FogLands.tscn"

func is_in_nightmare_campaign_inverted() -> bool:
    if is_in_modded_run or not active_sandbox_map_data:
        return false
    return active_balance_settings == nightmare_balance_settings and active_sandbox_map_data.scene_path == "res://scenes/FogLands_Invert.tscn"

func is_in_nightmare_first_kiln() -> bool:
    if is_in_modded_run or not active_sandbox_map_data:
        return false
    return active_balance_settings == nightmare_balance_settings and active_sandbox_map_data.scene_path == "res://scenes/ViperPit.tscn"

func is_in_nightmare_first_kiln_inverted() -> bool:
    if is_in_modded_run or not active_sandbox_map_data:
        return false
    return active_balance_settings == nightmare_balance_settings and active_sandbox_map_data.scene_path == "res://scenes/first_kiln_invert.tscn"
