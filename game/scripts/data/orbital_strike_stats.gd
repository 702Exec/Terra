class_name OrbitalStrikeStats
extends Resource

## Fire support called down from the mothership in orbit.
##
## This is the first credit sink that does not compound. Turrets and upgrades
## make the player permanently stronger, which is why credits piled up — buying
## power accelerates earning power. A strike is spent and gone, which is also
## the game's central bargain in miniature: every credit burned here is one that
## does not go home.
##
## Two properties keep it from being a cheat. It costs enough and cools down
## slowly enough to buy time rather than victory, and because armour applies
## normally it deletes swarms while barely troubling a Carapace. It is the
## answer to a breakthrough, not a substitute for having prepared.

@export var display_name: String = "Orbital Strike"
@export var cost: int = 300
## Seconds before it can be called again.
@export var cooldown: float = 45.0
## Ground radius of the impact.
@export var radius: float = 8.0
## Damage to everything caught, before each target's armour is applied.
@export var damage: int = 60
## Delay between the target being marked and the round landing. The marker is
## visible to the player for this whole time, which makes the strike a
## prediction rather than a guaranteed delete — enemies walk out of it.
@export var flight_time: float = 1.2
