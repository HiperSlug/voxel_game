@tool
extends RefCounted
class_name PathVerifier

var include_regexes: Array[RegEx]
var exclude_regexes: Array[RegEx]
var base_folder: String

func _init(_base_folder: String, include_patterns: Array[String], exclude_patterns: Array[String]):
	# compile the include and exclude patterns to regular expressions, so we don't
	# have to do it for each file
	include_regexes = []
	exclude_regexes = []
	

	for pattern in include_patterns:
		
		if pattern == "" or pattern == null:
			continue
			
		if not pattern.begins_with("**/"): # changed from contains() to begins_with()
			pattern = "**/" + pattern
		
		include_regexes.append(compile_pattern(pattern))

	for pattern in exclude_patterns:
		
		if pattern == "" or pattern == null:
			continue
			
		if not pattern.begins_with("**/"):
			pattern = "**/" + pattern
		
		exclude_regexes.append(compile_pattern(pattern))



## Compiles the given pattern to a regular expression.
func compile_pattern(pattern: String) -> RegEx:
	
	# ** - matches zero or more characters (including "/")
	# * - matches zero or more characters (excluding "/")
	# ? - matches one character
	
	# we convert the pattern to a regular expression
	# ** becomes .*
	# * becomes [^/]* (any number of characters except /)
	# ? becomes [^/] (any character except /)
	# all other characters are escaped
	# the pattern is anchored at the beginning and end of the string
	# the pattern is case-sensitive

	var regex: String = "^" # start of string
	
	# fix for #21, only append trailing slash if the incoming path
	# doesn't already have one
	#if not base_folder.ends_with("/"):
		#regex += "/"
	
	var length: int = pattern.length()
	
	for i: int in range(length):
		var char: String = pattern[i]
		match char:
			"*":
				var next_i: int = i + 1
				if next_i < length and pattern[next_i] == "*":
					# ** - matches zero or more characters (including "/")
					regex += ".*"
					
					i += 1 # skip the next character
				else:
					# * - matches zero or more characters (excluding "/")
					regex += "[^\\/]*"
				
			"?":
				# ? - matches one character
				regex += "[^\\/]"
			_:
				# escape everything else
				regex += char.json_escape()
	
	
	regex += "$" # end of string
	
	var result := RegEx.new()
	result.compile(regex)
	
	return result


func matches(file: String) -> bool:
	
	if not file.begins_with(base_folder):
		return false
	
	
	# the group definition has a list of include and exclude patterns
	# if the list of include patterns is empty, all files match
	# any file that matches an exclude pattern is excluded
	# we allow * as a wildcard for a single path segment
	# we allow ** as a wildcard for multiple path segments
	
	if include_regexes.size() > 0:
		var found: bool = false
		# the file must match at least one include pattern
		for item: RegEx in include_regexes:
			if item.search(file) != null:
				found = true
				break
			
		if not found:
			return false
	
	# the file must not match any exclude pattern
	for item: RegEx in exclude_regexes:
		if item.search(file) != null:
			return false
	
	return true
