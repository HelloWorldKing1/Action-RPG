extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500 # 每秒增加的速度
export var MAX_SPEED = 80 # 最大速度
export var FRICTION = 500 # 摩擦力
export var ROLL_SPEED = 125 # 翻滚速度


enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vertor = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitBoxPivot/SwordHitBox
onready var hurtBox = $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer


func _ready():
	randomize()
	stats.connect("no_health",self,"queue_free")
	animationTree.active = true 
	$HitBoxPivot/SwordHitBox/CollisionShape2D.disabled = true
	swordHitBox.knockback_vector = roll_vertor
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	# 获取输入
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector =input_vector.normalized()
#	print(input_vector)
	if input_vector != Vector2.ZERO:
#		velocity += input_vector * ACCELERATION * delta
#		velocity = velocity.clamped(MAX_SPEED) * delta
		roll_vertor = input_vector
		swordHitBox.knockback_vector = roll_vertor
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED,ACCELERATION * delta)
		
	else:
#		animationPlayer.play("IdleRight")
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta) # 停止使增加摩擦力
#	print(velocity)
	move()
	
	if Input.is_action_pressed("roll"):
		state = ROLL
	
	if Input.is_action_pressed("attack"):
		state = ATTACK

func move():
	velocity = move_and_slide(velocity)

func attack_state(detal):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finished():
	state = MOVE
	
	
func roll_state(detal):
	velocity = roll_vertor * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE


func _on_HurtBox_area_entered(area):
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	stats.health -= area.damage
	hurtBox.start_invincibility(2)
	hurtBox.create_hit_effect()


func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("stop")


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("start")
