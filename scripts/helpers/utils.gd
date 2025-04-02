class_name Utils

## Helper function: replaces any resource-saved text's escaped line breaks with actual line breaks.
static func replace_line_breaks(s: String) -> String:
	return s.replace("\\n", "\n")

# ## Helper function for waiting multiple signals. Accepts [signals] array
# static func await_all(signals) -> void:
# 	var waiters = []
# 	for sig in signals:
# 		waiters.append(await sig)

