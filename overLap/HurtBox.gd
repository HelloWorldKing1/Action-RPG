extends Area2D

const HitBoxEffect = preload("res://Effects/HitBoxEffect.tscn")

var invincible = false setget set_invincible

signal invincibility_started
signal invincibility_ended

onready var timer = $Timer

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)


func create_hit_effect():
	var hitBoxEffect = HitBoxEffect.instance()
	var main = get_tree().current_scene
	main.add_child(hitBoxEffect)
	hitBoxEffect.global_position = global_position 


func _on_Timer_timeout():
	self.invincible = false


func _on_HurtBox_invincibility_started():
	set_deferred("monitoring",false)


func _on_HurtBox_invincibility_ended():
	set_deferred("monitoring",true)
