extends Node3D

@onready var ball = $Ball
@onready var car = $Car
@onready var carbody = $Car/Model
@onready var drift_timer = $DriftTimer
@onready var boost_timer = $BoostTimer
@onready var camera = $Car/Camera3D
@onready var drift_ready_sound = $DriftReadySound
@onready var static_effect = get_node_or_null("StaticEffect")
var hud = null

@export var jump_impulse := 4.0
@export var acceleration = 40.0
@export var max_speed = 50.0
@export var acceleration_rate = 2.0
@export var steer = 12.0
@export var turn_speed = 8.0
@export var body_tilt = 30.0

@export_group("Drift")
@export var drift_steer_same_dir = 2.0
@export var drift_steer_opposite = 1.7
@export var drift_boost_multiplier = 1.5
@export var drift_sound_pitch_min = 0.9
@export var drift_sound_pitch_max = 1.1
@export var drift_cooldown_time = 0.5
@export var drift_charge_time = 1.0

@export_group("Camera")
@export var drift_fov_increase = 10.0
@export var fov_lerp_speed = 3.0
@export var boost_fov_increase = 15.0
@export var camera_turn_strength = 2.0
@export var camera_rotation_speed = 5.0

@export_group("Physics")
@export var friction_force = 8.0
@export var gravity_multiplier = 2.0
@export var max_fall_speed = 50.0
@export var reverse_speed_multiplier = 0.5
@export var deceleration_rate = 0.95
@export var void_height = -20.0

var speed_input = 0.0
var current_speed = 0.0
var rotate_input = 0.0
var steer_raw = 0.0
var is_grounded = false
var drifting = false
var drift_dir = 0
var drift_str = 1.0
var drift_min = false
var boost = 1.0
var default_fov = 75.0
var camera_offset = 0.0
var initial_model_rotation = Vector3.ZERO
var drift_cooldown = 0.0
var current_item = null
var drift_charge_progress = 0.0
var last_checkpoint = Vector3.ZERO
var respawning = false

func _ready():
	default_fov = camera.fov
	initial_model_rotation = carbody.rotation
	ball.continuous_cd = true
	ball.contact_monitor = true
	ball.max_contacts_reported = 4
	ball.gravity_scale = gravity_multiplier
	
	last_checkpoint = ball.global_position
	
	call_deferred("find_hud")

func _physics_process(delta):
	sync_car_position()
	check_void()
	limit_fall_speed()
	apply_movement_force(delta)
	apply_friction()

func _process(delta):
	if respawning:
		return
	
	handle_input()
	
	if drift_cooldown > 0:
		drift_cooldown -= delta
	
	if drifting:
		drift_charge_progress += delta
		update_hud_drift()
	
	if ball.linear_velocity.length() > 0.75:
		rotate_car(delta)
	
	update_drift_steering()
	update_camera(delta)
	update_checkpoint()

func sync_car_position():
	car.transform.origin = ball.transform.origin
	is_grounded = ball.get_contact_count() > 0

func limit_fall_speed():
	if ball.linear_velocity.y < -max_fall_speed:
		ball.linear_velocity.y = -max_fall_speed

func apply_movement_force(delta):
	var target_speed = speed_input * boost
	current_speed = lerpf(current_speed, target_speed, acceleration_rate * delta)
	
	var max_reverse = max_speed * reverse_speed_multiplier
	var clamped_speed = clamp(current_speed, -max_reverse, max_speed)
	var forward_force = -car.global_transform.basis.z * clamped_speed
	
	ball.apply_central_force(forward_force)

func apply_friction():
	if is_grounded:
		if speed_input == 0:
			current_speed *= deceleration_rate
			if abs(current_speed) < 0.5:
				current_speed = 0
			
			if ball.linear_velocity.length() > 0.1:
				var friction = -ball.linear_velocity.normalized() * (friction_force * 0.5)
				ball.apply_central_force(friction)

func handle_input():
	var accel = Input.get_action_strength("Accelerate")
	var brake = Input.get_action_strength("Brake")
	
	if accel > 0:
		speed_input = accel * acceleration
	elif brake > 0:
		speed_input = -brake * acceleration
	else:
		speed_input = 0
	
	steer_raw = Input.get_action_strength("SteerLeft") - Input.get_action_strength("SteerRight")
	
	if Input.is_action_just_pressed("Drift"):
		handle_drift_or_jump()
	
	if drifting and Input.is_action_just_released("Drift"):
		stop_drift()
	
	if Input.is_action_just_pressed("ui_accept") and current_item != null:
		use_item()

func handle_drift_or_jump():
	if not is_grounded or drift_cooldown > 0:
		return
	
	ball.apply_central_impulse(Vector3.UP * jump_impulse)
	
	if abs(steer_raw) > 0.1 and speed_input > 0:
		start_drift()

