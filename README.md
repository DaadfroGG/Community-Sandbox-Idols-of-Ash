# Community Sandbox — *Idols of Ash* Mod
**Mod Loader:** GodotModLoader 7.0.1  
**Game Version:** *Idols of Ash* 1.3.2

---

## Overview

Community Sandbox is a mod framework for *Idols of Ash* that enables custom community-made maps to run inside the game's existing sandbox system.

It handles map loading, save checkpoints, difficulty handling, and respawn logic so map creators can focus entirely on building levels rather than infrastructure.

Maps are loaded as external `.pck` files and integrated directly into the sandbox menu.

---

## Features

- **Custom map loading**
  - Loads `.pck` files from a `maps/` folder next to the game executable

- **Sandbox integration**
  - Custom maps appear alongside official sandbox maps in the menu

- **Checkpoint-based saving**
  - Uses the game's existing checkpoint system for saving and restoring progress in custom maps

---

## Installation

### 1. Install GodotModLoader

*Idols of Ash* does not officially support mods.  
To enable mod loading, the game must be manually patched with GodotModLoader.

This involves modifying the game’s `.pck`:

1. Extract or decompile the game’s `.pck`
2. Inject GodotModLoader into the project structure
3. Rebuild the `.pck`
4. Launch the patched version of the game

> **Note:** This process is not officially documented and requires familiarity with Godot project structure and `.pck` rebuilding.

GodotModLoader:
https://github.com/GodotModLoader/GodotModLoader

---

### 2. Install Community Sandbox

1. Download the latest release of Community Sandbox
2. Place the `.zip` file into the `mods/` folder next to the game executable

```text
IdolsOfAsh/
├── IdolsOfAsh.exe
├── mods/
│   └── DaadfroGG-Community_Sandbox.zip
```

3. Launch the game — the mod will load automatically

---

## For Map Makers

⚠️ **Current workflow (temporary)**

At the moment, creating maps requires working directly from a decompiled version of the game. This is necessary because there is no standalone editor yet.

### Creating a map

1. Decompile *Idols of Ash* to access the project files
2. Create or edit your map scene
3. Register the scene under:

```text
res://scenes/modded_maps/
```

4. Export your map as a `.pck`
5. Place the `.pck` into the `maps/` folder next to the game executable

---

### Thumbnail Support

To add a preview image for your map, place a `.png` file with the same name as your scene here:

```text
res://textures/map_textures/modded_maps/your_map.png
```

This image will be used as the map thumbnail in the sandbox menu.

---

### Planned Workflow

A prototype editor version of the game is planned to simplify map creation.

Goals include:

- Creating maps without decompiling the full game
- A dedicated editor for building sandbox levels
- Direct `.pck` export from the editor
- Faster iteration for map creators

This will replace the current manual workflow in the future.

---

## Compatibility

- **GodotModLoader:** 7.0.1  
- ***Idols of Ash*:** 1.3.2  

---

## Credits

Built by **DaadfroGG** using GodotModLoader.

Special thanks to the *Idols of Ash* community for inspiration and feedback.
