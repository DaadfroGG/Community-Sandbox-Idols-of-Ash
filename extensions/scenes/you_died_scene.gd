extends "res://scenes/you_died_scene.gd"

const MOD_LOG_NAME := "DaadfroGG-Community_Sandbox:YouDiedScreen"

var is_loading: bool = false

func _process(delta: float) -> void:
    time_in_scene += delta
    if time_in_scene > 3.0 and not is_loading:
        is_loading = true
        ModLoaderLog.debug("is_in_modded_run: %s" % Game.is_in_modded_run, MOD_LOG_NAME)
        ModLoaderLog.debug("active_sandbox_map_data: %s" % (Game.active_sandbox_map_data.scene_path if Game.active_sandbox_map_data else "null"), MOD_LOG_NAME)
        if Game.is_in_modded_run:
            Game.load_level_based_on_difficulty()
        else:
            SceneLoader.load_scene(go_to_foglands)
