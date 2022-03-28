#### OCS Font Manager v.0.9
#### One Cat Studio (C) 2022
#### Font Manager is a singletone for Godot that simplifies font management.
###################################################################################################
#### Instructions and usage:
#### Register it as an autoload in your project
#### In _ready() func or outside of ocs_font_manager.gd:
#### 1) Register locales with their respective fonts via registerLocale() function
#### 2) Register text presets with group tags using registerPreset() function
####	For example, if you create a preset tagged as "UI_SMALL", all nodes
####	that are supposed to use the preset must be in the "UI_SMALL" group
#### 3) If necessary, create overrides for particular locales using registerOverride() function
####	Overrides will solve problems with font sizes and spacings. Only one override
####	can exist for each locale. This is useful when font for one locale looks different
####	from your main font (e.g. 18pt russian font is significantly smaller than 18pt english)
####	or the font itself has been made poorly in terms of outline size or spacing.
#### 4) Call generateFonts() function AFTER registering all locales, presets and overrides. This
#### will generate fonts pool that is stored in fontResources array
###################################################################################################
#### In order to update font resource of a node, call pushFont(node) function. Font Manager will
#### automatically select the correct font that matches current app locale from the pool as long as
#### the node has a group tag that matches any of the preset tags.
###################################################################################################
#### By using pushFontToGroup(groupName), you can bulk-update font resources for all nodes in a
#### group. This function basically calls pushFont() function, but for each member of the group.
#### Each node still has to have a group tag that matches any of the preset tags.

extends Node

var locales : Array = []
var fontPresets : Array = []
var overrides : Array = []
var fontResources : Array = []

class FMLocale:
	var code : String #en_US, ru_RU, etc
	var font : DynamicFontData
	
class FMPreset:
	var tag : String #e.g. "UI_LG", "MENU_MD"
	var size : int
	var outline_size : int
	var outline_color
	var spacing : Array = [0,0,0,0] #top, bottom, char, space
	
class FMOverride:
	var code : String #en_US, ru_RU, etc
	var size : int
	var outline_size : int
	var outline_color
	var spacing : Array = [0,0,0,0] #top, bottom, char, space


func _ready():
	TranslationServer.set_locale("en_US")
	registerLocale("en_US", load("res://fonts/PixelColeco.ttf"))
	registerPreset("UI_SM", 36, 2, Color(0,0,0,1))
	registerPreset("UI_MD", 48, 2, Color(0,0,0,1))
	registerPreset("UI_LG", 72, 2, Color(0,0,0,1))
	registerPreset("UI_XL", 96, 2, Color(0,0,0,1))
	registerOverride("ru_RU", -4)
	generateFonts()


func registerLocale(localeCode:String, localeFont:DynamicFontData) -> void:
	for locale in locales:
		if locale.code == localeCode:
			print(name, ": failed adding locale ", localeCode, " - locale already exists")
			return
			
	var newLocale : FMLocale = FMLocale.new()
	newLocale.code = localeCode
	newLocale.font = localeFont
	locales.push_back(newLocale)


func registerPreset(tag:String, size:int, olSize:int, olColor:Color, spacing:Array = [0,0,0,0]) -> void:
	for preset in fontPresets:
		if preset.tag == tag:
			print(name, ": failed adding preset ", tag, " - preset already exists")
			return
			
	var newPreset : FMPreset = FMPreset.new()
	newPreset.tag = tag
	newPreset.size = size
	newPreset.outline_size = olSize
	newPreset.outline_color = olColor
	match spacing.size():
		1:
			newPreset.spacing = [spacing[0], 0, 0, 0]
		2:
			newPreset.spacing = [spacing[0], spacing[1], 0, 0]
		3:
			newPreset.spacing = [spacing[0], spacing[1], spacing[2], 0]
		4:
			newPreset.spacing = spacing
		_:
			newPreset.spacing = [0,0,0,0]
			print(name, ": incorrect spacing args on registering preset ", tag, ", defaulting to [0,0,0,0]")
	fontPresets.push_back(newPreset)


