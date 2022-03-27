# OCS plugins and apps for Godot
This repo contains all of One Cat Studio's plugins and apps. All of them are functionality that is commonly used in game development.
To make it to this repo, a plugin/app must be easy to use and integrate into any particular project.

## OCBM Importer v. 0.9
Beatmap importer for .ocbm beatmaps made via [OCS devtools](https://github.com/damnedpie/ocs-devtools "OCS devtools"). Compatible with Godot 3.4.2.
Introduces **OneCatBeatmap** resource class and **Note** class.
#### Integration:
Add the **ocbm-importer** folder to **addons** folder in your Godot project. In Project -> Project Settings -> Plugins tab, make sure that the plugin is enabled. If Godot Engine editor becomes able to see .ocbm files, the integration was successful.

## Font Manager v. 0.9
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

------------

### Last updated: Feb 28, 2022