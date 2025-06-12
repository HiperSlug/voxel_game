@tool
class_name PathVerifier

## MODIFIED. I HAVE NO IDEA WHATS HAPPENING SO I JUST USED CHATGPT TO MODIFY IT TO ALLOW NESTED SEARCHING ##

var _include_regexes:Array[RegEx]
var _exclude_regexes:Array[RegEx]
var base_folder: String

func _init(_base_folder:String, include_patterns:Array[String], exclude_patterns:Array[String]):
	# compile the include and exclude patterns to regular expressions, so we don't
	# have to do it for each file
	_include_regexes = []
	_exclude_regexes = []
	

	for pattern in include_patterns:
		if pattern == "" or pattern == null:
			continue
		if not pattern.contains("/"):
			pattern = "**/" + pattern  # match in nested folders too
		_include_regexes.append(_compile_pattern(pattern))

	for pattern in exclude_patterns:
		if pattern == "" or pattern == null:
			continue
		if not pattern.contains("/"):
			pattern = "**/" + pattern
		_exclude_regexes.append(_compile_pattern(pattern))



## Compiles the given pattern to a regular expression.
func _compile_pattern(pattern:String) -> RegEx:
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

	var regex = "^"
	
	# fix for #21, only append trailing slash if the incoming path
	# doesn't already have one
	#if not base_folder.ends_with("/"):
		#regex += "/"
		
	var i = 0
	var len = pattern.length()

	while i < len:
		var c = pattern[i]
		if c == "*":
			if i + 1 < len and pattern[i + 1] == "*":
				# ** - matches zero or more characters (including "/")
				regex += ".*"
				i += 2
			else:
				# * - matches zero or more characters (excluding "/")
				regex += "[^\\/]*"
				i += 1
		elif c == "?":
			# ? - matches one character
			regex += "[^\\/]"
			i += 1
		else:
			# escape all other characters
			regex += _escape_character(c)
			i += 1

	regex += "$"

	var  result = RegEx.new()
	result.compile(regex)
	
	return result


func _escape_string(c:String) -> String:
	var result = ""
	for i in len(c):
		result += _escape_character(c[i])
	return result

## Escapes the given character for use in a regular expression. 
## No clue why this is not built-in.
func _escape_character(c:String) -> String:
	if c == "\\":
		return "\\\\"
	elif c == "^":
		return "\\^"
	elif c == "$":
		return "\\$"
	elif c == ".":
		return "\\."
	elif c == "|":
		return "\\|"
	elif c == "?":
		return "\\?"
	elif c == "*":
		return "\\*"
	elif c == "+":
		return "\\+"
	elif c == "(":
		return "\\("
	elif c == ")":
		return "\\)"
	elif c == "{":
		return "\\{"
	elif c == "}":
		return "\\}"
	elif c == "[":
		return "\\["
	elif c == "]":
		return "\\]"
	elif c == "/":
		return "\\/"
	else:
		return c


func matches(file:String) -> bool:
	
	if not file.begins_with(base_folder):
		return false
	
	var relative_path = file.substr(base_folder.length(), file.length() - base_folder.length())
	if relative_path.begins_with("/"):
		relative_path = relative_path.substr(1, relative_path.length() - 1)
	
	
	# the group definition has a list of include and exclude patterns
	# if the list of include patterns is empty, all files match
	# any file that matches an exclude pattern is excluded
	# we allow * as a wildcard for a single path segment
	# we allow ** as a wildcard for multiple path segments

	if _include_regexes.size() > 0:
		var found = false
		# the file must match at least one include pattern
		for item in _include_regexes:
			if item.search(relative_path) != null:
				found = true
				break
			
		if not found:
			if relative_path.contains(".txt"):
				print("file ", file , " did not match any regex")
			return false

	# the file must not match any exclude pattern
	for item in _exclude_regexes:
		if item.search(relative_path) != null:
			if relative_path.contains(".txt"):
				print("file ", file , " was excluded ")
			return false

	return true