func registerOverride(code:String, deltaSize:int=0, deltaOlSize:int=0, newOlColor=null, deltaSpacing:Array=[0,0,0,0]) -> void:
	for override in overrides:
		if override.code == code:
			print(name, ": failed adding override for ", code, " - override already exists")
			return
			
	var newOverride : FMOverride = FMOverride.new()
	newOverride.code = code
	newOverride.size = deltaSize
	newOverride.outline_size = deltaOlSize
	newOverride.outline_color = newOlColor
	match deltaSpacing.size():
		1:
			newOverride.spacing = [deltaSpacing[0], 0, 0, 0]
		2:
			newOverride.spacing = [deltaSpacing[0], deltaSpacing[1], 0, 0]
		3:
			newOverride.spacing = [deltaSpacing[0], deltaSpacing[1], deltaSpacing[2], 0]
		4:
			newOverride.spacing = deltaSpacing
		_:
			newOverride.spacing = [0,0,0,0]
			print(name, ": incorrect spacing args on registering override for ", code, ", defaulting to [0,0,0,0]")
	overrides.push_back(newOverride)


func generateFonts() -> void:
	for fontRes in fontResources:
		fontRes.queue_free()
	fontResources = []
	for _locale in locales:
		var localeOverride = null
		for _override in overrides:
			if _override.code == _locale.code:
				localeOverride = _override
		for _preset in fontPresets:
			var newFont : DynamicFont = DynamicFont.new()
			newFont.resource_name = str(_locale.code + ":" + _preset.tag)
			newFont.font_data = _locale.font
			newFont.size = _preset.size
			if localeOverride:
				newFont.size = newFont.size + localeOverride.size
			newFont.outline_size = _preset.outline_size
			if localeOverride:
				newFont.outline_size = newFont.outline_size + localeOverride.outline_size
			newFont.outline_color = _preset.outline_color
			if localeOverride:
				if localeOverride.outline_color:
					newFont.outline_color = localeOverride.outline_color
			newFont.extra_spacing_top = _preset.spacing[0]
			if localeOverride:
				newFont.extra_spacing_top = newFont.extra_spacing_top + localeOverride.spacing[0]
			newFont.extra_spacing_bottom = _preset.spacing[1]
			if localeOverride:
				newFont.extra_spacing_bottom = newFont.extra_spacing_bottom + localeOverride.spacing[1]
			newFont.extra_spacing_char = _preset.spacing[2]
			if localeOverride:
				newFont.extra_spacing_char = newFont.extra_spacing_char + localeOverride.spacing[2]
			newFont.extra_spacing_space = _preset.spacing[3]
			if localeOverride:
				newFont.extra_spacing_space = newFont.extra_spacing_space + localeOverride.spacing[3]
			print(name, ": generated font resource ", newFont.resource_name)
			fontResources.push_back(newFont)

func pushFont(controlNode:Control) -> void:
	var nodeGroups = controlNode.get_groups()
	var presetTag = null
	for group in nodeGroups:
		for _preset in fontPresets:
			if group == _preset.tag:
				if presetTag:
					print(name, ": warning - ", controlNode, " has few groups that match preset tags")
				presetTag = group
	if !presetTag:
		print(name, ": error pushing font to ", controlNode, " - no preset tags found in node groups")
	else:
		var fontResource = null
		for font in fontResources:
			if TranslationServer.get_locale() in font.resource_name && presetTag in font.resource_name:
				fontResource = font
		if !fontResource:
			print(name, ": error - font resource ", TranslationServer.get_locale(),":",presetTag," not found in fonts pool")
			return
		
		match controlNode.get_class():
			"Label":
				controlNode.set("custom_fonts/font", fontResource)
			"RichTextLabel":
				controlNode.set("custom_fonts/normal_font", fontResource)
			"Button":
				controlNode.set("custom_fonts/font", fontResource)
			_:
				print(name, ": error pushing font to ", controlNode, " - can't push font to class ", controlNode.get_class())


func pushFontToGroup(groupName:String) -> void:
	for node in get_tree().get_nodes_in_group(groupName):
		pushFont(node)
