extends Node2D
@export var foreground_parallax: Parallax2D

func _ready():
	foreground_parallax.scroll_offset = Vector2(0, -337.0)
