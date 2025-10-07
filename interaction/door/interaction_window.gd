extends InteractionComponent
class_name InteractionWindow

# Window Variables
var window_height: float = 0.0
var window_velocity: float = 0.0
@export var window_smoothing: float = 80.0
var window_input_active: bool = false
var window_opened: bool = false

# Movement thresholds
@export var max_height_offset: float = 0.5
var window_creak_velocity_threshold: float = 0.002
var open_height_threshold: float = 0.2
var close_snap_range: float = 0.05
var creak_volume_scale: float = 1000.0
var window_fade_speed: float = 0.5
var prev_window_height: float = 0.0

@export var is_locked: bool = false
var was_just_unlocked: bool = false

var starting_height: float
var maximum_height: float

## -- Sound Settings --
@export var SFX_Close: String

func _ready():
	super._ready()
	starting_height = object_ref.position.y
	maximum_height = starting_height + max_height_offset
	object_ref.position.y = maximum_height

func _process(delta):
	if was_just_unlocked:
		window_velocity = 0.0
		window_input_active = false
		object_ref.position.y = starting_height
		window_height = starting_height
		was_just_unlocked = false
	else:
		if not window_input_active:
			window_velocity = lerp(window_velocity, 0.0, delta * 4.0)
		
		window_height += window_velocity

		if is_locked:
			var lock_wiggle: float = 0.02
			window_height = clamp(window_height, starting_height, starting_height + lock_wiggle)
			object_ref.position.y = window_height
			
			if window_input_active and prev_window_height != window_height:
				window_input_active = false
		else:
			window_height = clamp(window_height, starting_height, maximum_height)
			object_ref.position.y = window_height
			window_input_active = false

			if prev_window_height != window_height:
				update_window_sounds(delta)
			
		prev_window_height = window_height

func _input(event):
	if not is_interacting:
		return

	if event is InputEventMouseMotion:
		window_input_active = true
		var delta_move: float = event.relative.y * 0.001
		delta_move = -delta_move
		
		# small motions resistance
		if abs(delta_move) < 0.01:
			delta_move *= 0.25
		
		window_velocity = lerp(window_velocity, delta_move, 1.0 / window_smoothing)

func interact() -> void:
	super.interact()
	lock_camera = true

func auxInteract() -> void:
	postInteract()

func unlock() -> void:
	is_locked = false
	was_just_unlocked = true
	
	window_velocity = 0.0
	window_input_active = false
	window_height = starting_height
	object_ref.position.y = starting_height

## Fires when the player is interacting with it
func update_window_sounds(_delta: float) -> void:
	# Detect if window opened past threshold
	if abs(window_height - starting_height) > open_height_threshold:
		window_opened = true
	
	# Detect if window closed again
	if window_opened and abs(window_height - starting_height) < close_snap_range:
		window_opened = false
		notify_nodes(0)
		Audio.play(SFX_Close, self.global_transform)
