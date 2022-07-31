extends KinematicBody2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var animatedSprite = $AnimatedSprite
onready var hurtBox = $HurtBox
onready var softCollsions = $SoftCollsion
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

export var ACCELERATTON = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANER_TARGET_RANGE = 4  # 游荡范围

enum{
	IDLE, # 原地
	WANDER, # 到处晃荡
	CHASE # 追逐
}

var state = IDLE

func _physics_process(delta):
	
	knockback = knockback.move_toward(Vector2.ZERO , FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO , FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander_state()
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander_state()
				
			accelerate_toward_point(wanderController.target_position,delta)
			if global_position.distance_to(wanderController.target_position) <= WANER_TARGET_RANGE:
				update_wander_state()
		CHASE:
			var player = playerDetectionZone.player
			if player != null: # 若玩家进入攻击范围，将跟随玩家
#				var direction =( player.global_position - global_position ).normalized()
				accelerate_toward_point(player.global_position,delta)
			else:
				state = IDLE
			
	if softCollsions.is_collding():
		velocity += softCollsions.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle() # 洗牌
	return state_list.pop_front() # 随机抽取一个
	
func accelerate_toward_point(point,delta):
	var direction =global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATTON * delta)
	animatedSprite.flip_h = velocity.x < 0

func update_wander_state():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtBox.start_invincibility(0.5)
	hurtBox.create_hit_effect()


func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()


func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("stop")


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("start")
