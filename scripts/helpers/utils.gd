class_name Utils

## Helper function: replaces any resource-saved text's escaped line breaks with actual line breaks.
static func replace_line_breaks(s: String) -> String:
	return s.replace("\\n", "\n")

# ## Helper function for waiting multiple signals. Accepts [signals] array
# static func await_all(signals) -> void:
# 	var waiters = []
# 	for sig in signals:
# 		waiters.append(await sig)

## Helper function to tween a property over time. Accepts [target] as the node to tween, [property] as the property to tween, [end_val] as the value to tween to, and [duration] as the duration of the tween.[br]
## [param callback] allows to connect to a Callable when the tween is complete.
static func create_tween(target: Node, property: NodePath, end_val: Variant, duration: float, callback: Variant = null) -> void:
	var tween = target.create_tween()
	tween.tween_property(target, property, end_val, duration)
	## If we have a callback and it's a valid callable, connect it to the tween_completed signal.
	if typeof(callback) == TYPE_CALLABLE and callback.is_valid():
		tween.tween_callback(callback)
