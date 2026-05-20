extends Node


const DAADFROGG_C_EDITION_DIR := "DaadfroGG-Community_Sandbox"
const DAADFROGG_C_EDITION_LOG_NAME := "DaadfroGG-Community_Sandbox:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

func _init() -> void:
    mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(DAADFROGG_C_EDITION_DIR)
    install_script_extensions()


func install_script_extensions() -> void:
    extensions_dir_path = mod_dir_path.path_join("extensions")
    print(extensions_dir_path.path_join("scripts/game.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/game.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/lore_point.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/main_menu_ui.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/pause_menu_ui.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/sandbox_data_manager.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/sandbox_menu.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/climber.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scripts/mod_save_data.gd"))
    ModLoaderMod.install_script_extension(extensions_dir_path.path_join("scenes/you_died_scene.gd"))


func _ready() -> void:
    ModLoaderLog.info("Ready!", DAADFROGG_C_EDITION_LOG_NAME)
