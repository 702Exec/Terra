class_name WaveEntry
extends Resource

## One archetype's share of a wave.
##
## Composition is the escalation mechanism once raw count saturates: a wave gets
## harder because a Carapace showed up in it, not because the Mites got tougher.

@export var stats: EnemyStats
## The wave this archetype starts appearing on. Everything before that is a
## world where the player has not met it yet.
@export var from_wave: int = 1
## Relative share among whatever archetypes are available on a given wave.
@export var weight: float = 1.0
