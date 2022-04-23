#### OCS Version Controlled Saves v.0.2
#### One Cat Studio (C) 2022
#### OCS-VCSaves is a singletone for savefile version control and resolving deltas between savefiles.
#### It also repairs savefiles that belong to older game version and are structurally outdated.
###################################################################################################
#### Instructions and usage:
#### Register it as an autoload in your project.
#### In _ready() func or outside of ocs_vcsaves.gd:
#### 1) Start with registering Entries for each data field (variable) that has to be tracked by VCS.
#### Specify a default value for each Entry. By default, all entries will be merged by RECENT rule,
#### but you can select any rule for resolving deltas. Rules behaviour works as follows:
#### LOWEST: between two values, the lowest will be preferred. (5 over 6, False over True, shorter string over longer)
#### HIGHEST: opposite of LOWEST
#### OLDEST: will always prefer the value from older file
#### RECENT: will always prefer the value from newer file
####
#### 2) Once you are done registering values, you can now load game data. This singletone expects JSON
#### as input. JSON will be scanned for matches with entries you have registered previously. All information
#### that wasn't registered as an entry will be ignored. All entries missing in the JSON will be created from
#### entries' default values. If you don't have a JSON to load yet (e.g. your game starts for the first time),
#### you can initialize a savefile by putting empty string into loadGameData("")
####
#### 2.1) If you are only working with local savefile, use loadGameData(json).
####
#### 2.2) If you need to resolve deltas between a local savefile and a cloud one, use resolveAndLoad(json1, json2)
####
#### 3) Once step 2 is done, singleton is ready to operate with savefile game data.
#### Use getKeyValue(key) to get values from savefile game data.
#### Use setKeyValue(key, value) to write new value to an existing key.
#### 3.1) Note that you cannot create a completely new entry in the database via setKeyValue(). In order to create
#### a new field, you will have to registerEntry() it instead before.
#### 4) Use formJsonSave() to get a JSON of current gamedata state. This JSON can be saved as a savefile to device or cloud.


extends Node

enum {
	LOWEST = 0,
	HIGHEST = 1,
	OLDEST = 2,
	RECENT = 3,
}

class VCSEntry:
	var key : String
	var default
	var rule : int = RECENT
	

var database : Array = []
var dictionary : Dictionary = {}

#Returns current dictionary with current timestamp
func formJsonSave() -> String:
	dictionary["vcs_timestamp"] = OS.get_unix_time()
	return to_json(dictionary)

#Returns value if it's found in dictionary or null otherwise
func getKeyValue(key:String):
	if dictionary.has(key):
		return dictionary[key]
	else:
		print("%s: no value \"%s\" found on getKeyValue() attempt, returning null" % [name, key])
		return null

#Sets value if it's found in dictionary
func setKeyValue(key:String, value) -> void:
	if dictionary.has(key):
		dictionary[key] = value
	else:
		print("%s no value \"%s\" found on setKeyValue() attempt, did nothing" % [name, key])
	
	

#Adds an entry to database
func registerEntry(key:String, default, rule:int = RECENT) -> void:
	var newEntry : VCSEntry = VCSEntry.new()
	newEntry.key = key
	newEntry.default = default
	newEntry.rule = rule
	database.push_back(newEntry)

#This should be used when you only work with one local savefile (no cloud saves)
func loadGameData(json:String) -> void:
	dictionary = _fixMissingEntries(_jsonToDictionary(json))

