#### OCBM Importer v.0.9
#### One Cat Studio (C) 2022
#### OCS devtools beatmap files (.ocbm) importer for One Cat Studio projects.

tool
extends EditorPlugin


var import_plugin

func _enter_tree():
	import_plugin = preload("beatmap_importer.gd").new()
	add_import_plugin(import_plugin)

func _exit_tree():
	remove_import_plugin(import_plugin)
	import_plugin = null
