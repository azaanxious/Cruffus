extends CharacterBody2D

var wheat_points = 0
var bounce_speed_x: float = 200.0
var jump_velocity: float = -300.0
var gravity: float = 980.0

var is_burning: bool = false
var jumps_remaining: int = 0
var bounce_direction: float = -1.0
var ground_y: float = 0.0

func _physics_process(delta: float) -> void:
	if is_burning:
		# Apply simulated gravity during the burn jumps
		velocity.y += gravity * delta
		move_and_slide()

		# Check if the horse has landed back down at its starting ground height
		if global_position.y >= ground_y and velocity.y > 0:
			global_position.y = ground_y
			if jumps_remaining > 0:
				# Trigger Jump 2
				velocity.y = jump_velocity
				velocity.x = bounce_direction * bounce_speed_x
				jumps_remaining -= 1
			else:
				# Both jumps are finished -> Die
				die()
	else:
		# Normal 4-directional movement
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity = input_direction * 350
		move_and_slide()

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Wheat"):
		area.queue_free()
		wheat_points += 10
		$CanvasLayer/PointsDisplay.text = "Points: " + str(wheat_points)

func burn_and_die(fire_position: Vector2) -> void:
	if is_burning:
		return

	is_burning = true
	ground_y = global_position.y # Remember the ground height before jumping

	bounce_direction = sign(global_position.x - fire_position.x)
	if bounce_direction == 0:
		bounce_direction = -1.0

	# Turn the horse burnt orange
	modulate = Color(1.0, 0.35, 0.15)

	# Trigger Jump 1
	velocity.x = bounce_direction * bounce_speed_x
	velocity.y = jump_velocity
	jumps_remaining = 1

func die() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO
	print("Horse burnt and died!")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
