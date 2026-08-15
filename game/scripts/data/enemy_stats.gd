class_name EnemyStats
extends Resource

## Tuning for one enemy archetype.
##
## Stats stay flat across worlds (design doc §4 ranks inflation last). What
## escalates is which archetypes appear and in what mix — you out-compose a
## world rather than out-level it.

@export var display_name: String = "Mite"

@export_group("Durability")
@export var max_health: int = 40
## Flat reduction applied to every incoming hit, floored at MIN_DAMAGE in the
## bus. Flat rather than percentage on purpose: it punishes many weak shots and
## rewards fewer heavy ones, which is what makes an armoured wave a reason to
## buy Weapons rather than a reason to build more turrets.
@export var armor: int = 0

@export_group("Movement")
@export var move_speed: float = 4.0
## Random lateral spread applied to the shared lane so a wave reads as a mass
## rather than a single-file queue.
@export var lane_spread: float = 2.5

@export_group("Attack")
@export var attack_damage: int = 15
@export var attack_interval: float = 1.0
## How close this unit needs to be before it stops and attacks, and how far off
## its lane it will divert to reach something. A melee archetype has to walk
## into its target; a ranged one stops short and works from standoff, which is
## what lets it out-reach an un-upgraded turret line.
@export var attack_range: float = 3.6
## Ranged units draw a firing beam. Purely presentational.
@export var ranged: bool = false

@export_group("Appearance")
## Art override. Assign a PackedScene and the unit instances it instead of
## building a grey capsule from the fields below; leave it null and you get the
## grey box. Per archetype, so a bought pack can be introduced one unit at a
## time rather than all at once.
@export var visual_scene: PackedScene
@export var body_color: Color = Color(0.85, 0.26, 0.2)
@export var body_radius: float = 0.35
@export var body_height: float = 1.4
