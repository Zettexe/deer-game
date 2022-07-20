extends KinematicBody2D

# Globalize these later for consistency
const UP = Vector2.UP 
const GRAVITY = 1000
const MAX_FALL_SPEED = 500

var velocity = Vector2.ZERO
var timer: int = rand_range(50, 100)

func _physics_process(delta):
	if timer <= 0:
		if $Sprite.visible:
			$Sprite.visible = false
			$AnimationPlayer.play("Explode")
			$ExplosionRadius/CollisionShape2D.disabled = false
		return
	
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.normal.x != 0:
			velocity.x = collision.normal.x * velocity.x / 2
		else:
			velocity.x *= 0.6
		
		if collision.normal.y != 0:
			velocity.y = collision.normal.y * velocity.y / 2
		else:
			velocity.y *= 0.6
	
	timer -= 1

func _destroy_grenade():
	queue_free()


func _on_ExplosionRadius_body_entered(body):
	if not body.has_method("damage_event"):
		print(body.name + " does not have a damage state")
		return
	
	body.damage_event()
