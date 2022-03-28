# OCS plugins and apps for Godot
This repo contains all of One Cat Studio's plugins and apps. All of them are functionality that is commonly used in game development.
To make it to this repo, a plugin/app must be easy to use and integrate into any particular project.

## OCBM Importer v. 0.9
Beatmap importer for .ocbm beatmaps made via [OCS devtools](https://github.com/damnedpie/ocs-devtools "OCS devtools"). Compatible with Godot 3.4.2.
Introduces **OneCatBeatmap** resource class and **Note** class.
#### Integration:
Add the **ocbm-importer** folder to **addons** folder in your Godot project. In Project -> Project Settings -> Plugins tab, make sure that the plugin is enabled. If Godot Engine editor becomes able to see .ocbm files, the integration was successful.

## OCS Font Manager v. 0.9
Font Manager is a singletone for Godot that simplifies font management. Instead of creating numerous .tres files, it allows to register locales and font presets (somewhat similar to Bootstrap).
By adding rules (called overrides) each locale, having a particular font, can be adjusted for all it's presets to cover font differences in general sizes and outline sizes.
#### Integration and usage:
Register it as an autoload in your project.
In _ready() func or outside of font_manager.gd:

1) Register locales with their respective fonts via registerLocale() function

2) Register text presets with group tags using registerPreset() function
For example, if you create a preset tagged as "UI_SMALL", all nodes
that are supposed to use the preset must be in the "UI_SMALL" group.

3) If necessary, create overrides for particular locales using registerOverride() function
Overrides will solve problems with font sizes and spacings. Only one override
can exist for each locale. This is useful when font for one locale looks different
from your main font (e.g. 18pt russian font is significantly smaller than 18pt english)
or the font itself has been made poorly in terms of outline size or spacing.

4) Call generateFonts() function AFTER registering all locales, presets and overrides. This
will generate fonts pool that is stored in fontResources array.

In order to update font resource of a node, call pushFont(node) function. Font Manager will
automatically select the correct font that matches current app locale from the pool as long as
the node has a group tag that matches any of the preset tags.

By using pushFontToGroup(groupName), you can bulk-update font resources for all nodes in a
group. This function basically calls pushFont() function, but for each member of the group.
Each node still has to have a group tag that matches any of the preset tags.

## OCS Fast Lib v 0.01
OCS Fast Lib's purpose is to simplify math, geometry and other commonly faced routines. It's basically a header file with functions that check conditions or calculate stuff that is often used in game development.
#### Integration and usage:

Register it as an autoload in your project and refer to it by the node name (e.g. OcsFastLib.isVectorInBounds()).


## OCS Version Controlled Saves v.0.1
OCS VCSaves is a singletone for savefile version control and resolving deltas between savefiles. It also repairs savefiles that belong to older game version and are structurally outdated, preventing crashes even when game savefile structure changes.
Integration and usage:
Register it as an autoload in your project.
In _ready() func or outside of ocs_vcsaves.gd:
1) Start with registering Entries for each data field (variable) that has to be tracked by VCS.
Specify a default value for each Entry. By default, all entries will be merged by RECENT rule,
but you can select any rule for resolving deltas. Rules behaviour works as follows:
LOWEST: between two values, the lowest will be preferred. (5 over 6, False over True, shorter string over longer)
HIGHEST: opposite of LOWEST
OLDEST: will always prefer the value from older file
RECENT: will always prefer the value from newer file
####
2) Once you are done registering values, you can now load game data. This singletone expects JSON
as input. JSON will be scanned for matches with entries you have registered previously. All information
that wasn't registered as an entry will be ignored. All entries missing in the JSON will be created from
entries' default values. If you don't have a JSON to load yet (e.g. your game starts for the first time),
you can initialize a savefile by putting empty string into loadGameData("")
####
2.1) If you are only working with local savefile, use loadGameData(json).
####
2.2) If you need to resolve deltas between a local savefile and a cloud one, use resolveAndLoad(json1, json2)
####
3) Once step 2 is done, singleton is ready to operate with savefile game data.
Use getKeyValue(key) to get values from savefile game data.
Use setKeyValue(key, value) to write new value to an existing key.
3.1) Note that you cannot create a completely new entry in the database via setKeyValue(). In order to create
a new field, you will have to registerEntry() it instead before.
4) Use formJsonSave() to get a JSON of current gamedata state. This JSON can be saved as a savefile to device or cloud.

Warning: when changing array-typed entries's defaults, make sure that your array size is not getting shorter than before, this can currently cause errors. Making arrays longer than before will work fine.

------------

### Last updated: Feb 29, 2022