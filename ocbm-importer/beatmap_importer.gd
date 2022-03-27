extends EditorImportPlugin

func get_importer_name():
	return "com.onecat.ocbm"

func get_visible_name():
	return "One Cat Beatmap"

func get_recognized_extensions():
	return ["ocbm"]

func get_save_extension():
	return "tres"

func get_resource_type():
	return "Resource"

func get_preset_count():
	return 0

func get_preset_name(i):
	return "Default"

func get_import_options(i):
	return []

func import(source_file, save_path, options, platform_variants, gen_files):
	var file = File.new()
	if file.open(source_file, File.READ) != OK:
		return FAILED

	var data = OneCatBeatmap.new()
	var _str : String
	
	_str = file.get_line()
	if _str.find("bpm: ") != -1:
		_str.erase(0, 5)
		data.bpm = _str.to_int()
	else:
		return FAILED
		
	_str = file.get_line()
	if _str.find("notelines: ") != -1:
		_str.erase(0, 11)
		data.notelines = _str.to_int()
	else:
		return FAILED
		
	_str = file.get_line()
	if _str.find("measures: ") != -1:
		_str.erase(0, 10)
		data.measures = _str.to_int()
	else:
		return FAILED
		
	_str = file.get_line()
	if _str.find("offset: ") != -1:
		_str.erase(0, 8)
		data.offset = _str.to_int()
	else:
		return FAILED
		
	for i in range(data.notelines):
		var _noteline = []
		var _caret = 0
		_str = file.get_line()
		while _str != "":
			var _note = Note.new()
			_note.noteline = i
			_caret = _str.find(",", 0)
			_note.position = _str.substr(0, _caret).to_int()
			_str.erase(0, _caret+1)
			_caret = _str.find(";", 0)
			_note.length = _str.substr(0, _caret).to_int()
			_str.erase(0, _caret+1)
			_noteline.push_back(_note)
		data.map.push_back(_noteline)
		
	file.close()

	var filename = save_path + "." + get_save_extension()
	return ResourceSaver.save(filename, data)
