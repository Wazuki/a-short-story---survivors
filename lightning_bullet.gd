extends Sprite2D

func interpolate(length, duration = 0.1):
    var tween_offset = get_tree().create_tween()
    var tween_rect_h = get_tree().create_tween()

    tween_offset.tween_property(self, "offset", Vector2(length/2.0, 0), duration)
    tween_rect_h.tween_property(self, "region_rect", Rect2(0, 0, length, 12), duration)

func spark(distance = 900):
    interpolate(distance, 0.2)
    await get_tree().create_timer(0.3).timeout
    interpolate(0, 0.1)

func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("touch"):
        spark()