extends "res://scripts/lore_point.gd"

const MOD_LOG_NAME := "DaadfroGG-Community_Sandbox:LorePoint"

func _ready():
    ambient_sfx.volume_linear = 0.0
    ModLoaderLog.debug("Game.is_in_modded_run: %s" % [Game.is_in_modded_run], MOD_LOG_NAME)
    if Game.is_in_normal_campaign() or Game.is_in_modded_run:
        for chld in get_children():
            if chld is Node3D and chld.name != "LoreTriggerMesh":
                setup_child_fade(chld)
        Game.lore_point_locations.append(global_position)
    else:
        queue_free()

func action() -> void:
    if Game.climber and (Game.is_in_normal_campaign() or Game.is_in_modded_run):
        if Time.get_ticks_msec() > SaveGameData.last_saved_time_ms + 10000:
            SaveGameData.save(Game.climber)
            Game.save_mod_data()
            ModLoaderLog.debug("Game saved with mod data", MOD_LOG_NAME)
            Game.climber.hud.on_game_saved()
    super()
