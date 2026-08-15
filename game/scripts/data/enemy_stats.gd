class_name EnemyStats
extends Resource

## Tuning for one enemy archetype. Stat inflation is the weakest difficulty knob
## (design doc §4), so these numbers stay flat across worlds — difficulty comes
## from lanes, wave gap, and composition instead.

@export var display_name: String = "Grunt"
@export var max_health: int = 40
@export var move_speed: float = 3.2
## Damage dealt to the base per attack once the enemy is in contact.
@export var contact_damage: int = 15
@export var attack_interval: float = 1.0
## How close the enemy has to get to the base before it stops and attacks.
@export var contact_range: float = 3.6
## How far off its lane an enemy will divert to tear down a player structure.
## Wide enough that a node sitting in the lane is reliably attacked, narrow
## enough that one built well off the lane is genuinely safer.
@export var structure_aggro_range: float = 4.5
## Random lateral spread applied to the shared path so a wave reads as a mass
## rather than a single-file queue.
@export var lane_spread: float = 2.5
