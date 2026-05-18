class_name ProjectileData
extends Resource

enum OwnerType { PLAYER, ENEMY }

@export var owner_type: OwnerType = OwnerType.PLAYER
@export var speed: float = 20.0
@export var damage: float = 10.0
@export var lifetime: float = 2.0
@export var sprite: Texture2D
