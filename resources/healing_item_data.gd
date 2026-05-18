class_name HealingItemData
extends Resource

enum ItemClass { I = 1, II = 2, III = 3, IV = 4 }

@export var item_class: ItemClass = ItemClass.I
@export var base_heal_amount: float = 10.0
@export var use_delay: float = 1.0
@export var stack_limit: int = 5
@export var rarity: RarityTier
@export var sprite: Texture2D
