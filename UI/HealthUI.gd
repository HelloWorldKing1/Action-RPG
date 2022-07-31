extends Control

var hearts = 10 setget set_hearts
var max_hearts = 10 setget set_max_hearts

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * 15
		if hearts == 0:
			heartUIFull.visible = false
	
func set_max_hearts(value):
	max_hearts = max(value,1)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15 

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts =PlayerStats.health
	PlayerStats.connect("health_changed",self,"set_hearts")
	PlayerStats.connect("max_health_changed",self,"set_max_hearts")