#This should be used when you need to compare local save and cloud save and resolve deltas
func resolveAndLoad(jsonOne:String, jsonTwo:String) -> void:
	var mergedDict = {}
	var mode : int = 0 #0 - default, 1 - only dictOne is valid, 2 - only dictTwo is valid, 3 - no valid dicts
	
	var dictOne : Dictionary = _jsonToDictionary(jsonOne)
	var dictTwo : Dictionary = _jsonToDictionary(jsonTwo)
	
	if !dictOne.empty() && !dictTwo.empty():
		print("%s: both dictionaries are valid, resolving..." % name)
		mode = 0
		
	elif dictOne.empty() && dictTwo.empty():
		print("%s: error on deltas resolving - both dictionaries are empty, defaulting all entries" % name)
		mode = 3
	
	elif dictOne.empty():
		print("%s: error on deltas resolving - 1st dictionary is invalid, scanning 2nd for errors" % name)
		mode = 2
		
	elif dictTwo.empty():
		print("%s: error on deltas resolving - 2nd dictionary is invalid, scanning 1st for errors" % name)
		mode = 1
	
	match mode:
		0:
			var isDictOneNewer : bool = dictOne["vcs_timestamp"] > dictTwo["vcs_timestamp"]
			for entry in database:
				#IF BOTH DICTS HAVE THIS ENTRY
				if dictOne.has(entry.key) && dictTwo.has(entry.key):
					
					#IF ENTRY IS NOT THE SAME OR THE ENTRY IS AN ARRAY
					#ARRAYS HAVE TO BE FORCE-RESOLVED TO MAKE SURE THEY ARE SAME SIZE AS EXPECTED DEFAULT
					if dictOne[entry.key] != dictTwo[entry.key] || typeof(entry.default) == TYPE_ARRAY:
						#IF IT IS AN ARRAY
						if typeof(entry.default) == TYPE_ARRAY:
							var mergedArray : Array = entry.default.duplicate(true)
							
							var arrayCompareMode : int = 0 #0:equal, 1:dictOne entry is longer, 2:dictTwo entry is longer
							if dictOne[entry.key].size() != dictTwo[entry.key].size():
								if dictOne[entry.key].size() > dictTwo[entry.key].size():
									arrayCompareMode = 1
								else:
									arrayCompareMode = 2
									
							match entry.rule:
								LOWEST:
									match arrayCompareMode:
										0:
											for _i in range(dictOne[entry.key].size()):
												if dictOne[entry.key][_i] < dictTwo[entry.key][_i]:
													mergedArray[_i] = dictOne[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
										1:
											for _i in range(dictOne[entry.key].size()):
												if _i < dictTwo[entry.key].size()-1:
													if dictOne[entry.key][_i] < dictTwo[entry.key][_i]:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictOne[entry.key][_i]
										2:
											for _i in range(dictTwo[entry.key].size()):
												if _i < dictOne[entry.key].size()-1:
													if dictOne[entry.key][_i] < dictTwo[entry.key][_i]:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
								HIGHEST:
									match arrayCompareMode:
										0:
											for _i in range(dictOne[entry.key].size()):
												if dictOne[entry.key][_i] > dictTwo[entry.key][_i]:
													mergedArray[_i] = dictOne[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
										1:
											for _i in range(dictOne[entry.key].size()):
												if _i < dictTwo[entry.key].size()-1:
													if dictOne[entry.key][_i] > dictTwo[entry.key][_i]:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictOne[entry.key][_i]
										2:
											for _i in range(dictTwo[entry.key].size()):
												if _i < dictOne[entry.key].size()-1:
													if dictOne[entry.key][_i] > dictTwo[entry.key][_i]:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
								OLDEST:
									match arrayCompareMode:
										0:
											if isDictOneNewer:
												for _i in range(dictTwo[entry.key].size()):
													mergedArray[_i] = dictTwo[entry.key][_i]
											else:
												for _i in range(dictOne[entry.key].size()):
													mergedArray[_i] = dictOne[entry.key][_i]
										1:
											for _i in range(dictOne[entry.key].size()):
												if isDictOneNewer:
													if _i < dictTwo[entry.key].size()-1:
														mergedArray[_i] = dictTwo[entry.key][_i]
													else:
														mergedArray[_i] = dictOne[entry.key][_i]
												else:
													mergedArray[_i] = dictOne[entry.key][_i]
										2:
											for _i in range(dictTwo[entry.key].size()):
												if !isDictOneNewer:
													if _i < dictOne[entry.key].size()-1:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
								RECENT:
									match arrayCompareMode:
										0:
											if isDictOneNewer:
												for _i in range(dictOne[entry.key].size()):
													mergedArray[_i] = dictOne[entry.key][_i]
											else:
												for _i in range(dictTwo[entry.key].size()):
													mergedArray[_i] = dictTwo[entry.key][_i]
										1:
											for _i in range(dictOne[entry.key].size()):
												if !isDictOneNewer:
													if _i < dictTwo[entry.key].size()-1:
														mergedArray[_i] = dictTwo[entry.key][_i]
													else:
														mergedArray[_i] = dictOne[entry.key][_i]
												else:
													mergedArray[_i] = dictOne[entry.key][_i]
										2:
											for _i in range(dictTwo[entry.key].size()):
												if isDictOneNewer:
													if _i < dictOne[entry.key].size()-1:
														mergedArray[_i] = dictOne[entry.key][_i]
													else:
														mergedArray[_i] = dictTwo[entry.key][_i]
												else:
													mergedArray[_i] = dictTwo[entry.key][_i]
							mergedDict[entry.key] = mergedArray
						#IF IT IS A STRING
						elif typeof(entry.default) == TYPE_STRING:
							match entry.rule:
								LOWEST:
									if dictOne[entry.key].size() < dictTwo[entry.key].size():
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
								HIGHEST:
									if dictOne[entry.key].size() > dictTwo[entry.key].size():
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
								OLDEST:
									if !isDictOneNewer:
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
								RECENT:
									if isDictOneNewer:
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
						#IF IT IS ANY OTHER TYPE:
						else:
							match entry.rule:
								LOWEST:
									if dictOne[entry.key] < dictTwo[entry.key]:
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
								HIGHEST:
									if dictOne[entry.key] > dictTwo[entry.key]:
										mergedDict[entry.key] = dictOne[entry.key]
									else:
										mergedDict[entry.key] = dictTwo[entry.key]
								OLDEST:
									if isDictOneNewer:
										mergedDict[entry.key] = dictTwo[entry.key]
									else:
										mergedDict[entry.key] = dictOne[entry.key]
								RECENT:
									if !isDictOneNewer:
										mergedDict[entry.key] = dictTwo[entry.key]
									else:
										mergedDict[entry.key] = dictOne[entry.key]
						print("%s: resolved delta for key \"%s\"" % [name, entry.key])
					
					#IF ENTRY IS THE SAME AND ITS NOT AN ARRAY
					else:
						mergedDict[entry.key] = dictOne[entry.key]
				
				
				
				#IF ONLY DICTONE HAS THIS ENTRY
				elif dictOne.has(entry.key):
					mergedDict[entry.key] = dictOne[entry.key]
				#IF ONLY DICTTWO HAS THIS ENTRY
				elif dictTwo.has(entry.key):
					mergedDict[entry.key] = dictTwo[entry.key]
				#IF NO DICTS HAVE THIS ENTRY (JUST IN CASE)
				else:
					print("%s: no dictionaries had key \"%s\", defaulting to \"%s\"" % [name, entry.key, entry.default])
					mergedDict[entry.key] = entry.default
			
		1:
			for entry in database:
				#if dict has entry:
				if dictOne.has(entry.key):
					if typeof(entry.default) == TYPE_ARRAY:
						var fixedArray : Array = entry.default.duplicate(true)
						for _i in range(dictOne[entry.key].size()):
							fixedArray[_i] = dictOne[entry.key][_i]
						mergedDict[entry.key] = fixedArray
					else:
						mergedDict[entry.key] = dictOne[entry.key]
				#otherwise fill with default value
				else:
					mergedDict[entry.key] = entry.default
		2:
			for entry in database:
				#if dict has entry:
				if dictTwo.has(entry.key):
					if typeof(entry.default) == TYPE_ARRAY:
						var fixedArray : Array = entry.default.duplicate(true)
						for _i in range(dictTwo[entry.key].size()):
							fixedArray[_i] = dictTwo[entry.key][_i]
						mergedDict[entry.key] = fixedArray
					else:
						mergedDict[entry.key] = dictTwo[entry.key]
				#otherwise fill with default value
				else:
					mergedDict[entry.key] = entry.default
		3:
			mergedDict["vcs_timestamp"] = OS.get_unix_time()
			for entry in database:
				mergedDict[entry.key] = entry.default
	dictionary = mergedDict

func _fixMissingEntries(dict:Dictionary) -> Dictionary:
	var fixedDict = {}
	for entry in database:
		#if it's an array, fix array length
		if typeof(entry.default) == TYPE_ARRAY:
			if dict.has(entry.key):
				if dict[entry.key].size() != entry.default.size():
					var fixedArr = entry.default.duplicate(true)
					for _i in range(dict[entry.key].size()):
						fixedArr[_i] = dict[entry.key][_i]
					fixedDict[entry.key] = fixedArr
				else:
					fixedDict[entry.key] = dict[entry.key]
			else:
				print("%s: dict has no %s, defaulting" % [name, entry.key])
				fixedDict[entry.key] = entry.default.duplicate(true)
				
		#otherwise if no key found fill it with default
		elif !dict.has(entry.key):
			fixedDict[entry.key] = entry.default
			
		#otherwise if dict has the key, keep it
		else:
			fixedDict[entry.key] = dict[entry.key]
	
	return fixedDict

func _jsonToDictionary(json:String) -> Dictionary:
	#fix for Godot JSON parsing errors (for initializing via "")
	if json == "":
		json = "{}"
	var resultDict : Dictionary = {}
	var parsedData = parse_json(json)
	
	#check if parsedData is null
	if !parsedData:
		print("%s: warning - attempt to form dictionary from Null" % name)
		return {}
	
	#check if database is empty
	if database.size() == 0:
		print("%s: warning - attempt to form dictionary without registered entries." % name)
		print("%s: Load savefiles only AFTER registering entries!" % name)
		return {}
	
	#fetch timestamp of the savefile
	if parsedData.has("vcs_timestamp"):
		resultDict["vcs_timestamp"] = parsedData["vcs_timestamp"]
	else:
		print("%s: no timestamp found in the data, savefile is corrupt." % name)
		return {}
	
	for entry in database:
		if parsedData.has(entry.key):
			resultDict[entry.key] = parsedData[entry.key]
	return resultDict
