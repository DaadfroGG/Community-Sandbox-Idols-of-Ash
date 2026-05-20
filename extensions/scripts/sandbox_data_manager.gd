extends "res://scripts/sandbox_data_manager.gd"

const MODDED_MAPS_PATH: String = "res://scenes/modded_maps/"

func _ready() -> void:
    if ResourceLoader.exists(SANDBOX_DATA_PATH):
        loaded_data = ResourceLoader.load(SANDBOX_DATA_PATH)
        post_load()
    else:
        loaded_data = SandboxData.new().setup()
    
    cleanup_missing_modded_maps()
    register_modded_maps()
    
    var player_unlocked_difficulty = PlayerData.config.get_value("unlocked", "difficulty", 0)
    for unlocked_idx in player_unlocked_difficulty + 1:
        unlock_sandbox_map_of_idx(unlocked_idx)

func cleanup_missing_modded_maps():
    var to_remove = []
    for map_data in loaded_data.unlocked_map_data:
        if map_data.scene_path.contains("modded_maps"):
            if not ResourceLoader.exists(map_data.scene_path):
                to_remove.append(map_data)
                print("removing missing modded map: %s" % map_data.scene_path)
    for map_data in to_remove:
        loaded_data.unlocked_map_data.erase(map_data)
    if to_remove.size() > 0:
        save()

func register_modded_maps():
    var dir = DirAccess.open(MODDED_MAPS_PATH)
    if not dir:
        return
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if not dir.current_is_dir():
            var scene_path = ""
            if file_name.ends_with(".tscn"):
                scene_path = MODDED_MAPS_PATH + file_name
            elif file_name.ends_with(".tscn.remap"):
                scene_path = MODDED_MAPS_PATH + file_name.replace(".remap", "")
            
            if scene_path != "" and not loaded_data.has_unlocked_map_with_path(scene_path):
                var display_name = scene_path.get_file().replace(".tscn", "").replace("_", " ").capitalize()
                loaded_data.unlocked_map_data.append(
                    SandboxMapData.new().setup(display_name, scene_path, SandboxData.EDifficultyLevel.Normal)
                )
                save()
                print("registered: %s" % scene_path)
        file_name = dir.get_next()
    dir.list_dir_end()

func _process(delta: float) -> void:
    var player_unlocked_difficulty = PlayerData.config.get_value("unlocked", "difficulty", 0)
    for unlocked_idx in player_unlocked_difficulty + 1:
        unlock_sandbox_map_of_idx(unlocked_idx)
    if OS.has_feature("editor"):
        safe_unlock_map_of_type("CHASM", "res://scenes/Chasm.tscn", SandboxData.EDifficultyLevel.Unleashed)

func unlock_sandbox_map_of_idx(idx: int):
    match (idx):
        3:
            safe_unlock_map_of_type("CAMPAIGN (INVERTED)", "res://scenes/FogLands_Invert.tscn", SandboxData.EDifficultyLevel.Nightmare)
            safe_unlock_map_of_type("FIRST KILN", "res://scenes/ViperPit.tscn", SandboxData.EDifficultyLevel.Nightmare)
        4:
            safe_unlock_map_of_type("FIRST KILN (INVERTED)", "res://scenes/first_kiln_invert.tscn", SandboxData.EDifficultyLevel.Nightmare)

func safe_unlock_map_of_type(map_name: String, map_path: String, difficulty_level: SandboxData.EDifficultyLevel):
    if not loaded_data.has_unlocked_map_with_path(map_path):
        loaded_data.unlocked_map_data.append(SandboxMapData.new().setup(map_name, map_path, difficulty_level))
        save()

func get_map_data_with_path(path: String) -> SandboxMapData:
    if loaded_data:
        for map_data in loaded_data.unlocked_map_data:
            if map_data.scene_path == path:
                return map_data
    return null
