extends EnemyCharacter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
