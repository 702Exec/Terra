class_name TurretStats
extends Resource

## Tuning for one defensive structure.

@export var display_name: String = "Pulse Turret"
@export var cost: int = 50
@export var attack_range: float = 8.0
@export var damage: int = 12
@export var fire_interval: float = 0.45
## How often the turret re-picks its nearest target. Kept off the frame loop on
## purpose; retargeting four times a second is indistinguishable from every
## frame and costs a fraction as much once unit counts climb.
@export var retarget_interval: float = 0.25
