extends "res://scripts/game.gd"

const DAADFROGG_C_EDITION_LOG_NAME := "DaadfroGG-Community_Sandbox:Game"


func _ready() -> void:
    super()
    ModLoaderLog.debug("Community Sandbox has loaded correctly", DAADFROGG_C_EDITION_LOG_NAME)
