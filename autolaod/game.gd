extends Node

enum FailureState {
	None,
	RunnedOutOfTime,
	AbandonedRun,
}

var rottaion_speed: float = 0.5
var time_limit: float

@warning_ignore_start("unused_signal")
signal run_finished(time: float, state: FailureState)
@warning_ignore_restore("unused_signal")

signal _start_run

func start_run() -> void:
	_start_run.emit()
