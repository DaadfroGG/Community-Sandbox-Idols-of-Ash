extends "res://scripts/pause_menu_ui.gd"

func restart_level():
    if Game.is_in_modded_run:
        queue_free()
        SaveGameData.clear()
        PlayerData.reset_player_death_count()
        Game.load_level_based_on_difficulty()
    else:
        SceneLoader.load_scene(perform_restart_level)

func restart_level_at_checkpoint():
    if Game.is_in_modded_run:
        queue_free()
        Game.load_level_based_on_difficulty()
    else:
        SceneLoader.load_scene(Game.load_level_based_on_difficulty)

func perform_restart_level():
    if not Game.is_in_modded_run:
        SaveGameData.clear()
    PlayerData.reset_player_death_count()
    Game.load_level_based_on_difficulty()