func start_drift():
	drifting = true
	drift_min = false
	drift_charge_progress = 0.0
	drift_dir = sign(steer_raw)
	drift_timer.start()
	
	if hud:
		hud.update_drift_bar(0.0)

func stop_drift():
	var drift_progress = drift_charge_progress / drift_charge_time
	
	if drift_progress >= 1.0:
		boost = drift_boost_multiplier
		boost_timer.start()
		drift_min = true
	
	drifting = false
	drift_min = false
	drift_str = 1.0
	drift_cooldown = drift_cooldown_time
	drift_charge_progress = 0.0
	
	if hud:
		hud.update_drift_bar(0.0)

func update_drift_steering():
	if drifting:
		var current_steer = sign(steer_raw)
		
		if abs(steer_raw) > 0.1 and current_steer == drift_dir:
			drift_str = drift_steer_same_dir
		else:
			drift_str = drift_steer_opposite
		
		rotate_input = steer_raw * deg_to_rad(steer * drift_str) if abs(steer_raw) > 0.1 else 0
	else:
		drift_str = 1.0
		rotate_input = steer_raw * deg_to_rad(steer)

func rotate_car(delta):
	var new_basis = car.global_transform.basis.rotated(car.global_transform.basis.y, rotate_input)
	car.global_transform.basis = car.global_transform.basis.slerp(new_basis, turn_speed * delta)
	car.global_transform = car.global_transform.orthonormalized()
	
	var target_tilt = rotate_input * ball.linear_velocity.length() / body_tilt
	carbody.rotation = initial_model_rotation
	carbody.rotation.z += target_tilt

func update_camera(delta):
	update_camera_fov(delta)
	update_camera_lag(delta)
	update_camera_rotation(delta)

func update_camera_fov(delta):
	var target_fov = default_fov
	
	if boost > 1.0:
		target_fov += boost_fov_increase
	elif drifting:
		target_fov += drift_fov_increase
	
	camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

func update_camera_lag(delta):
	var target_offset = -steer_raw * camera_turn_strength
	camera_offset = lerp(camera_offset, target_offset, 10.0 * delta)

func update_camera_rotation(delta):
	var target_rotation = car.global_rotation.y
	camera.global_rotation.y = lerp_angle(camera.global_rotation.y, target_rotation, camera_rotation_speed * delta)
	camera.rotation.y += deg_to_rad(camera_offset)

func _on_drift_timer_timeout() -> void:
	if drifting:
		drift_min = true
		drift_ready_sound.pitch_scale = randf_range(drift_sound_pitch_min, drift_sound_pitch_max)
		drift_ready_sound.play()

func _on_boost_timer_timeout() -> void:
	boost = 1.0

func receive_item(item):
	current_item = item
	
	if hud:
		var item_names = ["BOOST", "TRIPLE_BOOST", "SHIELD", "BOMB", "LIGHTNING", "STAR"]
		hud.show_item(item_names[item])

func update_hud_drift():
	if not hud or not drifting:
		return
	
	var progress = clamp(drift_charge_progress / drift_charge_time, 0.0, 1.0)
	hud.update_drift_bar(progress)

func use_item():
	if current_item == null:
		return
	
	match current_item:
		0:
			boost = drift_boost_multiplier
			boost_timer.wait_time = 1.5
			boost_timer.start()
		1:
			boost = drift_boost_multiplier * 1.5
			boost_timer.wait_time = 2.5
			boost_timer.start()
		2:
			print("Shield ativado!")
		3:
			print("Bomba lançada!")
		4:
			print("Raio ativado!")
		5:
			boost = drift_boost_multiplier * 2.0
			boost_timer.wait_time = 3.0
			boost_timer.start()
	
	current_item = null
	if hud:
		hud.hide_item()

func find_hud():
	var root = get_tree().root
	hud = root.find_child("hud", true, false)
	if hud:
		print("HUD encontrado!")
	else:
		print("HUD não encontrado")

func check_void():
	if ball.global_position.y < void_height and not respawning:
		respawn()

func update_checkpoint():
	if is_grounded and ball.linear_velocity.length() > 1.0:
		last_checkpoint = ball.global_position

func respawn():
	respawning = true
	
	if static_effect:
		static_effect.show_effect()
	
	await get_tree().create_timer(0.5).timeout
	
	ball.global_position = last_checkpoint
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	car.global_position = last_checkpoint
	current_speed = 0
	
	stop_drift()
	
	await get_tree().create_timer(0.3).timeout
	
	if static_effect:
		static_effect.hide_effect()
	
	respawning = false
