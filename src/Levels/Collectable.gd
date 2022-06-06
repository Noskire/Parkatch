extends Area

func _ready():
	var rand = rand_range(0, 1.2)
	$AnimationPlayer.advance(rand)

func _on_body_entered(body):
	body.getPoint()
	$AnimationPlayer.play("FadeOut")

func _on_animation_finished(_anim_name):
	queue_free()
