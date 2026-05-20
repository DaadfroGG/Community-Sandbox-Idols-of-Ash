extends "res://scripts/main_menu_ui.gd"

const MOD_LOG_NAME := "DaadfroGG-Community_Sandbox:MainMenuUI"

var continue_map_label: Label

func _ready() -> void:
    Game.is_in_modded_run = false
    super()
    sandbox_button.visible = true  # Always show sandbox regardless of difficulty
    _inject_continue_map_label()
    _update_continue_label()
    ModLoaderLog.debug("Main menu loaded", MOD_LOG_NAME)

func _get_save() -> Resource:
    if ResourceLoader.exists(SaveGameData.SAVE_FILE_PATH):
        return ResourceLoader.load(SaveGameData.SAVE_FILE_PATH)
    return null

func _inject_continue_map_label() -> void:
    var main_list = get_node_or_null("MainContainer/DefaultTab/MainList")
    if not main_list:
        ModLoaderLog.debug("Could not find MainList", MOD_LOG_NAME)
        return
    var label = Label.new()
    label.name = "ContinueMapLabel"
    label.theme = load("res://ui/main_theme.tres")
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    main_list.add_child(label)
    main_list.move_child(label, 1)
    continue_map_label = label
    ModLoaderLog.debug("continue_map_label injected", MOD_LOG_NAME)

func _update_continue_label() -> void:
    if not continue_map_label:
        return
    if continue_button.visible:
        var saved_map = Game.get_mod_saved_map()
        continue_map_label.text = saved_map.get_file().replace(".tscn", "").replace("_", " ").capitalize() if saved_map != "" else "Campaign"
        continue_map_label.visible = true
    else:
        continue_map_label.visible = false

func on_click_continue():
    var saved_map = Game.get_mod_saved_map()
    if saved_map != "" and saved_map != "res://scenes/FogLands.tscn":
        fade_to_tab_index = 4
        var balance = Game.get_balance_settings_for_sandbox_difficulty_level(Game.get_mod_saved_balance_index())
        Game.load_custom_map(saved_map, balance if balance else Game.normal_balance_settings)
        return
    fade_to_tab_index = 4
    on_click_start_normal_difficulty(false)
