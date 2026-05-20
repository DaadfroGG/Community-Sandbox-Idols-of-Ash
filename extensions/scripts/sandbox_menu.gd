extends "res://scripts/sandbox_menu.gd"

const MOD_LOG_NAME := "DaadfroGG-Community_Sandbox:SandboxMenu"

const MAPS_PER_PAGE: int = 4
var current_page: int = 0
var all_maps: Array = []
var map_nav_container: Container  # add this
func _ready() -> void:
    super()
    map_nav_container = get_node_or_null("TabContainer/SelectMap/VBoxContainer/Nav")
    if not map_nav_container:
        ModLoaderLog.debug("Could not find Nav container", MOD_LOG_NAME)
    map_list_container = get_node_or_null("TabContainer/SelectMap/VBoxContainer/MapList")
    if not map_list_container:
        ModLoaderLog.debug("Could not find MapList container", MOD_LOG_NAME)
    setup_map_list()

func is_modded_map(scene_path: String) -> bool:
    return scene_path.contains("modded_maps")

func setup_map_list():
    var sandbox_data = SandboxDataManager.get_data()
    var player_unlocked = PlayerData.config.get_value("unlocked", "difficulty", 0)

    all_maps = []
    var official_maps = []
    var modded_maps = []

    for map in sandbox_data.unlocked_map_data:
        if is_modded_map(map.scene_path):
            modded_maps.append(map)
        elif player_unlocked >= 1:
            official_maps.append(map)

    all_maps = official_maps + modded_maps
    current_page = 0
    refresh_map_list()

func refresh_map_list():
    for chld in map_list_container.get_children():
        chld.queue_free()

    # Hide vanilla nav children instead of freeing them
    for chld in map_nav_container.get_children():
        if chld.name == "Back" or chld.name == "Label":
            chld.visible = false
        elif chld.get_meta("mod_pagination", false):
            chld.queue_free()

    var start = current_page * MAPS_PER_PAGE
    var end = mini(start + MAPS_PER_PAGE, all_maps.size())

    for i in range(start, end):
        create_map_display(all_maps[i])

    var prev_btn = Button.new()
    prev_btn.set_meta("mod_pagination", true)
    prev_btn.text = "< PREV"
    prev_btn.theme = load("res://ui/main_theme.tres")
    prev_btn.disabled = current_page == 0
    prev_btn.modulate.a = 0.0 if current_page == 0 else 1.0
    prev_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    prev_btn.custom_minimum_size = Vector2(100, 40)
    prev_btn.pressed.connect(func():
        current_page -= 1
        refresh_map_list()
    )

    var page_label = Label.new()
    page_label.set_meta("mod_pagination", true)
    page_label.text = "%d / %d" % [current_page + 1, ceili(float(all_maps.size()) / MAPS_PER_PAGE)]
    page_label.theme = load("res://ui/main_theme.tres")
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page_label.custom_minimum_size = Vector2(0, 40)

    var next_btn = Button.new()
    next_btn.set_meta("mod_pagination", true)
    next_btn.text = "NEXT >"
    next_btn.theme = load("res://ui/main_theme.tres")
    next_btn.disabled = end >= all_maps.size()
    next_btn.modulate.a = 0.0 if end >= all_maps.size() else 1.0
    next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    next_btn.custom_minimum_size = Vector2(100, 40)
    next_btn.pressed.connect(func():
        current_page += 1
        refresh_map_list()
    )

    # Insert pagination before the Back button
    var back_btn = map_nav_container.get_node_or_null("Back")
    map_nav_container.add_child(prev_btn)
    map_nav_container.add_child(page_label)
    map_nav_container.add_child(next_btn)
    if back_btn:
        back_btn.visible = true
        map_nav_container.move_child(back_btn, map_nav_container.get_child_count() - 1)

    var first_child = map_list_container.get_child(0)
    if first_child:
        Game.node_to_select_for_controller_mode = first_child
func create_map_display(map_data: SandboxMapData):
    var btn = load("res://scenes/sandbox_map_option.tscn").instantiate()
    btn.setup(map_data, self)
    btn.pressed.connect(func(): on_clicked_btn_for_map_data(map_data))
    map_list_container.add_child(btn)

func on_clicked_btn_for_map_data(map_data: SandboxMapData):
    selected_map_data = map_data
    move_to_settings()

func get_texture_for_map_data(map_data: SandboxMapData) -> Texture2D:
    var path_sections: PackedStringArray = map_data.scene_path.split("/")
    if path_sections.size() >= 2:
        var scene_file: String = path_sections[path_sections.size() - 1]
        var scene_file_sections: PackedStringArray = scene_file.split(".")
        if scene_file_sections.size() > 0:
            var resource_path: String
            if is_modded_map(map_data.scene_path):
                resource_path = "res://textures/map_textures/modded_maps/%s.png" % scene_file_sections[0]
            else:
                resource_path = "res://textures/map_textures/%s.png" % scene_file_sections[0]
            if ResourceLoader.exists(resource_path):
                return load(resource_path)
    return null

func perform_level_load():
    close_menu()
    if is_modded_map(selected_map_data.scene_path):
        ModLoaderLog.debug("Loading modded map: %s" % selected_map_data.scene_path, MOD_LOG_NAME)
        SaveGameData.clear()
        Game.clear_mod_save()
        Game.is_in_modded_run = true
        Game.active_balance_settings = selected_balance_settings
        Game.active_sandbox_map_data = SandboxDataManager.get_map_data_with_path(selected_map_data.scene_path)
        if not Game.active_sandbox_map_data:
            Game.active_sandbox_map_data = SandboxMapData.new().setup(
                selected_map_data.scene_path.get_file().replace(".tscn", ""),
                selected_map_data.scene_path,
                SandboxData.EDifficultyLevel.Normal
            )
        PlayerData.reset_player_death_count()
        Game.perform_level_load_modded(selected_map_data.scene_path)
    else:
        Game.is_in_modded_run = false
        Game.active_balance_settings = selected_balance_settings
        Game.active_sandbox_map_data = selected_map_data
        Game.load_level_based_on_difficulty(false)
